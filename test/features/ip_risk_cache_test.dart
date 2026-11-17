import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fl_clash/features/ip_quality/risk_model.dart';
import 'package:fl_clash/features/ip_quality/risk_provider.dart';
import 'package:flutter_test/flutter_test.dart';

const risk = IpRisk(
  ip: '1.2.3.4',
  score: 28,
  level: IpRiskLevel.medium,
  hostname: 'example.com',
  asn: 'AS123',
  isp: 'Example ISP',
  organization: 'Example',
  country: 'Japan',
  countryCode: 'JP',
  region: 'Tokyo',
  city: 'Tokyo',
  checks: [
    IpRiskCheck(group: IpRiskGroup.datacenter, name: 'Datacenter', hit: true),
    IpRiskCheck(group: IpRiskGroup.proxy, name: 'Tor'),
  ],
  note: IpRiskNote(
    direct: false,
    isp: 'Example ISP',
    amount: IpRiskAmount.high,
    share: IpRiskShare.some,
    operatorName: 'Operator',
    operatorLevel: IpRiskLevel.low,
    ownerName: 'Owner',
    ownerLevel: IpRiskLevel.high,
    connection: IpRiskConnection.vpn,
    warning: IpRiskLevel.veryHigh,
  ),
);

void main() {
  test('complete result survives JSON persistence including unknown flags', () {
    final restored = IpRisk.fromJson(jsonDecode(jsonEncode(risk.toJson())));
    expect(restored.toJson(), risk.toJson());
    expect(restored.checks.last.hit, isNull);
    const empty = IpRisk(ip: '1.1.1.1', score: 0, level: IpRiskLevel.low);
    expect(IpRisk.fromJson(empty.toJson()).toJson(), empty.toJson());
  });

  test(
    'cache survives repository recreation and manual refresh bypasses it',
    () async {
      Map<String, dynamic>? disk;
      var queries = 0;
      IpRiskRepository repository() => IpRiskRepository(
        read: (_) async => disk,
        write: (_, data) async => disk = data,
        fetch: (_, _) async {
          queries++;
          return risk.copyWith(score: queries);
        },
      );
      final first = repository();
      expect((await first.load(risk.ip, CancelToken())).score, 1);
      final reopened = repository();
      expect((await reopened.load(risk.ip, CancelToken())).score, 1);
      expect(queries, 1);
      reopened.forceNextQuery(risk.ip);
      expect((await reopened.load(risk.ip, CancelToken())).score, 2);
      expect(queries, 2);
      expect((await repository().load(risk.ip, CancelToken())).score, 2);
    },
  );

  test('corrupt or mismatched cache falls back to network', () async {
    for (final data in <Map<String, dynamic>>[
      {},
      {...risk.toJson(), 'ip': '8.8.8.8'},
    ]) {
      var queried = false;
      final repository = IpRiskRepository(
        read: (_) async => data,
        write: (_, _) async {},
        fetch: (_, _) async {
          queried = true;
          return risk;
        },
      );
      expect(await repository.load(risk.ip, CancelToken()), risk);
      expect(queried, isTrue);
    }
  });

  test('unavailable storage does not block a successful query', () async {
    final repository = IpRiskRepository(
      read: (_) async => throw StateError('unavailable'),
      write: (_, _) async => throw StateError('disk full'),
      fetch: (_, _) async => risk,
    );
    expect(await repository.load(risk.ip, CancelToken()), risk);
  });

  test(
    'failed force refresh does not overwrite the last good result',
    () async {
      var writes = 0;
      final repository = IpRiskRepository(
        read: (_) async => risk.toJson(),
        write: (_, _) async {
          writes++;
        },
        fetch: (_, _) async => throw StateError('offline'),
      );
      repository.forceNextQuery(risk.ip);
      await expectLater(
        repository.load(risk.ip, CancelToken()),
        throwsStateError,
      );
      expect(writes, 0);
      expect((await repository.load(risk.ip, CancelToken())).score, risk.score);
    },
  );
}
