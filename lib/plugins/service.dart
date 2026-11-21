import 'dart:async';
import 'dart:convert';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/event.dart';
import 'package:fl_clash/core/method.dart';
import 'package:fl_clash/core/spill.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

final _utf8JsonDecoder = utf8.decoder.fuse(json.decoder);

Object? _decodeUtf8Json(Uint8List data) => _utf8JsonDecoder.convert(data);

Map<String, Object?> _decodeResponseOf((Uint8List, CoreResultModel?) request) {
  final (data, model) = request;
  final decoded = _decodeUtf8Json(data);
  return withResultModel(model, Map<String, Object?>.from(decoded as Map));
}

Future<Map<String, Object?>> _decodeResponse(
  Uint8List data,
  CoreResultModel? model,
) async {
  if (data.length < coreIsolateDecodeBytes) {
    return _decodeResponseOf((data, model));
  }
  return compute(_decodeResponseOf, (data, model));
}

abstract mixin class ServiceListener {
  void onServiceEvent(CoreEvent event) {}

  void onServiceStopped([ServiceStartFailure? failure]) {}

  void onServiceTrace(String line) {}
}

typedef AndroidServiceRun = ({DateTime startedAt, VpnOptions options});

class Service {
  static Service? _instance;
  late MethodChannel methodChannel;
  static const _coreChannel = MethodChannel('$packageName/core');

  final ObserverList<ServiceListener> _listeners =
      ObserverList<ServiceListener>();

  int _commandRevision = 0;
  int _stopReportCount = 0;
  bool _startRequested = false;

  factory Service() {
    _instance ??= Service._internal();
    return _instance!;
  }

  Service._internal() {
    methodChannel = const MethodChannel('$packageName/service');
    methodChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'event':
          final methodCall = CoreMethodCall.fromJson(
            Map<String, Object?>.from(
              _decodeUtf8Json(call.arguments as Uint8List) as Map,
            ),
          );
          for (final event in coreEventsFromData(methodCall.arguments)) {
            _dispatch(
              'Core event ${event.type.name}',
              (listener) => listener.onServiceEvent(event),
            );
          }
          break;
        case 'stopped':
          final report = call.arguments as Map<Object?, Object?>;
          final reportRev = report['revision'];
          final reportFailure = report['failure'];
          // A report stamped before the newest command no longer describes it.
          if (reportRev != _commandRevision) {
            vpnTrace.record(
              'service.stopped_report',
              fields: {
                'decision': 'drop_stale_rev',
                'reportRev': reportRev,
                'localRev': _commandRevision,
                'startRequested': _startRequested,
                'failure': reportFailure,
              },
            );
            break;
          }
          _stopReportCount++;
          if (!_startRequested) {
            vpnTrace.record(
              'service.stopped_report',
              fields: {
                'decision': 'drop_not_start_requested',
                'reportRev': reportRev,
                'localRev': _commandRevision,
                'failure': reportFailure,
              },
            );
            break;
          }
          final stopReport = _stopReportCount;
          // Native starts can advance without a new Flutter revision.
          final runRequested = await methodChannel.invokeMethod<bool>(
            'isRunRequested',
          );
          if (runRequested != false ||
              reportRev != _commandRevision ||
              stopReport != _stopReportCount) {
            vpnTrace.record(
              'service.stopped_report',
              fields: {
                'decision': 'drop_superseded',
                'reportRev': reportRev,
                'localRev': _commandRevision,
                'runRequested': runRequested,
                'stopReportMatch': stopReport == _stopReportCount,
                'failure': reportFailure,
              },
            );
            break;
          }
          _startRequested = false;
          final failure = ServiceStartFailure.fromCode(reportFailure);
          vpnTrace.record(
            'service.stopped_report',
            fields: {
              'decision': 'dispatch',
              'reportRev': reportRev,
              'localRev': _commandRevision,
              'runRequested': runRequested,
              'failure': failure?.name ?? reportFailure,
            },
          );
          _dispatch(
            'stop report',
            (listener) => listener.onServiceStopped(failure),
          );
          break;
        case 'trace':
          final line = call.arguments as String?;
          if (line != null && line.isNotEmpty) {
            vpnTrace.recordNative(line);
            _dispatch(
              'service trace',
              (listener) => listener.onServiceTrace(line),
            );
          }
          break;
        default:
          throw MissingPluginException();
      }
    });
  }

  Future<CoreMethodResponse> invokeMethod(
    CoreMethodCall call, {
    CoreResultModel? model,
  }) async {
    model ??= coreResultModelOf(call.method);
    final data = await _coreChannel.invokeMethod<Uint8List>(
      'invokeMethod',
      json.encode(call),
    );
    if (data == null) {
      throw CoreMethodException(
        code: 'no_response',
        message: 'Core did not answer ${call.method.wireName}',
      );
    }
    return resolveSpilledResponse(
      CoreMethodResponse.fromJson(await _decodeResponse(data, model)),
      model: model,
    );
  }

  void _dispatch(String label, void Function(ServiceListener) deliver) {
    for (final listener in List.of(_listeners)) {
      try {
        deliver(listener);
      } catch (error) {
        commonPrint.log(
          'Unable to dispatch Android $label: $error',
          logLevel: LogLevel.error,
        );
      }
    }
  }

  Future<bool> start() async {
    _startRequested = true;
    final rev = ++_commandRevision;
    vpnTrace.record('service.start', fields: {'rev': rev});
    final res = await methodChannel.invokeMethod<bool>('start', rev) ?? false;
    vpnTrace.record(
      'service.start.result',
      fields: {'rev': rev, 'result': res},
    );
    return res;
  }

  Future<bool> stop() async {
    _startRequested = false;
    final rev = ++_commandRevision;
    vpnTrace.record(
      'service.stop',
      fields: {'rev': rev},
      stack: StackTrace.current,
    );
    final res = await methodChannel.invokeMethod<bool>('stop', rev) ?? false;
    vpnTrace.record(
      'service.stop.result',
      fields: {'rev': rev, 'result': res},
    );
    return res;
  }

  Future<String> init() async {
    return await methodChannel.invokeMethod<String>('init') ?? '';
  }

  Future<String> syncState(SharedState state) async {
    return await methodChannel.invokeMethod<String>(
          'syncState',
          json.encode(state),
        ) ??
        '';
  }

  Future<bool> shutdown() async {
    return await methodChannel.invokeMethod<bool>('shutdown') ?? true;
  }

  Future<AndroidServiceRun?> adoptRunningService() async {
    final revision = _commandRevision;
    final stopReports = _stopReportCount;
    final run = await methodChannel.invokeMapMethod<String, Object?>(
      'getRunningService',
    );
    if (run == null ||
        revision != _commandRevision ||
        stopReports != _stopReportCount) {
      vpnTrace.record(
        'service.adopt',
        fields: {
          'adopted': false,
          'hasRun': run != null,
          'revMatch': revision == _commandRevision,
          'stopMatch': stopReports == _stopReportCount,
        },
      );
      return null;
    }
    final startedAt = DateTime.fromMillisecondsSinceEpoch(
      run['startedAt']! as int,
    );
    final options = VpnOptions.fromJson(
      json.decode(run['options']! as String) as Map<String, Object?>,
    );
    _startRequested = true;
    vpnTrace.record(
      'service.adopt',
      fields: {
        'adopted': true,
        'startedAt': startedAt.millisecondsSinceEpoch,
        'vpnEnable': options.enable,
      },
    );
    return (startedAt: startedAt, options: options);
  }

  bool get hasListeners {
    return _listeners.isNotEmpty;
  }

  void addListener(ServiceListener listener) {
    _listeners.add(listener);
  }

  void removeListener(ServiceListener listener) {
    _listeners.remove(listener);
  }
}

Service? get service => system.isAndroid ? Service() : null;
