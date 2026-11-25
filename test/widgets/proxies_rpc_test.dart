import 'package:fl_clash/core/core.dart';
import 'package:fl_clash/core/api/rpc_core_api.dart';
import 'package:fl_clash/core/api/core_client.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/proxies/card.dart';
import 'package:fl_clash/views/proxies/proxies.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../core/api/fake_channel.dart';
import '../helpers/core_mocks.dart';
import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

Map<String, Object?> _groups(String member) => {
  'order': ['Example group'],
  'groups': [
    {
      'name': 'Example group',
      'type': 'Selector',
      'now': member,
      'all': [member],
      'testUrl': '',
      'hidden': false,
      'icon': '',
      'emptyFallback': 'DIRECT',
    },
  ],
  'nodes': [
    {'name': member, 'type': 'Shadowsocks'},
  ],
};

void main() {
  for (final style in ProxiesType.values) {
    testWidgets('Concord proxy.groups renders nodes in ${style.name} mode', (
      tester,
    ) async {
      final channel = FakeFrameChannel()..connect();
      final client = (await tester.runAsync(
        () async => CoreClient(channel, debug: true),
      ))!;
      addTearDown(() async {
        await client.close();
        await channel.close();
      });
      channel.sentListener = (message) {
        switch (message['method']) {
          case 'core.hello':
            channel.answer(message['id'], helloBody);
          case 'proxy.groups':
            channel.answer(message['id'], _groups('Loaded node'));
        }
      };
      final backend = MockCoreBackend();
      when(() => backend.api).thenReturn(RpcCoreApi(client));
      final profile = Profile.normal().copyWith(
        currentGroupName: 'Example group',
        unfoldSet: {'Example group'},
      );
      final container = ProviderContainer(
        overrides: [
          coreHandlerProvider.overrideWithValue(CoreController.scoped(backend)),
          profilesProvider.overrideWith(() => TestProfiles([profile])),
          currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
          proxiesStyleSettingProvider.overrideWithBuild(
            (_, _) => ProxiesStyleProps(type: style),
          ),
        ],
      );
      globalState.container = container;
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const TestApp(child: ProxiesView()),
        ),
      );
      await tester.runAsync(
        () => container.read(proxiesActionProvider.notifier).updateGroups(),
      );
      await tester.pumpAndSettle();
      expect(channel.calls('proxy.groups'), hasLength(1));
      expect(
        find.byWidgetPredicate(
          (widget) => widget is ProxyCard && widget.proxy.name == 'Loaded node',
        ),
        findsOneWidget,
      );
    });
  }
}
