import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/features/toolbox/catalog.dart';
import 'package:fl_clash/features/toolbox/client.dart';
import 'package:fl_clash/features/toolbox/diagnostics.dart';
import 'package:fl_clash/views/toolbox.dart';
import 'package:fl_clash/views/tools.dart';
import 'package:fl_clash/views/navigation.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_app.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('catalog has only the ten requested tools', () {
    expect(ToolboxTool.values, hasLength(10));
    expect(
      ToolboxTool.values.map((t) => t.name),
      isNot(contains('connectivity')),
    );
  });

  testWidgets('the sole toolbox entry is between resources and logs', (
    tester,
  ) async {
    final items = Navigation()
        .getItems(openLogs: true)
        .where(
          (item) =>
              item.label == PageLabel.resources || item.label == PageLabel.logs,
        )
        .toList();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          moreToolsSelectorStateProvider.overrideWithValue(
            MoreToolsSelectorState(navigationItems: items),
          ),
        ],
        child: const TestApp(child: ToolsView()),
      ),
    );
    await tester.pumpAndSettle();
    final l = tester.element(find.byType(ToolsView)).appLocalizations;
    expect(find.text(l.toolbox), findsOneWidget);
    expect(
      tester.getTopLeft(find.text(l.resources)).dy,
      lessThan(tester.getTopLeft(find.text(l.toolbox)).dy),
    );
    expect(
      tester.getTopLeft(find.text(l.toolbox)).dy,
      lessThan(tester.getTopLeft(find.text(l.logs)).dy),
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });

  for (final width in [360.0, 1200.0]) {
    testWidgets('toolbox list fits width $width', (tester) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        const ProviderScope(child: TestApp(child: ToolboxView())),
      );
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(ToolboxView));
      expect(find.text(context.appLocalizations.toolbox), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  test('query rejects an invalid core response', () async {
    final client = ToolboxClient(invoke: (_, _) async => 'invalid');
    await expectLater(
      client.query(toolRunMethod(ToolboxTool.route)),
      throwsFormatException,
    );
  });

  for (final tool in ToolboxTool.values.where(
    (tool) => tool != ToolboxTool.age && tool != ToolboxTool.ip,
  )) {
    testWidgets('${tool.name} renders its controls without a live core', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: TestApp(
            child: DiagnosticToolPage(
              tool: tool,
              client: ToolboxClient(
                invoke: (_, _) async => <String, Object?>{},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
