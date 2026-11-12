import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/toolbox_ip.freezed.dart';
part 'generated/toolbox_ip.g.dart';

enum IpRiskLevel { low, medium, high, veryHigh }

enum IpRiskGroup { datacenter, blacklist, proxy }

enum IpRiskAmount { low, medium, high }

enum IpRiskShare { little, some, almostAll }

enum IpRiskConnection { server, vpn, publicProxy, tor, webProxy }

@freezed
abstract class IpRiskCheck with _$IpRiskCheck {
  const factory IpRiskCheck({
    required IpRiskGroup group,
    required String name,
    bool? hit,
  }) = _IpRiskCheck;

  factory IpRiskCheck.fromJson(Map<String, Object?> json) =>
      _$IpRiskCheckFromJson(json);
}

@freezed
abstract class IpRiskNote with _$IpRiskNote {
  const factory IpRiskNote({
    bool? direct,
    @Default('') String isp,
    IpRiskAmount? amount,
    IpRiskShare? share,
    @Default('') String operatorName,
    IpRiskLevel? operatorLevel,
    @Default('') String ownerName,
    IpRiskLevel? ownerLevel,
    IpRiskConnection? connection,
    IpRiskLevel? warning,
  }) = _IpRiskNote;

  factory IpRiskNote.fromJson(Map<String, Object?> json) =>
      _$IpRiskNoteFromJson(json);
}

@freezed
abstract class IpRisk with _$IpRisk {
  const factory IpRisk({
    required String ip,
    required int score,
    required IpRiskLevel level,
    @Default('') String hostname,
    @Default('') String asn,
    @Default('') String isp,
    @Default('') String organization,
    @Default('') String country,
    @Default('') String countryCode,
    @Default('') String region,
    @Default('') String city,
    @Default([]) List<IpRiskCheck> checks,
    IpRiskNote? note,
  }) = _IpRisk;

  factory IpRisk.fromJson(Map<String, Object?> json) => _$IpRiskFromJson(json);
}

extension IpRiskExt on IpRisk {
  bool get isHomeBroadband =>
      checks.isNotEmpty &&
      checks.any((check) => check.group == IpRiskGroup.datacenter) &&
      checks.every((check) => check.hit != true);

  int get displayScore => !isHomeBroadband && score == 0 ? 1 : score;

  IpRisk get normalized =>
      !isHomeBroadband && score == 0 ? copyWith(score: 1) : this;
}

class ToolIpInfo {
  final String ip;
  final String countryCode;
  final String? country;
  final String? province;
  final String? city;
  final String? isp;
  final String? asn;
  final String? asName;
  final String? asDomain;
  final String? continent;
  final String? continentCode;

  ToolIpInfo({
    required this.ip,
    required String countryCode,
    String? country,
    this.province,
    this.city,
    this.isp,
    this.asn,
    this.asName,
    this.asDomain,
    this.continent,
    this.continentCode,
  }) : countryCode = normalizeCountryCode(countryCode, country, province),
       country = normalizeCountry(
         country,
         normalizeCountryCode(countryCode, country, province),
         province,
       );

  static bool _isTaiwan(String? text) {
    if (text == null || text.isEmpty) return false;
    final trimmed = text.trim();
    final lower = trimmed.toLowerCase();
    if (lower == 'tw' ||
        lower == 'twn' ||
        lower == 'taiwan' ||
        lower == 'taiwan (china)' ||
        lower == 'taiwan, china' ||
        lower == 'taiwan, province of china' ||
        lower == 'republic of china' ||
        lower == 'republic of china (taiwan)' ||
        lower == 'taiwan (roc)' ||
        lower == 'taiwan, roc' ||
        lower == 'roc') {
      return true;
    }
    if (trimmed == '台湾' ||
        trimmed == '台灣' ||
        trimmed == '臺灣' ||
        trimmed == '台湾省' ||
        trimmed == '臺灣省' ||
        trimmed == '台湾 (中国)' ||
        trimmed == '台灣 (中国)' ||
        trimmed == '臺灣 (中国)' ||
        trimmed == '中国台湾' ||
        trimmed == '中國台灣' ||
        trimmed == '中國臺灣' ||
        trimmed == '中华民国' ||
        trimmed == '中華民國') {
      return true;
    }
    if (trimmed.contains('中华民国') ||
        trimmed.contains('中華民國') ||
        trimmed.contains('台湾') ||
        trimmed.contains('台灣') ||
        trimmed.contains('臺灣')) {
      return true;
    }
    return false;
  }

  static String normalizeCountryCode(
    String countryCode, [
    String? country,
    String? province,
  ]) {
    final clean = countryCode.trim().toUpperCase();
    if (clean.length == 2 && RegExp(r'^[A-Z]{2}$').hasMatch(clean)) {
      if (clean == 'CN') {
        if (_isTaiwan(province) || _isTaiwan(country)) {
          return 'TW';
        }
        if (province == '香港' || country == '香港') return 'HK';
        if (province == '澳门' ||
            province == '澳門' ||
            country == '澳门' ||
            country == '澳門') {
          return 'MO';
        }
      }
      return clean;
    }
    if (_isTaiwan(clean) || _isTaiwan(country) || _isTaiwan(province)) {
      return 'TW';
    }
    if (clean == 'HK' ||
        clean == 'HKG' ||
        country == '香港' ||
        province == '香港') {
      return 'HK';
    }
    if (clean == 'MO' ||
        clean == 'MAC' ||
        clean == 'MFM' ||
        country == '澳门' ||
        country == '澳門' ||
        province == '澳门' ||
        province == '澳門') {
      return 'MO';
    }
    return clean;
  }

  static String? normalizeCountry(
    String? country, [
    String? countryCode,
    String? province,
  ]) {
    final effectiveCode = countryCode?.trim().toUpperCase();
    if (country == null || country.trim().isEmpty) {
      if (effectiveCode == 'TW' || _isTaiwan(province)) {
        return '台湾 (中国)';
      }
      return null;
    }
    final trimmed = country.trim();
    if (trimmed == '台湾 (中国)' ||
        trimmed == '台灣 (中国)' ||
        trimmed == '臺灣 (中国)' ||
        trimmed == 'Taiwan (China)' ||
        trimmed == '中国台湾' ||
        trimmed == '中國台灣' ||
        trimmed == '中國臺灣') {
      return trimmed;
    }
    if (trimmed.endsWith('(中国)') ||
        trimmed.endsWith('（中国）') ||
        trimmed.endsWith('(China)') ||
        trimmed.endsWith('（China）') ||
        trimmed.endsWith('(中國)') ||
        trimmed.endsWith('（中國）')) {
      return trimmed;
    }
    final lower = trimmed.toLowerCase();
    if (lower == 'taiwan' ||
        lower == 'republic of china' ||
        lower == 'republic of china (taiwan)' ||
        lower == 'taiwan (roc)' ||
        lower == 'taiwan, roc' ||
        lower == 'roc' ||
        lower == 'taiwan, province of china' ||
        lower == 'taiwan, china') {
      return 'Taiwan (China)';
    }
    if (trimmed == '中華民國' ||
        trimmed.contains('中華民國') ||
        trimmed == '台灣' ||
        trimmed == '臺灣') {
      return '台灣 (中国)';
    }
    if (trimmed == '中华民国' || trimmed.contains('中华民国') || trimmed == '台湾') {
      return '台湾 (中国)';
    }
    if (trimmed == '台湾省') {
      return '台湾省 (中国)';
    }
    if (trimmed == '台灣省' || trimmed == '臺灣省') {
      return '台灣省 (中国)';
    }
    if (effectiveCode == 'TW' || _isTaiwan(province)) {
      if (trimmed == '中国' || trimmed == '中國') {
        if (province != null &&
            (province.contains('中華民國') ||
                province.contains('台灣') ||
                province.contains('臺灣'))) {
          return '台灣 (中国)';
        }
        return '台湾 (中国)';
      }
    }
    return country;
  }

  static ToolIpInfo fromJson(Map<String, dynamic> json) {
    if (json['ret'] == 'ok' && json['data'] is Map) {
      final data = json['data'] as Map;
      final ip = data['ip']?.toString() ?? '';
      final loc = data['location'];
      if (loc is List && ip.isNotEmpty) {
        final locList = loc.map((e) => e?.toString() ?? '').toList();
        final country = locList.isNotEmpty && locList[0].isNotEmpty
            ? locList[0]
            : null;
        final countryCode = country == '中国' ? 'CN' : '';
        final province = locList.length > 1 && locList[1].isNotEmpty
            ? locList[1]
            : null;
        final city = locList.length > 2 && locList[2].isNotEmpty
            ? locList[2]
            : null;
        final last = locList.length > 4 && locList[4].isNotEmpty
            ? locList[4]
            : (locList.length > 3 && locList[3].isNotEmpty ? locList[3] : null);

        String? isp;
        String? asName;
        String? asDomain;
        if (last != null && last.isNotEmpty) {
          if (last.contains('.')) {
            asDomain = last;
            asName = last;
          } else {
            isp = last;
            asName = last;
          }
        }

        return ToolIpInfo(
          ip: ip,
          countryCode: countryCode,
          country: country,
          province: province,
          city: city,
          isp: isp,
          asName: asName,
          asDomain: asDomain,
        );
      }
    }

    final ip = json['ip']?.toString() ?? '';
    if (json['region'] is String && json.containsKey('llc')) {
      final region = (json['region'] as String)
          .split(RegExp(r'\s+'))
          .where((item) => item.isNotEmpty)
          .toList();
      final country = region.firstOrNull;
      final llc = json['llc']?.toString() ?? '';
      final isp = llc.isNotEmpty ? llc : json['isp']?.toString();
      final rawAsn = json['asn']?.toString().trim().toUpperCase() ?? '';
      if (ip.isNotEmpty) {
        return ToolIpInfo(
          ip: ip,
          countryCode: country == '中国'
              ? switch (region.elementAtOrNull(1)) {
                  '台湾' => 'TW',
                  '香港' => 'HK',
                  '澳门' => 'MO',
                  _ => 'CN',
                }
              : '',
          country: country,
          province: region.elementAtOrNull(1),
          city: region.elementAtOrNull(2),
          isp: isp,
          asName: isp,
          asn: rawAsn.isEmpty ? null : rawAsn,
        );
      }
    }
    if (json['location'] is Map) {
      final loc = json['location'] as Map;
      final countryCode = loc['country_code']?.toString() ?? '';
      final country = loc['country_name']?.toString();
      final province = loc['province']?.toString();
      final city = loc['city']?.toString();
      if (ip.isNotEmpty) {
        return ToolIpInfo(
          ip: ip,
          countryCode: countryCode,
          country: country,
          province: province,
          city: city,
        );
      }
    }

    if (json['query'] != null ||
        json['countryCode'] != null ||
        json['status'] != null) {
      if (json['status'] != null && json['status'] != 'success') {
        throw FormatException(
          'ip-api.com status not success: ${json['message']}',
        );
      }
      final ip = (json['query'] ?? json['ip'])?.toString() ?? '';
      final countryCode =
          (json['countryCode'] ?? json['country_code'])?.toString() ?? '';
      final country = json['country']?.toString();
      final province =
          (json['regionName'] ?? json['region'] ?? json['province'])
              ?.toString();
      final city = json['city']?.toString();
      final isp = json['isp']?.toString();
      final org = json['org']?.toString();
      final asName = org?.isNotEmpty == true
          ? org
          : (json['as_name']?.toString());

      final rawAs = (json['as'] ?? json['asn'])?.toString() ?? '';
      final asnMatch = RegExp(
        r'^(AS\d+)',
        caseSensitive: false,
      ).firstMatch(rawAs.trim());
      final asn = asnMatch != null
          ? asnMatch.group(1)!.toUpperCase()
          : (rawAs.isNotEmpty ? rawAs.trim().split(' ').first : null);

      if (ip.isNotEmpty) {
        return ToolIpInfo(
          ip: ip,
          countryCode: countryCode,
          country: country,
          province: province,
          city: city,
          isp: isp,
          asName: asName,
          asn: asn,
        );
      }
    }

    if (json['country_code'] != null && json['country_code3'] != null) {
      final ip = json['ip']?.toString() ?? '';
      final org =
          json['organization_name']?.toString() ??
          json['organization']?.toString();
      final rawAsn = json['asn']?.toString() ?? '';
      final asn = rawAsn.isNotEmpty
          ? (rawAsn.toUpperCase().startsWith('AS')
                ? rawAsn.toUpperCase()
                : 'AS$rawAsn')
          : null;
      if (ip.isNotEmpty) {
        return ToolIpInfo(
          ip: ip,
          countryCode: json['country_code']?.toString() ?? '',
          country: json['country']?.toString(),
          province: json['region']?.toString(),
          city: json['city']?.toString(),
          isp: org,
          asName: org,
          asn: asn,
          continentCode: json['continent_code']?.toString(),
        );
      }
    }

    final countryCode =
        (json['country_code'] ?? json['country'])?.toString() ?? '';
    final country = json['country']?.toString();
    final asn = json['asn']?.toString();
    final asName = json['as_name']?.toString();
    final asDomain = json['as_domain']?.toString();
    final continent = json['continent']?.toString();
    final continentCode = json['continent_code']?.toString();
    if (ip.isNotEmpty) {
      return ToolIpInfo(
        ip: ip,
        countryCode: countryCode,
        country: country,
        asn: asn,
        asName: asName,
        asDomain: asDomain,
        continent: continent,
        continentCode: continentCode,
      );
    }
    throw const FormatException('invalid ip json format');
  }

  static ToolIpInfo fromCloudflareTrace(String traceText) {
    final lines = traceText.split('\n');
    String? ip;
    String? countryCode;

    for (final line in lines) {
      final parts = line.split('=');
      if (parts.length == 2) {
        final key = parts[0].trim();
        final value = parts[1].trim();

        if (key == 'ip') {
          ip = value;
        } else if (key == 'loc') {
          countryCode = value;
        }
      }
    }

    if (ip != null && countryCode != null) {
      return ToolIpInfo(ip: ip, countryCode: countryCode);
    }

    throw const FormatException('invalid cloudflare trace format');
  }

  static bool _hasNonAscii(String? str) {
    if (str == null || str.isEmpty) return false;
    return str.codeUnits.any((c) => c > 127);
  }

  ToolIpInfo merge(ToolIpInfo other, {bool otherIsAuthoritative = false}) {
    final isOtherPrimary =
        otherIsAuthoritative ||
        ((asn == null || asn!.isEmpty) &&
            (other.asn != null && other.asn!.isNotEmpty));

    final primary = isOtherPrimary ? other : this;
    final secondary = isOtherPrimary ? this : other;

    final mergedIp = primary.ip.isNotEmpty ? primary.ip : secondary.ip;
    final bool isSameIp =
        primary.ip.isEmpty ||
        secondary.ip.isEmpty ||
        primary.ip == secondary.ip;

    final primaryCc = primary.countryCode.trim().toUpperCase();
    final secondaryCc = secondary.countryCode.trim().toUpperCase();

    final bool isSameCountry =
        isSameIp &&
        (primaryCc.isEmpty || secondaryCc.isEmpty || primaryCc == secondaryCc);

    final mergedCountryCode = primaryCc.isNotEmpty ? primaryCc : secondaryCc;

    final mergedCountry = () {
      if (isSameCountry) {
        if (_hasNonAscii(primary.country)) return primary.country;
        if (_hasNonAscii(secondary.country)) return secondary.country;
        return (primary.country?.isNotEmpty == true)
            ? primary.country
            : secondary.country;
      }
      return (primary.country?.isNotEmpty == true)
          ? primary.country
          : secondary.country;
    }();

    final mergedProvince = primary.province?.isNotEmpty == true
        ? primary.province
        : (isSameCountry ? secondary.province : null);

    final mergedCity = primary.city?.isNotEmpty == true
        ? primary.city
        : (isSameCountry ? secondary.city : null);

    final mergedAsn = primary.asn?.isNotEmpty == true
        ? primary.asn
        : secondary.asn;
    final mergedAsName = primary.asName?.isNotEmpty == true
        ? primary.asName
        : secondary.asName;
    final mergedAsDomain = primary.asDomain?.isNotEmpty == true
        ? primary.asDomain
        : secondary.asDomain;
    final mergedIsp = primary.isp?.isNotEmpty == true
        ? primary.isp
        : secondary.isp;
    final mergedContinent = primary.continent?.isNotEmpty == true
        ? primary.continent
        : secondary.continent;
    final mergedContinentCode = primary.continentCode?.isNotEmpty == true
        ? primary.continentCode
        : secondary.continentCode;

    return ToolIpInfo(
      ip: mergedIp,
      countryCode: mergedCountryCode,
      country: mergedCountry,
      province: mergedProvince,
      city: mergedCity,
      isp: mergedIsp,
      asn: mergedAsn,
      asName: mergedAsName,
      asDomain: mergedAsDomain,
      continent: mergedContinent,
      continentCode: mergedContinentCode,
    );
  }

  ToolIpInfo copyWith({
    String? ip,
    String? countryCode,
    String? country,
    String? province,
    String? city,
    String? isp,
    String? asn,
    String? asName,
    String? asDomain,
    String? continent,
    String? continentCode,
  }) {
    return ToolIpInfo(
      ip: ip ?? this.ip,
      countryCode: countryCode ?? this.countryCode,
      country: country ?? this.country,
      province: province ?? this.province,
      city: city ?? this.city,
      isp: isp ?? this.isp,
      asn: asn ?? this.asn,
      asName: asName ?? this.asName,
      asDomain: asDomain ?? this.asDomain,
      continent: continent ?? this.continent,
      continentCode: continentCode ?? this.continentCode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ip': ip,
      'countryCode': countryCode,
      if (country != null) 'country': country,
      if (province != null) 'regionName': province,
      if (city != null) 'city': city,
      if (isp != null) 'isp': isp,
      if (asName != null) 'org': asName,
      if (asn != null) 'as': asn,
      if (asDomain != null) 'as_domain': asDomain,
      if (continent != null) 'continent': continent,
      if (continentCode != null) 'continent_code': continentCode,
    };
  }

  @override
  String toString() {
    return 'ToolIpInfo{ip: $ip, countryCode: $countryCode, country: $country, province: $province, city: $city, isp: $isp, asn: $asn, asName: $asName}';
  }
}
