import 'dart:convert';
import 'dart:typed_data';

import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/manager/app_manager.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/icon.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_database_providers.dart';

class _TestIconRules extends IconRulesNotifier {
  @override
  List<IconRule> build() => const [];

  void replace(List<IconRule> rules) => state = rules;
}

void main() {
  testWidgets(
    'warm proxy icons start restoring before a foreground animation ends',
    (tester) async {
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      final animation = AnimationController(
        vsync: tester,
        duration: const Duration(milliseconds: 300),
      );
      addTearDown(animation.dispose);

      const src = 'https://example.com/cached-on-resume.svg';
      final bytes = Uint8List.fromList(
        utf8.encode(
          '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16">'
          '<rect width="16" height="16" fill="blue"/></svg>',
        ),
      );
      var reads = 0;
      readRemoteIcon = (_) {
        reads++;
        return Stream.value(bytes);
      };
      addTearDown(() => readRemoteIcon = null);
      await tester.runAsync(() => precacheTargetIcons([src]));
      expect(reads, 1);

      final container = ProviderContainer(
        overrides: [
          safeModeProvider.overrideWithValue(true),
          iconSetsProvider.overrideWith(TestIconSets.new),
          iconRulesProvider.overrideWith(_TestIconRules.new),
        ],
      );
      addTearDown(container.dispose);
      container.read(groupsProvider.notifier).value = const [
        Group(name: 'Group', type: GroupType.Selector, icon: src),
      ];

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const AppStateManager(child: SizedBox.shrink()),
        ),
      );
      await tester.pumpAndSettle();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      container.read(groupsProvider.notifier).value = const [
        Group(name: 'Updated group', type: GroupType.Selector, icon: src),
      ];
      imageCache.clear();
      imageCache.clearLiveImages();
      expect(imageCache.currentSize, 0);

      animation.forward();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      expect(animation.isAnimating, isTrue);
      expect(imageCache.pendingImageCount + imageCache.currentSize, 1);
      expect(reads, 1);

      animation.stop();
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('proxy icons warm the latest sources after foreground motion', (
    tester,
  ) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    final animation = AnimationController(
      vsync: tester,
      duration: const Duration(milliseconds: 300),
    );
    addTearDown(animation.dispose);

    final reads = <String>[];
    readRemoteIcon = (src) {
      reads.add(src);
      return const Stream<Uint8List>.empty();
    };
    addTearDown(() => readRemoteIcon = null);

    final rules = _TestIconRules();
    final container = ProviderContainer(
      overrides: [
        safeModeProvider.overrideWithValue(true),
        iconSetsProvider.overrideWith(TestIconSets.new),
        iconRulesProvider.overrideWith(() => rules),
      ],
    );
    addTearDown(container.dispose);
    final groups = container.read(groupsProvider.notifier);
    groups.value = const [
      Group(
        name: 'Group',
        type: GroupType.Selector,
        icon: 'https://example.com/stale.svg',
      ),
    ];

    animation.forward();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const AppStateManager(child: SizedBox.shrink()),
      ),
    );
    expect(reads, isEmpty);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    final sources = [
      for (var index = 0; index < 6; index++)
        'https://example.com/latest-$index.svg',
    ];
    rules.replace([IconRule(id: 1, pattern: '^Group', icon: sources.first)]);
    groups.value = [
      const Group(
        name: 'Group with override',
        type: GroupType.Selector,
        icon: 'https://example.com/overridden.svg',
      ),
      for (final src in sources.skip(1))
        Group(name: src, type: GroupType.Selector, icon: src),
    ];
    expect(reads, isEmpty);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump(const Duration(milliseconds: 32));
    expect(animation.isAnimating, isTrue);
    expect(reads, isEmpty);

    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 16));
    expect(reads, hasLength(4));
    await tester.pumpAndSettle();
    expect(reads, unorderedEquals(sources));

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
