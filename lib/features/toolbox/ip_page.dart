import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/method.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'client.dart';
import 'ip_risk_parser.dart';
import 'proxy.dart';
import 'widgets.dart';

class IpLookupPage extends ConsumerStatefulWidget {
  const IpLookupPage({super.key, this.client});
  final ToolboxClient? client;

  @override
  ConsumerState<IpLookupPage> createState() => _IpLookupPageState();
}

class _IpLookupPageState extends ConsumerState<IpLookupPage> {
  final _target = TextEditingController();
  final _cancel = CancelToken();
  bool _busy = false;
  String _proxy = '';
  Object? _result;
  String? _error;

  ToolboxClient get _client => widget.client ?? toolboxClient;

  @override
  void dispose() {
    _cancel.cancel();
    _target.dispose();
    super.dispose();
  }

  Future<Map<String, Object?>> _lookup(Dio dio, String ip) async {
    final result = <String, Object?>{};
    final response = await dio.get<Map<String, dynamic>>(
      'http://ip-api.com/json/${Uri.encodeComponent(ip)}',
      queryParameters: {
        'fields':
            'status,message,country,countryCode,regionName,city,zip,lat,lon,timezone,isp,org,as,query',
        'lang': Localizations.localeOf(context).languageCode == 'zh'
            ? 'zh-CN'
            : 'en',
      },
      cancelToken: _cancel,
    );
    result.addAll(response.data ?? {});
    final actualIp = '${result['query'] ?? ip}';
    if (InternetAddress.tryParse(actualIp) != null) {
      try {
        final riskResponse = await dio.get<List<int>>(
          'https://scamalytics.com/ip/${Uri.encodeComponent(actualIp)}',
          options: Options(responseType: ResponseType.bytes),
          cancelToken: _cancel,
        );
        final risk = await compute(
          (({String ip, List<int> bytes}) input) =>
              parseScamalyticsBytes(input.ip, input.bytes),
          (ip: actualIp, bytes: riskResponse.data!),
        );
        result['risk'] = risk?.toJson();
      } catch (error) {
        result['risk'] = '$error';
      }
    }
    return result;
  }

  Future<void> _query() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    ToolProxyLease? lease;
    Dio? dio;
    try {
      lease = await ToolProxyLease.acquire(_client, _proxy);
      final route = lease.route;
      dio =
          Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 8),
                receiveTimeout: const Duration(seconds: 10),
              ),
            )
            ..httpClientAdapter = IOHttpClientAdapter(
              createHttpClient: () => HttpClient()..findProxy = (_) => route,
            );
      final text = _target.text.trim();
      final host = text.contains('://') ? Uri.parse(text).host : text;
      List<String> ips;
      if (host.isEmpty || InternetAddress.tryParse(host) != null) {
        ips = [host];
      } else {
        final mode = ref.read(runTimeProvider) != null ? 'follow' : 'system';
        final answers = await Future.wait([
          for (final type in ['A', 'AAAA'])
            _client.query(CoreMethod.toolboxDnsQuery, {
              'domain': host,
              'type': type,
              'mode': mode,
            }),
        ]);
        ips = {
          for (final answer in answers)
            for (final record in answer['answers'] as List? ?? [])
              if (record is Map &&
                  InternetAddress.tryParse('${record['data']}') != null)
                '${record['data']}',
        }.toList();
        if (ips.isEmpty) {
          throw StateError(currentAppLocalizations.ipLookupResolveFailed);
        }
      }
      final entries = <String, Object?>{};
      for (final ip in ips) {
        if (_cancel.isCancelled) break;
        entries[ip.isEmpty ? currentAppLocalizations.ipLookupProxyExit : ip] =
            await _lookup(dio, ip);
      }
      if (host.isEmpty) {
        final direct =
            Dio(
                BaseOptions(
                  connectTimeout: const Duration(seconds: 6),
                  receiveTimeout: const Duration(seconds: 8),
                ),
              )
              ..httpClientAdapter = IOHttpClientAdapter(
                createHttpClient: () =>
                    HttpClient()..findProxy = (_) => 'DIRECT',
              );
        try {
          entries[currentAppLocalizations.ipLookupDomesticExit] = await _lookup(
            direct,
            '',
          );
        } catch (error) {
          entries[currentAppLocalizations.ipLookupDomesticExit] = '$error';
        } finally {
          direct.close(force: true);
        }
      }
      entries['local-network'] = [
        for (final interface in await NetworkInterface.list())
          {
            'name': interface.name,
            'address': interface.addresses.map((a) => a.address).toList(),
          },
      ];
      if (mounted) setState(() => _result = entries);
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      dio?.close(force: true);
      try {
        await lease?.release();
      } catch (error) {
        commonPrint.log('Unable to close IP lookup proxy: $error');
      }
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final groups = ref.watch(groupsProvider);
    final outbounds = [
      '',
      'DIRECT',
      ...{for (final group in groups) group.name},
    ];
    return ToolPageFrame(
      title: l.ipLookup,
      actions: [toolCopyAction(context, _result)],
      slivers: [if (_result != null) ToolResultSliver(value: _result)],
      children: [
        ToolMessage(l.ipLookupDesc),
        ToolField(
          label: l.ipLookup,
          controller: _target,
          hint: l.ipLookupHint,
          onSubmitted: (_) => _query(),
        ),
        generateSection(
          items: [
            ListItem<String>.options(
              title: Text(l.speedTestOutbound),
              options: outbounds,
              value: outbounds.contains(_proxy) ? _proxy : '',
              textBuilder: (v) => v.isEmpty ? l.speedTestFollowRules : v,
              onChanged: (v) => setState(() => _proxy = v),
            ),
          ],
        ),
        ToolRunButton(
          busy: _busy,
          onRun: _query,
          label: _target.text.isEmpty ? l.ipLookupMine : null,
        ),
        if (_error != null) ToolMessage(_error!, error: true),
      ],
    );
  }
}
