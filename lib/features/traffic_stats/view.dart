import 'dart:async';
import 'dart:math' as math;

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'client.dart';
import 'settings.dart';
import 'store.dart';
import 'widgets.dart';

class TrafficStatsView extends ConsumerStatefulWidget {
  const TrafficStatsView({super.key});

  @override
  ConsumerState<TrafficStatsView> createState() => _TrafficStatsViewState();
}

class _TrafficStatsViewState extends ConsumerState<TrafficStatsView> {
  static const _refreshInterval = Duration(seconds: 30);

  TrafficStatsPeriod _period = TrafficStatsPeriod.day;
  DateTime _anchor = DateTime.now();
  TrafficStatsRankTab _rankTab = TrafficStatsRankTab.domain;
  TrafficStatsResult? _result;
  bool _loading = true;
  Timer? _timer;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(_refreshInterval, (_) {
      final enabled =
          ref.read(trafficStatsStoreProvider).value?.enable ?? false;
      if (enabled && ref.read(appVisibleProvider)) {
        unawaited(_refresh());
      }
    });
    unawaited(_refresh(initial: true));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _refresh({bool initial = false}) async {
    final id = ++_requestId;
    if (initial && _result == null && mounted) {
      setState(() => _loading = true);
    }
    try {
      final (start, end) = trafficStatsDateRange(_period, _anchor);
      final result = await ref
          .read(trafficStatsClientProvider)
          .getStats(start: start, end: end);
      if (!mounted || id != _requestId) return;
      setState(() {
        _result = result;
        _loading = false;
      });
    } catch (_) {
      if (!mounted || id != _requestId) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _enable() async {
    await ref
        .read(trafficStatsStoreProvider.notifier)
        .updateSettings((s) => s.copyWith(enable: true));
    await _refresh();
  }

  void _changePeriod(TrafficStatsPeriod period) {
    if (period == _period) return;
    setState(() {
      _period = period;
      _anchor = DateTime.now();
    });
    unawaited(_refresh());
  }

  void _stepAnchor(int delta) {
    final next = trafficStatsStepAnchor(_period, _anchor, delta);
    setState(() => _anchor = next);
    unawaited(_refresh());
  }

  Future<void> _openSettings() async {
    await showFormSheet<void>(
      context: context,
      props: nestedPagedSheetProps,
      builder: (_) => NestedPagedSheet(
        builder: (_) =>
            TrafficStatsSettingsView(onCleared: () => unawaited(_refresh())),
      ),
    );
    if (mounted) {
      unawaited(_refresh());
    }
  }

  bool _hasAnyData(TrafficStatsResult result) =>
      result.total > 0 ||
      result.series.any((p) => p.total > 0) ||
      result.hosts.isNotEmpty ||
      result.processes.isNotEmpty ||
      result.nodes.isNotEmpty ||
      result.profiles.isNotEmpty ||
      result.rules.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    ref.watch(trafficStatsClientProvider);
    ref.listen(trafficStatsStoreProvider, (prev, next) {
      if (prev?.value != next.value) {
        unawaited(_refresh());
      }
    });

    final l = context.appLocalizations;
    final store = ref.watch(trafficStatsStoreProvider);
    final settings = store.value ?? const TrafficStatsSettings();
    final result = _result ?? const TrafficStatsResult();
    final hasData = _hasAnyData(result);
    final showEmptyDisabled = !settings.enable && !hasData;

    return TrafficStatsScope(
      child: Scaffold(
        title: l.trafficStats,
        groupIconActions: false,
        iconActions: [
          IconButtonData(
            glyph: AppGlyphs.refresh,
            tooltip: l.trafficStatsRefresh,
            onPressed: _loading ? null : () => unawaited(_refresh()),
          ),
          IconButtonData(
            glyph: AppGlyphs.sliders,
            tooltip: l.settings,
            onPressed: _openSettings,
          ),
        ],
        body: Builder(
          builder: (context) => NullStatusSwitcher(
            isLoading: (_loading && _result == null) || store.isLoading,
            isEmpty: false,
            loadingStatus: const ActivityIndicator.page(),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final sidePadding = math.max(
                  16.0,
                  (constraints.maxWidth - 928) / 2,
                );
                final isWide = constraints.maxWidth >= 760;
                final listPadding = EdgeInsets.symmetric(horizontal: sidePadding)
                    .copyWith(
                      top: context.contentTopPadding + 12,
                      bottom: 24 + context.bottomInset,
                    );

                if (showEmptyDisabled) {
                  return ListView(
                    padding: listPadding,
                    children: [
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 460),
                          child: TrafficStatsDisabledCard(onEnable: _enable),
                        ),
                      ),
                    ],
                  );
                }

                return ListView(
                  padding: listPadding,
                  children: [
                    TrafficStatsPeriodBar(
                      period: _period,
                      anchor: _anchor,
                      onPeriodChanged: _changePeriod,
                      onStep: _stepAnchor,
                    ),
                    if (!settings.enable) ...[
                      const SizedBox(height: 12),
                      TrafficStatsDisabledBanner(onEnable: _enable),
                    ],
                    const SizedBox(height: 12),
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(minHeight: 238),
                              child: TrafficStatsOverviewCard(result: result),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 6,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(minHeight: 238),
                              child: TrafficStatsTrendCard(
                                points: result.series,
                                period: _period,
                              ),
                            ),
                          ),
                        ],
                      )
                    else ...[
                      TrafficStatsOverviewCard(result: result),
                      const SizedBox(height: 12),
                      TrafficStatsTrendCard(
                        points: result.series,
                        period: _period,
                      ),
                    ],
                    if (result.rules.isNotEmpty)
                      TrafficStatsRuleHitsSection(
                        rules: result.rules,
                        totalHits: result.ruleHits,
                      ),
                    TrafficStatsRankingSection(
                      result: result,
                      settings: settings,
                      tab: _rankTab,
                      onTabChanged: (tab) => setState(() => _rankTab = tab),
                    ),
                    if (result.since.isNotEmpty)
                      ListFooter(text: l.trafficStatsSince(result.since)),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
