import 'dart:convert';

import 'package:fl_clash/core/method.dart';

import 'client.dart';

class ToolProxyLease {
  ToolProxyLease._(this._client, this.route);

  final ToolboxClient _client;
  final String route;
  bool _released = false;
  static int _users = 0;
  static Future<int>? _opening;
  static Future<void>? _closing;

  static Future<ToolProxyLease> acquire(
    ToolboxClient client,
    String outbound,
  ) async {
    if (_closing case final closing?) await closing;
    _users++;
    try {
      final port = await (_opening ??= client
          .call(CoreMethod.toolboxProxyStart)
          .then((value) {
            if (value is! int || value <= 0) {
              throw StateError('Unable to open tool proxy');
            }
            return value;
          }));
      final user = utf8
          .encode(outbound)
          .map((v) => v.toRadixString(16).padLeft(2, '0'))
          .join();
      return ToolProxyLease._(client, 'PROXY $user:x@127.0.0.1:$port');
    } catch (_) {
      if (--_users == 0) _opening = null;
      rethrow;
    }
  }

  Future<void> release() async {
    if (_released) return;
    _released = true;
    if (--_users > 0) return;
    _opening = null;
    try {
      await (_closing = _client.call(CoreMethod.toolboxProxyStop).then((_) {}));
    } finally {
      _closing = null;
    }
  }
}
