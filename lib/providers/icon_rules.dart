import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'database.dart';

final _patternWords = RegExp('[A-Za-z0-9]{3,}');

/// Gives the groups whose name matches [pattern] an icon out of the icon set
/// [iconSetId], the way bettbox maps a regular expression to an icon.
class IconRule {
  IconRule({required this.pattern, required this.iconSetId})
    : regExp = _compile(pattern);

  factory IconRule.fromJson(Map<String, Object?> json) {
    return IconRule(
      pattern: json['pattern'] as String? ?? '',
      iconSetId: (json['iconSetId'] as num?)?.toInt() ?? -1,
    );
  }

  final String pattern;
  final int iconSetId;

  /// Null when [pattern] is not a valid regular expression.
  final RegExp? regExp;

  static RegExp? _compile(String pattern) {
    try {
      return RegExp(pattern, caseSensitive: false);
    } catch (_) {
      return null;
    }
  }

  Map<String, Object?> toJson() => {'pattern': pattern, 'iconSetId': iconSetId};

  /// The icon of [iconSet] that suits the group [name]: matched against the
  /// name, then against the part the regex matched, then against the words of
  /// the pattern itself, since a name in Chinese matches no icon by itself.
  String? iconFor(String name, IconSet iconSet) {
    final regExp = this.regExp;
    if (regExp == null || pattern.isEmpty) {
      return null;
    }
    final match = regExp.firstMatch(name);
    if (match == null) {
      return null;
    }
    final targets = <String>[
      name,
      ?match.group(0),
      for (final word in _patternWords.allMatches(pattern)) word.group(0)!,
    ];
    for (final target in targets) {
      if (target.isEmpty) {
        continue;
      }
      final ranked = rankIconMatches(iconSet.icons.scoreFor(target), limit: 1);
      if (ranked.isNotEmpty) {
        return ranked.first.url;
      }
    }
    return null;
  }

  IconRule copyWith({String? pattern, int? iconSetId}) => IconRule(
    pattern: pattern ?? this.pattern,
    iconSetId: iconSetId ?? this.iconSetId,
  );

  @override
  bool operator ==(Object other) =>
      other is IconRule &&
      other.pattern == pattern &&
      other.iconSetId == iconSetId;

  @override
  int get hashCode => Object.hash(pattern, iconSetId);
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
  final iconSets = ref.watch(iconSetsProvider).value ?? const <IconSet>[];
  for (final rule in rules) {
    final iconSet = iconSets.firstWhereOrNull(
      (item) => item.id == rule.iconSetId,
    );
    if (iconSet == null) {
      continue;
    }
    final icon = rule.iconFor(name, iconSet);
    if (icon != null) {
      return icon;
    }
  }
  return configured;
});
