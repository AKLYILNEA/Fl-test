import 'dart:async';
import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/event.dart';
import 'package:fl_clash/core/method.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/pages/scan.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' show join;

import 'catalog.dart';
import 'client.dart';
import 'labels.dart';
import 'iperf_link.dart';
import 'widgets.dart';

Map<String, Object?> toolDefaults(ToolboxTool tool) => switch (tool) {
  ToolboxTool.speed => {
    'provider': 'apple',
    'protocol': 'h3',
    'duration': 10,
    'streams': 6,
    'proxy': '',
    'use-system-dns': false,
  },
  ToolboxTool.route => {'network': 'tcp', 'port': 443},
  ToolboxTool.dns => {
    'type': 'A',
    'mode': 'system',
    'server': '1.1.1.1',
    'compare': false,
  },
  ToolboxTool.mrs => {'resolve': true},
  ToolboxTool.nat => {'proxy': ''},
  ToolboxTool.ping => {
    'protocol': 'icmp',
    'port': 443,
    'count': 20,
    'interval': 1000,
    'size': 56,
  },
  ToolboxTool.iperf => {
    'role': 'client',
    'protocol': 'tcp',
    'direction': 'upload',
    'port': 5201,
    'parallel': 1,
    'duration': 10,
    'bandwidth': 10,
  },
  ToolboxTool.traffic => {
    'days': 1,
    'enable': false,
    'detail': true,
    'retention-days': 7,
    'host': '',
  },
  _ => {},
};

CoreMethod toolRunMethod(ToolboxTool tool) => switch (tool) {
  ToolboxTool.speed => CoreMethod.toolboxSpeedStart,
  ToolboxTool.route => CoreMethod.toolboxRouteTrace,
  ToolboxTool.dns => CoreMethod.toolboxDnsQuery,
  ToolboxTool.mrs => CoreMethod.toolboxMrsLookup,
  ToolboxTool.nat => CoreMethod.toolboxStunStart,
  ToolboxTool.ping => CoreMethod.toolboxPingStart,
  ToolboxTool.iperf => CoreMethod.toolboxIperfStart,
  ToolboxTool.traffic => CoreMethod.toolboxTrafficQuery,
  _ => throw ArgumentError.value(tool),
};

CoreMethod? toolCancelMethod(ToolboxTool tool) => switch (tool) {
  ToolboxTool.speed => CoreMethod.toolboxSpeedCancel,
  ToolboxTool.nat => CoreMethod.toolboxStunCancel,
  ToolboxTool.ping => CoreMethod.toolboxPingCancel,
  ToolboxTool.iperf => CoreMethod.toolboxIperfCancel,
  ToolboxTool.mrs => CoreMethod.toolboxMrsCancel,
  _ => null,
};

class DiagnosticToolPage extends ConsumerStatefulWidget {
  const DiagnosticToolPage({super.key, required this.tool, this.client});

  final ToolboxTool tool;
  final ToolboxClient? client;

  @override
  ConsumerState<DiagnosticToolPage> createState() => _DiagnosticToolPageState();
}

class _DiagnosticToolPageState extends ConsumerState<DiagnosticToolPage>
    with CoreEventListener {
  final _target = TextEditingController();
  late Map<String, Object?> _options = toolDefaults(widget.tool);
  List<String> _history = [];
  List<Map<String, Object?>> _records = [];
  Object? _result;
  String? _error;
  bool _busy = false;
  bool _serverRunning = false;
  int _serial = 0;
  Timer? _eventTimer;
  Map<String, Object?>? _pendingEvent;

  ToolboxClient get _client => widget.client ?? toolboxClient;

  @override
  void initState() {
    super.initState();
    coreEventManager.addListener(this);
    unawaited(_load());
  }

  Future<void> _load() async {
    try {
      final saved = await toolboxStore.load(widget.tool.name);
      if (!mounted) return;
      setState(() {
        if (saved['options'] case final Map options) {
          _options = {..._options, ...Map<String, Object?>.from(options)};
        }
        _history = (saved['history'] as List? ?? [])
            .whereType<String>()
            .take(10)
            .toList();
        _records = [
          for (final record in saved['records'] as List? ?? [])
            if (record is Map) Map<String, Object?>.from(record),
        ];
      });
    } catch (error) {
      commonPrint.log('Unable to read toolbox settings: $error');
    }
  }

  Future<void> _save() => toolboxStore.save(widget.tool.name, {
    'options': _options,
    'history': _history,
    'records': _records.take(200).toList(),
  });

  @override
  void onToolbox(String kind, Map<String, Object?> data) {
    final expected = switch (widget.tool) {
      ToolboxTool.speed => 'speedTest',
      ToolboxTool.nat => 'stunTest',
      ToolboxTool.ping => 'localPing',
      ToolboxTool.iperf => 'iperf',
      _ => '',
    };
    if (kind != expected || (!_busy && !_serverRunning)) return;
    _pendingEvent = data;
    _eventTimer ??= Timer(const Duration(milliseconds: 100), () {
      _eventTimer = null;
      if (mounted && _pendingEvent != null) {
        setState(() => _result = _pendingEvent);
      }
    });
  }

  @override
  void dispose() {
    coreEventManager.removeListener(this);
    _eventTimer?.cancel();
    _serial++;
    if (_busy) {
      final cancel = toolCancelMethod(widget.tool);
      if (cancel != null) unawaited(_quietCall(cancel));
    }
    if (_serverRunning) unawaited(_quietCall(CoreMethod.toolboxIperfStop));
    _target.dispose();
    super.dispose();
  }

  Future<void> _quietCall(CoreMethod method) async {
    try {
      await _client.call(method);
    } catch (error) {
      commonPrint.log('Toolbox cleanup failed: $error');
    }
  }

  Future<void> _cancel() async {
    final method = toolCancelMethod(widget.tool);
    if (method == null) return;
    try {
      await _client.call(method);
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    }
  }

  void _set(String key, Object? value) {
    setState(() => _options = {..._options, key: value});
  }

  Future<void> _run() async {
    if (_busy) return;
    final tool = widget.tool;
    final target = _target.text.trim();
    final l = context.appLocalizations;
    if ([
          ToolboxTool.route,
          ToolboxTool.dns,
          ToolboxTool.mrs,
          ToolboxTool.ping,
        ].contains(tool) &&
        target.isEmpty) {
      setState(() => _error = l.tbTargetRequired);
      return;
    }
    if (tool == ToolboxTool.iperf &&
        _options['role'] == 'client' &&
        target.isEmpty) {
      setState(() => _error = l.iperfAddressRequired);
      return;
    }
    FocusScope.of(context).unfocus();
    final serial = ++_serial;
    setState(() {
      _busy = true;
      _error = null;
      _result = null;
    });
    try {
      final params = {..._options, 'target': target};
      Object? result;
      if (tool == ToolboxTool.dns) {
        params['domain'] = target;
        final running = ref.read(runTimeProvider) != null;
        final modes = _options['compare'] == true
            ? [if (running) 'follow', 'system', 'custom']
            : [
                _options['mode'] == 'follow' && !running
                    ? 'system'
                    : _options['mode'],
              ];
        result = {
          for (final mode in modes)
            '$mode': await _client.query(CoreMethod.toolboxDnsQuery, {
              ...params,
              'mode': mode,
            }),
        };
      } else if (tool == ToolboxTool.mrs) {
        final bundle = File(join(await appPath.homeDirPath, 'BundleMRS.7z'));
        if (!await bundle.exists()) {
          final response = await request.getFileResponseForUrl(
            'https://github.com/appshubcc/bett-rules/releases/download/latest/BundleMRS.7z',
          );
          await bundle.safeWriteAsBytes(response.data!);
        }
        if (!mounted || serial != _serial) return;
        final ready = await _client.query(CoreMethod.toolboxMrsPrepare);
        if (ready['error'] != null && ready['error'] != '') {
          throw StateError(l.mrsPrepareFailed);
        }
        result = await _client.query(CoreMethod.toolboxMrsLookup, params);
      } else if (tool == ToolboxTool.nat) {
        result = await _client.query(CoreMethod.toolboxStunStart, {
          ...params,
          'server': target,
        });
      } else if (tool == ToolboxTool.iperf) {
        if (_options['role'] == 'server') {
          if (_serverRunning) {
            await _client.call(CoreMethod.toolboxIperfStop);
            result = <String, Object?>{'phase': 'done'};
          } else {
            result = await _client.query(CoreMethod.toolboxIperfListen, {
              'port': _options['port'],
            });
            if (!mounted || serial != _serial) {
              await _quietCall(CoreMethod.toolboxIperfStop);
              return;
            }
          }
          _serverRunning =
              !_serverRunning &&
              (result as Map)['error'] != 'listen' &&
              result['error'] != 'port-in-use';
        } else {
          final link = parseIperfLink(target);
          final address = parseIperfAddress(target);
          result = await _client.query(CoreMethod.toolboxIperfStart, {
            ...params,
            'hosts':
                link?.hosts ??
                target
                    .split(RegExp(r'[\s,]+'))
                    .map((host) => parseIperfAddress(host)?.host ?? host)
                    .toList(),
            'port':
                link?.port ??
                (target.contains(':') && address != null
                    ? address.port
                    : _options['port']),
            'bandwidth': (_options['bandwidth'] as num) * 1000000,
          });
        }
      } else if (tool == ToolboxTool.traffic) {
        final now = DateTime.now();
        final date = DateFormat('yyyy-MM-dd');
        result = await _client.query(CoreMethod.toolboxTrafficQuery, {
          'start': date.format(
            now.subtract(Duration(days: (_options['days'] as int) - 1)),
          ),
          'end': date.format(now),
          'top': 100,
          'host': target,
        });
      } else {
        result = await _client.query(toolRunMethod(tool), params);
      }
      if (!mounted || serial != _serial) return;
      _eventTimer?.cancel();
      _eventTimer = null;
      _pendingEvent = null;
      setState(() {
        _result = result;
        if (result is Map && result['error'] != null && result['error'] != '') {
          _error = toolErrorLabel(l, '${result['error']}');
        }
        if (target.isNotEmpty) {
          _history = [
            target,
            ..._history.where((item) => item != target),
          ].take(10).toList();
        }
        if (tool == ToolboxTool.speed && result is Map && _error == null) {
          final cutoff = DateTime.now()
              .subtract(const Duration(days: 14))
              .millisecondsSinceEpoch;
          _records = [
            {'time': DateTime.now().millisecondsSinceEpoch, 'result': result},
            ..._records.where((r) => (r['time'] as int? ?? 0) >= cutoff),
          ];
        }
      });
      await _save();
    } catch (error) {
      if (mounted && serial == _serial) setState(() => _error = '$error');
    } finally {
      if (mounted && serial == _serial) setState(() => _busy = false);
    }
  }

  Widget _choice(
    String key,
    List<Object> values, {
    String Function(Object)? label,
  }) => ListItem<Object>.options(
    title: Text(toolFieldLabel(context.appLocalizations, key)),
    options: values,
    value: values.contains(_options[key]) ? _options[key]! : values.first,
    textBuilder:
        label ?? (value) => toolOptionLabel(context.appLocalizations, '$value'),
    onChanged: (value) => _set(key, value),
  );

  Widget _number(String key, int min, int max) => ListItem.input(
    title: Text(toolFieldLabel(context.appLocalizations, key)),
    dialogTitle: toolFieldLabel(context.appLocalizations, key),
    value: '${_options[key]}',
    keyboardType: TextInputType.number,
    validator: (text) {
      final value = int.tryParse(text ?? '');
      return value == null || value < min || value > max ? '$min – $max' : null;
    },
    onChanged: (text) {
      final value = int.tryParse(text ?? '');
      if (value != null) _set(key, value);
    },
  );

  Widget _toggle(String key) => ListItem.toggle(
    title: Text(toolFieldLabel(context.appLocalizations, key)),
    value: _options[key] == true,
    onChanged: (value) => _set(key, value),
  );

  Widget _textOption(String key) => ListItem.input(
    title: Text(toolFieldLabel(context.appLocalizations, key)),
    dialogTitle: toolFieldLabel(context.appLocalizations, key),
    value: '${_options[key] ?? ''}',
    onChanged: (text) {
      if (text != null) _set(key, text.trim());
    },
  );

  List<Widget> _settings() {
    final l = context.appLocalizations;
    final groups = ref.watch(groupsProvider);
    final outbounds = <Object>[
      '',
      'DIRECT',
      ...{
        for (final group in groups) group.name,
        for (final group in groups) ...group.all.map((p) => p.name),
      },
    ];
    return switch (widget.tool) {
      ToolboxTool.speed => [
        _choice('provider', ['apple', 'cloudflare', 'speedtest']),
        _choice('proxy', outbounds),
        _choice('protocol', ['h1', 'h2', 'h3']),
        _number('duration', 3, 30),
        _number('streams', 1, 16),
        _toggle('use-system-dns'),
        if (_options['provider'] == 'speedtest')
          ListItem(
            title: Text(l.speedTestServer),
            subtitle: Text(
              _options['server'] is Map
                  ? toolValue(_options['server'])
                  : l.speedTestServerAutoDesc,
            ),
            onTap: _busy ? null : _selectServer,
          ),
      ],
      ToolboxTool.route => [
        _choice('network', ['tcp', 'udp']),
        _number('port', 1, 65535),
      ],
      ToolboxTool.dns => [
        _choice('type', ['A', 'AAAA', 'CNAME', 'HTTPS', 'TXT', 'MX', 'NS']),
        _choice('mode', ['follow', 'system', 'custom']),
        _textOption('server'),
        _toggle('compare'),
      ],
      ToolboxTool.mrs => [_toggle('resolve')],
      ToolboxTool.nat => [_choice('proxy', outbounds)],
      ToolboxTool.ping => [
        _choice('protocol', ['icmp', 'tcp', 'udp']),
        _number('port', 1, 65535),
        _number('count', 1, 9999),
        _number('interval', 100, 10000),
        _number('size', 0, 65000),
      ],
      ToolboxTool.iperf => [
        _choice('role', ['client', 'server']),
        _number('port', 1, 65535),
        if (_options['role'] == 'client') ...[
          _choice('protocol', ['tcp', 'udp']),
          _choice('direction', ['upload', 'download', 'bidir']),
          _number('parallel', 1, 128),
          _number('duration', 1, 3600),
          _number('bandwidth', 1, 100000),
        ],
      ],
      ToolboxTool.traffic => [
        ListItem.toggle(
          title: Text(l.trafficStatsEnable),
          value: _options['enable'] == true,
          onChanged: (value) => _configureTraffic('enable', value),
        ),
        ListItem.toggle(
          title: Text(l.trafficStatsDetail),
          value: _options['detail'] == true,
          onChanged: (value) => _configureTraffic('detail', value),
        ),
        _choice('days', [1, 7, 30]),
        ListItem<int>.options(
          title: Text(l.trafficStatsRetention),
          options: const [1, 7, 14, 30],
          value: _options['retention-days'] as int,
          textBuilder: (v) => '$v d',
          onChanged: (v) => _configureTraffic('retention-days', v),
        ),
      ],
      _ => const [],
    };
  }

  Future<void> _configureTraffic(String key, Object value) async {
    final options = {..._options, key: value};
    try {
      await _client.call(CoreMethod.toolboxTrafficConfigure, {
        'options': {
          ...options,
          'tz-offset': DateTime.now().timeZoneOffset.inMinutes,
        },
        'profile': '${ref.read(currentProfileIdProvider) ?? ''}',
      });
      if (!mounted) return;
      setState(() => _options = options);
      await _save();
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    }
  }

  Future<void> _selectServer() async {
    final chosen = await BaseNavigator.push(
      context,
      _SpeedServerPage(client: _client, proxy: '${_options['proxy']}'),
    );
    if (mounted && chosen is Map<String, Object?>) _set('server', chosen);
  }

  Future<void> _showHistory() async {
    await BaseNavigator.push(
      context,
      ToolResultView(
        title: context.appLocalizations.speedTestHistory,
        value: _records,
      ),
    );
  }

  void _openBatch() {
    final groups = ref.read(groupsProvider);
    final groupNames = groups.map((group) => group.name).toSet();
    final nodes = {
      for (final group in groups)
        for (final proxy in group.all)
          if (!groupNames.contains(proxy.name) &&
              !['DIRECT', 'REJECT', 'PASS'].contains(proxy.name))
            proxy.name,
    }.toList();
    BaseNavigator.push(
      context,
      _BatchToolPage(
        tool: widget.tool,
        client: _client,
        options: {
          ..._options,
          if (widget.tool == ToolboxTool.nat) 'server': _target.text.trim(),
        },
        nodes: nodes,
      ),
    );
  }

  Future<void> _scanIperf() async {
    final link = await BaseNavigator.push(
      context,
      ScanPage(
        decode: (codes) => codes
            .whereType<String>()
            .where((code) => parseIperfLink(code) != null)
            .firstOrNull,
      ),
    );
    if (!mounted || link is! String) return;
    final target = parseIperfLink(link);
    if (target != null) {
      setState(() {
        _target.text = target.hosts.join(',');
        _options['port'] = target.port;
      });
    }
  }

  Future<void> _showServerLink() async {
    try {
      final hosts = [
        for (final interface in await NetworkInterface.list())
          ...interface.addresses.map((a) => a.address),
      ];
      final link = buildIperfLink(
        hosts: hosts,
        port: _options['port'] as int,
        name: 'FlClash',
      );
      if (!mounted) return;
      await BaseNavigator.push(
        context,
        ToolPageFrame(
          title: context.appLocalizations.iperfAddresses,
          children: [
            Center(child: QrCodeView(data: link)),
            const SizedBox(height: 16),
            SelectableText(link),
            for (final host in hosts)
              SelectableText('iperf3 -c $host -p ${_options['port']}'),
          ],
        ),
      );
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    }
  }

  Future<void> _clearTraffic() async {
    final l = context.appLocalizations;
    if (await dialogs.showMessage(
          context: context,
          title: l.trafficUsage,
          message: TextSpan(text: l.trafficStatsClearTip),
          destructive: true,
          confirmText: l.delete,
        ) !=
        true) {
      return;
    }
    try {
      await _client.call(CoreMethod.toolboxTrafficClear);
      if (mounted) setState(() => _result = null);
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    }
  }

  Future<void> _openMrs(Map<String, Object?> entry) async {
    try {
      final text = await _client.call(CoreMethod.toolboxMrsDump, {
        'path': entry['file'],
      });
      if (!mounted) return;
      await BaseNavigator.push(
        context,
        ToolResultView(title: '${entry['name']}', value: text),
      );
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final tool = widget.tool;
    final showTarget = ![ToolboxTool.speed].contains(tool);
    final result = _result;
    return ToolPageFrame(
      title: tool.title(l),
      actions: [
        toolCopyAction(context, result),
        if ([ToolboxTool.speed, ToolboxTool.nat].contains(tool))
          IconButtonData(
            glyph: AppGlyphs.proxies,
            tooltip: l.tbBatch,
            onPressed: _busy ? null : _openBatch,
          ),
        if (tool == ToolboxTool.iperf && system.isAndroid)
          IconButtonData(
            glyph: AppGlyphs.qrCode,
            tooltip: l.iperfScan,
            onPressed: _busy ? null : _scanIperf,
          ),
        if (tool == ToolboxTool.iperf && _serverRunning)
          IconButtonData(
            glyph: AppGlyphs.export,
            tooltip: l.iperfAddresses,
            onPressed: _showServerLink,
          ),
        if (tool == ToolboxTool.speed)
          IconButtonData(
            glyph: AppGlyphs.clock,
            tooltip: l.speedTestHistory,
            onPressed: _showHistory,
          ),
        if (tool == ToolboxTool.traffic)
          IconButtonData(
            glyph: AppGlyphs.delete,
            tooltip: l.delete,
            onPressed: _busy ? null : _clearTraffic,
          ),
      ],
      slivers: [
        if (result != null)
          ToolResultSliver(
            value: result,
            onEntry: tool == ToolboxTool.mrs ? _openMrs : null,
          ),
      ],
      children: [
        ToolMessage(tool.description(l)),
        if (showTarget)
          ToolField(
            label: tool == ToolboxTool.nat
                ? l.dnsQueryServer
                : tool == ToolboxTool.traffic
                ? l.tbHostFilter
                : l.routeTraceInput,
            controller: _target,
            hint: switch (tool) {
              ToolboxTool.nat => 'stun.cloudflare.com:3478',
              ToolboxTool.iperf => l.iperfAddressHint,
              ToolboxTool.traffic => l.tbOptional,
              _ => l.routeTraceHint,
            },
            onSubmitted: (_) => _run(),
          ),
        if (_history.isNotEmpty && showTarget)
          generateSection(
            items: [
              ListItem<String>.options(
                title: Text(l.tbRecentTargets),
                options: _history,
                value: _history.first,
                textBuilder: (v) => v,
                onChanged: (v) => setState(() => _target.text = v),
              ),
            ],
          ),
        IgnorePointer(
          ignoring: _busy || _serverRunning,
          child: generateSection(title: l.general, items: _settings()),
        ),
        if (tool == ToolboxTool.traffic) ToolMessage(l.trafficStatsDisabledTip),
        if (tool == ToolboxTool.iperf) ToolMessage(l.iperfServerTip),
        ToolRunButton(
          busy: _busy,
          onRun: _run,
          onCancel: toolCancelMethod(tool) == null ? null : _cancel,
          label: _serverRunning ? l.iperfServerStop : null,
        ),
        if (_error != null) ToolMessage(_error!, error: true),
        if (result != null) ListHeader(title: l.ageOutput),
      ],
    );
  }
}

class _BatchToolPage extends StatefulWidget {
  const _BatchToolPage({
    required this.tool,
    required this.client,
    required this.options,
    required this.nodes,
  });
  final ToolboxTool tool;
  final ToolboxClient client;
  final Map<String, Object?> options;
  final List<String> nodes;

  @override
  State<_BatchToolPage> createState() => _BatchToolPageState();
}

class _BatchToolPageState extends State<_BatchToolPage> {
  final _results = <String, Object?>{};
  bool _busy = false;
  bool _cancelled = false;
  String? _error;

  Future<void> _cancel() async {
    _cancelled = true;
    try {
      await widget.client.call(toolCancelMethod(widget.tool)!);
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    }
  }

  @override
  void dispose() {
    if (_busy) unawaited(_cancel());
    super.dispose();
  }

  Future<void> _run() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _cancelled = false;
      _results.clear();
      _error = null;
    });
    try {
      for (final node in widget.nodes) {
        if (_cancelled || !mounted) break;
        try {
          final result = await widget.client.query(toolRunMethod(widget.tool), {
            ...widget.options,
            'proxy': node,
          });
          if (mounted) setState(() => _results[node] = result);
        } catch (error) {
          if (mounted) setState(() => _results[node] = '$error');
        }
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => ToolPageFrame(
    title: context.appLocalizations.tbBatch,
    actions: [toolCopyAction(context, _results)],
    slivers: [ToolResultSliver(value: _results)],
    children: [
      ToolMessage('${_results.length} / ${widget.nodes.length}'),
      ToolRunButton(
        busy: _busy,
        onRun: widget.nodes.isEmpty ? null : _run,
        onCancel: _cancel,
      ),
      if (_error != null) ToolMessage(_error!, error: true),
    ],
  );
}

class _SpeedServerPage extends StatefulWidget {
  const _SpeedServerPage({required this.client, required this.proxy});
  final ToolboxClient client;
  final String proxy;

  @override
  State<_SpeedServerPage> createState() => _SpeedServerPageState();
}

class _SpeedServerPageState extends State<_SpeedServerPage> {
  final _search = TextEditingController();
  List<Map<String, Object?>> _servers = [];
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final result = await widget.client.call(CoreMethod.toolboxSpeedServers, {
        'proxy': widget.proxy,
        'search': _search.text.trim(),
      });
      if (mounted) {
        setState(
          () => _servers = [
            for (final row in result as List)
              Map<String, Object?>.from(row as Map),
          ],
        );
      }
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => ToolPageFrame(
    title: context.appLocalizations.speedTestServer,
    slivers: [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverList.builder(
          itemCount: _servers.length,
          itemBuilder: (context, index) {
            final server = _servers[index];
            return ListItem(
              title: Text('${server['sponsor']} · ${server['name']}'),
              subtitle: Text('${server['host']} · ${server['latency']} ms'),
              onTap: () => Navigator.of(context).pop(server),
            );
          },
        ),
      ),
    ],
    children: [
      ToolField(
        label: context.appLocalizations.search,
        controller: _search,
        onSubmitted: (_) => _load(),
      ),
      ToolRunButton(busy: _busy, onRun: _load),
      if (_error != null) ToolMessage(_error!, error: true),
      ListItem(
        title: Text(context.appLocalizations.speedTestServerAutoDesc),
        onTap: () => Navigator.of(context).pop(<String, Object?>{}),
      ),
    ],
  );
}
