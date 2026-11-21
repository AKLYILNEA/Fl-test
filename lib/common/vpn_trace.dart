import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/foundation.dart';

class VpnTrace {
  static const _maxEntries = 200;

  final List<({String payload, LogLevel level})> _entries = [];

  void record(
    String event, {
    Map<String, Object?> fields = const {},
    StackTrace? stack,
    LogLevel level = LogLevel.warning,
  }) {
    final now = DateTime.now();
    final ts =
        '${_pad2(now.hour)}:${_pad2(now.minute)}:${_pad2(now.second)}.${_pad3(now.millisecond)}';
    final parts = <String>['[VPN-TRACE][DART] $ts', event];
    if (fields.isNotEmpty) {
      parts.add(
        fields.entries.map((entry) => '${entry.key}=${entry.value}').join(', '),
      );
    }
    if (stack != null) {
      final compact = _compactStack(stack);
      if (compact.isNotEmpty) {
        parts.add('stack=$compact');
      }
    }
    _append(parts.join(' | '), level: level);
  }

  void recordNative(String line) {
    _append(line, level: LogLevel.warning);
  }

  void flushToLogs({bool all = false}) {
    if (!globalState.isAttach || _entries.isEmpty) {
      return;
    }
    try {
      final notifier = globalState.container.read(logsProvider.notifier);
      final existing = all
          ? globalState.container
                .read(logsProvider)
                .list
                .map((item) => item.payload)
                .toSet()
          : const <String>{};
      for (final entry in _entries) {
        if (all && existing.contains(entry.payload)) {
          continue;
        }
        notifier.add(Log.app(entry.payload).copyWith(logLevel: entry.level));
      }
    } catch (_) {}
  }

  void _append(String payload, {required LogLevel level}) {
    debugPrint(payload);
    if (_entries.length >= _maxEntries) {
      _entries.removeAt(0);
    }
    _entries.add((payload: payload, level: level));
    if (!globalState.isAttach) {
      return;
    }
    try {
      globalState.container
          .read(logsProvider.notifier)
          .add(Log.app(payload).copyWith(logLevel: level));
    } catch (_) {}
  }

  String _compactStack(StackTrace stack) {
    final frames = <String>[];
    for (final rawLine in stack.toString().split('\n')) {
      final line = rawLine.trim();
      if (line.isEmpty || line.contains('vpn_trace.dart')) {
        continue;
      }
      if (line.contains('package:fl_clash/') ||
          line.contains('package:prism_ui/')) {
        final compact = line.replaceFirst(RegExp(r'^#\d+\s+'), '');
        frames.add(compact);
        if (frames.length >= 6) {
          break;
        }
      }
    }
    return frames.join(' <- ');
  }

  String _pad2(int value) => value.toString().padLeft(2, '0');

  String _pad3(int value) => value.toString().padLeft(3, '0');
}

final vpnTrace = VpnTrace();
