import 'dart:convert';

import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/method.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef ToolboxInvoker =
    Future<Object?> Function(CoreMethod method, Map<String, Object?> arguments);

class ToolboxClient {
  ToolboxClient({ToolboxInvoker? invoke}) : _invoke = invoke ?? _callCore;

  final ToolboxInvoker _invoke;

  static Future<Object?> _callCore(
    CoreMethod method,
    Map<String, Object?> arguments,
  ) => coreController.invokeMethod(
    method: method,
    arguments: arguments,
    timeout: Duration(
      seconds: switch (method) {
        CoreMethod.toolboxIperfStart =>
          ((arguments['duration'] as num?)?.toInt() ?? 10).clamp(1, 3600) + 60,
        CoreMethod.toolboxPingStart =>
          ((arguments['count'] as num?)?.toInt() ?? 20).clamp(1, 9999) *
                  ((arguments['interval'] as num?)?.toInt() ?? 1000).clamp(
                    100,
                    10000,
                  ) ~/
                  1000 +
              60,
        _ => 360,
      },
    ),
  );

  Future<Object?> call(
    CoreMethod method, [
    Map<String, Object?> arguments = const {},
  ]) => _invoke(method, arguments);

  Future<Map<String, Object?>> query(
    CoreMethod method, [
    Map<String, Object?> arguments = const {},
  ]) async {
    final value = await call(method, arguments);
    if (value is! Map) throw const FormatException('Invalid toolbox response');
    return Map<String, Object?>.from(value);
  }
}

class ToolboxStore {
  static const _prefix = 'toolbox_v1_';

  Future<Map<String, Object?>> load(String key) async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString('$_prefix$key');
    if (raw == null) return {};
    try {
      return Map<String, Object?>.from(jsonDecode(raw) as Map);
    } on FormatException {
      return {};
    } on TypeError {
      return {};
    }
  }

  Future<void> save(String key, Map<String, Object?> value) async {
    final preferences = await SharedPreferences.getInstance();
    if (!await preferences.setString('$_prefix$key', jsonEncode(value))) {
      throw StateError('Unable to save toolbox settings');
    }
  }
}

final toolboxClient = ToolboxClient();
final toolboxStore = ToolboxStore();
