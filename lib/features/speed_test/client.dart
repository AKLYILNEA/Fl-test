import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/api/core_api.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class SpeedTestClient {
  Stream<SpeedTestState> get updates;
  Future<SpeedTestState> probe(
    SpeedTestSettings settings,
    String proxy,
    String id,
  );
  Future<SpeedTestState> start(
    SpeedTestSettings settings,
    String proxy,
    String id,
  );
  Future<void> cancel(String id);
  Future<List<SpeedTestNode>> servers(String proxy, String search, String id);
}

class _CoreSpeedTestClient implements SpeedTestClient {
  _CoreSpeedTestClient(this.core);
  final CoreApi core;
  String? _activeId;
  bool _disposed = false;
  final _updates = StreamController<SpeedTestState>.broadcast();

  @override
  Stream<SpeedTestState> get updates => _updates.stream;

  @override
  Future<SpeedTestState> probe(
    SpeedTestSettings settings,
    String proxy,
    String id,
  ) => core.probeSpeedTest(settings, proxy, id);
  @override
  Future<SpeedTestState> start(
    SpeedTestSettings settings,
    String proxy,
    String id,
  ) async {
    var state = await core.startSpeedTest(settings, proxy, id);
    if (_disposed) {
      await cancel(id);
      return state;
    }
    _activeId = id;
    try {
      while (!_disposed &&
          _activeId == id &&
          state.phase != SpeedTestPhase.done) {
        await Future<void>.delayed(const Duration(milliseconds: 200));
        if (_disposed || _activeId != id) break;
        state = await core.speedTestStatus(id);
        if (!_disposed && _activeId == id) _updates.add(state);
      }
      return state;
    } finally {
      if (_activeId == id) _activeId = null;
    }
  }

  @override
  Future<List<SpeedTestNode>> servers(String proxy, String search, String id) =>
      core.speedTestServers(proxy, search, id);
  @override
  Future<void> cancel(String id) async {
    try {
      await core.cancelSpeedTest(id);
    } catch (error) {
      commonPrint.log('Cancel speed test: $error');
    }
  }

  void dispose() {
    _disposed = true;
    if (_activeId case final id?) unawaited(cancel(id));
    unawaited(_updates.close());
  }
}

final speedTestClientProvider = Provider.autoDispose<SpeedTestClient>((ref) {
  final client = _CoreSpeedTestClient(ref.watch(coreHandlerProvider).api);
  ref.onDispose(client.dispose);
  return client;
});
