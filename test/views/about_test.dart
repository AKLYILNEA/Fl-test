import 'package:fl_clash/common/constant.dart';
import 'package:fl_clash/features/about/miuix_bg_effect.dart';
import 'package:fl_clash/features/about/miuix_frosted_card.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/about.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

void main() {
  setUpAll(() {
    globalState.packageInfo = PackageInfo(
      appName: appName,
      packageName: 'com.follow.clash',
      version: '0.9.3',
      buildNumber: '1',
    );
  });

  ProviderContainer containerFor(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final container = ProviderContainer(
      overrides: [profilesProvider.overrideWith(TestProfiles.new)],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(viewSizeProvider.notifier).update((_) => size);
    return container;
  }

  testWidgets(
    'miuix about page renders flowing backdrop, chromatic title, frosted cards, and scroll collapse',
    (tester) async {
      final container = containerFor(tester, const Size(430, 480));
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const TestApp(
            locale: Locale('en'),
            child: AboutView(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(MiuixAboutBackdrop), findsOneWidget);
      expect(find.byType(MiuixChromaticTitle), findsOneWidget);
      expect(find.text(appName), findsOneWidget);
      expect(find.text('v0.9.3'), findsOneWidget);
      expect(find.text('GPL-3.0'), findsOneWidget);
      expect(find.byType(MiuixFrostedSection), findsNWidgets(2));
      expect(find.text('aaANDkk'), findsOneWidget);
      expect(find.text('Telegram'), findsOneWidget);

      final barOpacityBefore = tester.widget<Opacity>(
        find
            .ancestor(
              of: find.text('About'),
              matching: find.byType(Opacity),
            )
            .first,
      );
      expect(barOpacityBefore.opacity, 0.0);

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();

      final barOpacityAfter = tester.widget<Opacity>(
        find
            .ancestor(
              of: find.text('About'),
              matching: find.byType(Opacity),
            )
            .first,
      );
      expect(barOpacityAfter.opacity, greaterThan(0.5));
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    },
  );

  testWidgets('about hero app icon 5-tap enables developer mode', (tester) async {
    final container = containerFor(tester, const Size(900, 700));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(
          locale: Locale('en'),
          child: AboutView(dynamicBackground: false),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(container.read(appSettingProvider).developerMode, isFalse);
    final icon = find.byType(Image);
    for (var i = 0; i < 5; i++) {
      await tester.tap(icon);
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(container.read(appSettingProvider).developerMode, isTrue);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
