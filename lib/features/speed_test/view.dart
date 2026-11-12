import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/features/form/selection_sheet.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'client.dart';
import 'gauge.dart';
import 'history.dart';
import 'settings.dart';
import 'store.dart';
import 'widgets.dart';

class SpeedTestView extends ConsumerStatefulWidget {
  const SpeedTestView({super.key});
  @override
  ConsumerState<SpeedTestView> createState() => _SpeedTestViewState();
}

class _SpeedTestViewState extends ConsumerState<SpeedTestView> {
  late final SpeedTestClient _client;
  late final StreamSubscription<SpeedTestState> _updates;
  SpeedTestSettings _settings = const SpeedTestSettings();
  SpeedTestState? _state;
  SpeedTestState? _probe;
  List<Traffic> _samples = const [];
  int _downIndex = -1;
  int _upIndex = -1;
  String _proxy = '';
  String? _request;
  bool _loaded = false;
  bool _probing = false;
  bool _testing = false;
  bool _confirming = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _client = ref.read(speedTestClientProvider);
    _updates = _client.updates.listen(_onUpdate);
    unawaited(_load());
  }

  Future<void> _load() async {
    try {
      final data = await ref.read(speedTestStoreProvider.future);
      if (!mounted) return;
      setState(() {
        _settings = data.settings;
        _loaded = true;
      });
      await _detect();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loaded = true;
        _error = 'unavailable';
      });
    }
  }

  String _route() => ref.read(isStartProvider) ? _proxy : 'DIRECT';
  String _id() => '${DateTime.now().microsecondsSinceEpoch}';

  Future<void> _detect() async {
    if (_testing || !mounted) return;
    final id = _id();
    _request = id;
    setState(() {
      _probing = true;
      _error = null;
    });
    try {
      final result = await _client.probe(_settings, _route(), id);
      if (!mounted || _request != id) return;
      setState(() {
        _probe = result;
        _probing = false;
        _error = result.error.isEmpty || result.error == 'cancelled'
            ? null
            : result.error;
      });
    } catch (_) {
      if (!mounted || _request != id) return;
      setState(() {
        _probing = false;
        _error = 'unavailable';
      });
    }
  }

  void _onUpdate(SpeedTestState state) {
    if (!mounted || !_testing || state.id != _request) return;
    setState(() {
      _state = state;
      if (state.phase != SpeedTestPhase.download &&
          state.phase != SpeedTestPhase.upload) {
        return;
      }
      final up = state.phase == SpeedTestPhase.upload;
      final index = (state.progress.clamp(0, 1) * 59).round();
      final previous = up ? _upIndex : _downIndex;
      final samples = [..._samples];
      for (var i = previous + 1; i <= index; i++) {
        samples[i] = up
            ? samples[i].copyWith(up: state.speed / 8)
            : samples[i].copyWith(down: state.speed / 8);
      }
      _samples = samples;
      if (up) {
        _upIndex = index;
      } else {
        _downIndex = index;
      }
    });
  }

  Future<void> _start() async {
    if (_testing || _confirming || !_loaded) return;
    setState(() => _confirming = true);
    var allowed = true;
    try {
      if (system.isAndroid) {
        final networks = await Connectivity().checkConnectivity();
        if (!mounted) return;
        if (networks.contains(ConnectivityResult.mobile) &&
            !networks.contains(ConnectivityResult.wifi)) {
          allowed =
              await dialogs.showMessage(
                message: TextSpan(
                  text: context.appLocalizations.speedTestMobileDataTip,
                ),
                confirmText: context.appLocalizations.speedTestStart,
              ) ==
              true;
        }
      }
    } catch (error) {
      commonPrint.log('Speed test network type: $error');
    } finally {
      if (mounted) setState(() => _confirming = false);
    }
    if (!mounted || !allowed) return;
    final id = _id();
    _request = id;
    final proxy = _route();
    setState(() {
      _testing = true;
      _probing = false;
      _error = null;
      _state = SpeedTestState(id: id, direct: !ref.read(isStartProvider));
      _samples = List.filled(60, const Traffic());
      _downIndex = -1;
      _upIndex = -1;
    });
    try {
      final result = await _client.start(_settings, proxy, id);
      if (!mounted || _request != id) return;
      setState(() {
        _state = result;
        _probe = result;
        _testing = false;
        _error = result.error.isEmpty || result.error == 'cancelled'
            ? null
            : result.error;
      });
      if (result.completed) {
        try {
          await ref
              .read(speedTestStoreProvider.notifier)
              .add(
                SpeedTestRecord(
                  time: DateTime.now().millisecondsSinceEpoch,
                  proxy: proxy,
                  result: result,
                ),
              );
        } catch (error) {
          commonPrint.log('Save speed test record: $error');
        }
      }
    } catch (_) {
      if (!mounted || _request != id) return;
      setState(() {
        _testing = false;
        _state = null;
        _error = 'unavailable';
      });
    }
  }

  Future<void> _stop() async {
    final id = _request;
    _request = null;
    setState(() {
      _testing = false;
      _probing = false;
      _state = null;
    });
    if (id != null) await _client.cancel(id);
  }

  Future<void> _chooseOutbound() async {
    if (_testing || _confirming) return;
    final l = context.appLocalizations;
    final groups = ref.read(groupsProvider);
    final groupNames = {for (final group in groups) group.name};
    final names = <String>{};
    for (final group in groups) {
      for (final node in group.all) {
        if (!groupNames.contains(node.name) &&
            !const {
              'DIRECT',
              'REJECT',
              'REJECT-DROP',
              'PASS',
            }.contains(node.name) &&
            !const {
              'Reject',
              'RejectDrop',
              'Pass',
              'Compatible',
            }.contains(node.type)) {
          names.add(node.name);
        }
      }
    }
    final value = await showSheet<String>(
      context: context,
      builder: (context) => SelectionSheet<String>(
        title: l.speedTestChangeOutbound,
        sections: [
          SelectionSection(items: ['', 'DIRECT', ...names]),
        ],
        labelBuilder: (name) => name.isEmpty
            ? l.speedTestFollowRules
            : name == 'DIRECT'
            ? l.direct
            : name,
        selectedOf: (_) => _proxy,
        onSelected: (name) => Navigator.of(context).pop(name),
      ),
    );
    if (!mounted || value == null || value == _proxy) return;
    setState(() {
      _proxy = value;
      _state = null;
    });
    await _detect();
  }

  Future<void> _openSettings() async {
    if (_testing || _confirming) return;
    final settings = await showFormSheet<SpeedTestSettings>(
      context: context,
      props: nestedPagedSheetProps,
      builder: (_) => NestedPagedSheet(
        builder: (_) =>
            SpeedTestSettingsView(settings: _settings, proxy: _route()),
      ),
    );
    if (!mounted || settings == null) return;
    setState(() {
      _settings = settings;
      _state = null;
    });
    await ref.read(speedTestStoreProvider.notifier).settings(settings);
    if (mounted) await _detect();
  }

  Future<void> _openHistory() => showSheet<void>(
    context: context,
    props: nestedPagedSheetProps,
    builder: (_) =>
        NestedPagedSheet(builder: (_) => const SpeedTestHistoryView()),
  );

  @override
  void dispose() {
    unawaited(_updates.cancel());
    final id = _request;
    if (id != null) unawaited(_client.cancel(id));
    super.dispose();
  }

  Widget _hero(BuildContext context) {
    final l = context.appLocalizations;
    final phase = _state?.phase;
    final color = phase == SpeedTestPhase.upload
        ? speedUploadColor(context)
        : context.colorScheme.primary;
    final gauge = SpeedTestGauge(
      state: _state,
      waiting:
          !_loaded ||
          _probing ||
          (_testing &&
              (phase == SpeedTestPhase.connecting ||
                  phase == SpeedTestPhase.latency)),
      color: color,
      otherColor: phase == SpeedTestPhase.upload
          ? context.colorScheme.primary
          : speedUploadColor(context),
    );
    final panel = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton(
          onPressed: !_loaded || _confirming
              ? null
              : _testing
              ? _stop
              : _start,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              _testing
                  ? l.speedTestStop
                  : _state?.completed == true
                  ? l.speedTestAgain
                  : l.speedTestStart,
            ),
          ),
        ),
        const SizedBox(height: 24),
        SpeedTestMetrics(state: _state),
        if (_state != null && _state!.bytes > 0) ...[
          const SizedBox(height: 18),
          Text(
            '${l.speedTestDataUsed} · ${speedTestBytes(_state!.bytes)}',
            style: AppTextStyle.footnote
                .of(context)
                .copyWith(color: context.colorScheme.onSurfaceVariant),
          ),
        ],
      ],
    );
    return Card(
      radius: AppCorner.xl,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            spacing: 8,
            children: [
              GlyphIcon(AppGlyphs.speed, size: 20, color: color),
              Expanded(
                flex: 2,
                child: Text(
                  'Speedtest',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.headline.of(context, emphasized: true),
                ),
              ),
              Expanded(
                child: Text(
                  _state?.fallback == true
                      ? '${speedProtocolLabel(_settings.protocol)} → ${speedProtocolLabel(_state!.protocol)}'
                      : speedProtocolLabel(
                          _state == null || phase == SpeedTestPhase.connecting
                              ? _settings.protocol
                              : _state!.protocol,
                        ),
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.footnote
                      .of(context)
                      .copyWith(color: context.colorScheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) => constraints.maxWidth >= 640
                ? Row(
                    children: [
                      Expanded(child: gauge),
                      const SizedBox(width: 28),
                      Expanded(child: panel),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [gauge, const SizedBox(height: 12), panel],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _routeCard(BuildContext context, bool running) {
    final l = context.appLocalizations;
    final result = _state ?? _probe;
    final chains = result?.outbound?.chains ?? const <String>[];
    final selected = !running || _proxy == 'DIRECT'
        ? l.direct
        : _proxy.isEmpty
        ? l.speedTestFollowRules
        : _proxy;
    final server = _settings.server;
    final actual = result?.server;
    final serverText =
        server?.title ??
        (actual == null
            ? l.auto
            : [
                actual.sponsor,
                actual.city,
              ].where((s) => s.isNotEmpty).join(' · '));
    return generateGroup([
      ListItem(
        leading: const GlyphIcon(AppGlyphs.proxies),
        title: Text(l.speedTestExitNode),
        subtitle: !running
            ? Text(l.speedTestCoreStopped)
            : chains.isEmpty
            ? null
            : EmojiText(chains.last),
        trailing: TextButton(
          onPressed: _testing || !running ? null : _chooseOutbound,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 160),
                child: PopupValueText(selected),
              ),
              const GlyphIcon(Glyphs.picker, size: 16),
            ],
          ),
        ),
      ),
      ListItem(
        leading: const GlyphIcon(AppGlyphs.resources),
        title: Text(l.speedTestServer),
        subtitle: Text(serverText.isEmpty ? l.auto : serverText),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(speedTestClientProvider);
    final l = context.appLocalizations;
    final running = ref.watch(isStartProvider);
    ref.listen(isStartProvider, (_, _) {
      if (_testing) {
        unawaited(
          _stop().then((_) {
            if (mounted) unawaited(_detect());
          }),
        );
      } else if (_loaded) {
        unawaited(_detect());
      }
    });
    return Scaffold(
      title: l.speedTest,
      iconActions: [
        IconButtonData(
          glyph: AppGlyphs.clock,
          tooltip: l.speedTestHistory,
          onPressed: _openHistory,
        ),
        IconButtonData(
          glyph: AppGlyphs.sliders,
          tooltip: l.speedTestSettings,
          onPressed: _testing || _confirming || !_loaded ? null : _openSettings,
        ),
      ],
      body: Builder(
        builder: (context) => ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(
            top: context.contentTopPadding + 12,
            bottom: 20 + context.bottomInset,
          ),
          children: [
            _hero(context),
            const SizedBox(height: 16),
            _routeCard(context, running),
            if (_error != null) ...[
              const SizedBox(height: 12),
              ListFooter(
                text: switch (_error) {
                  'rejected' => l.speedTestErrorRejected,
                  'blocked' => l.speedTestErrorBlocked,
                  'timeout' => l.speedTestErrorTimeout,
                  _ => l.speedTestErrorUnavailable,
                },
              ),
            ],
            if (_downIndex >= 0 || _upIndex >= 0) ...[
              const SizedBox(height: 16),
              SpeedTestWaveform(samples: _samples),
            ],
            ListFooter(text: l.speedTestCredit),
          ],
        ),
      ),
    );
  }
}
