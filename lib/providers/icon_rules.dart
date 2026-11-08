import 'dart:async';
import 'dart:convert';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

/// Gives the groups whose name matches [pattern] the icon [icon], the way
/// bettbox maps a regular expression to an icon. [icon] is an image address as
/// the icon picker returns it, from an icon set or a link.
class IconRule {
  IconRule({required this.pattern, required this.icon})
    : regExp = _compile(pattern);

  factory IconRule.fromJson(Map<String, Object?> json) {
    return IconRule(
      pattern: json['pattern'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
    );
  }

  final String pattern;
  final String icon;

  /// Null when [pattern] is not a valid regular expression.
  final RegExp? regExp;

  static RegExp? _compile(String pattern) {
    try {
      return RegExp(pattern, caseSensitive: false);
    } catch (_) {
      return null;
    }
  }

  Map<String, Object?> toJson() => {'pattern': pattern, 'icon': icon};

  bool matches(String name) =>
      icon.isNotEmpty && (regExp?.hasMatch(name) ?? false);

  @override
  bool operator ==(Object other) =>
      other is IconRule && other.pattern == pattern && other.icon == icon;

  @override
  int get hashCode => Object.hash(pattern, icon);
}
/// The regex icon rules of the proxies page, in the order they are tried. They
/// outlive the process in the preferences.
class IconRulesNotifier extends Notifier<List<IconRule>> {
  @override
  List<IconRule> build() {
    unawaited(_restore());
    return const [];
  }

  Future<void> _restore() async {
    try {
      final raw = await preferences.getIconRules();
      if (raw == null || raw.isEmpty) {
        return;
      }
      final items = json.decode(raw);
      if (items is! List) {
        return;
      }
      state = [
        for (final item in items)
          if (item is Map) IconRule.fromJson(Map<String, Object?>.from(item)),
      ];
    } catch (error) {
      commonPrint.log('restore icon rules error $error');
    }
  }

  void update(List<IconRule> rules) {
    state = List.unmodifiable(rules);
    unawaited(
      preferences.setIconRules(
        json.encode([for (final rule in rules) rule.toJson()]),
      ),
    );
  }
}

final iconRulesProvider = NotifierProvider<IconRulesNotifier, List<IconRule>>(
  IconRulesNotifier.new,
);

/// The icon shown for the group [groupName]: the one a rule picks, else the one
/// the profile configured for it, else none.
final proxyGroupIconProvider = Provider.family<String, String>((ref, name) {
  final configured = ref.watch(
    groupsProvider.select((state) => state.getGroup(name)?.icon ?? ''),
  );
  final rules = ref.watch(iconRulesProvider);
  if (rules.isEmpty || name.isEmpty) {
    return configured;
  }
  for (final rule in rules) {
    if (rule.matches(name)) {
      return rule.icon;
    }
  }
  return configured;
});
