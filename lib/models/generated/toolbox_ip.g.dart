// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../toolbox_ip.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_IpRiskCheck _$IpRiskCheckFromJson(Map<String, dynamic> json) => _IpRiskCheck(
  group: $enumDecode(_$IpRiskGroupEnumMap, json['group']),
  name: json['name'] as String,
  hit: json['hit'] as bool?,
);

Map<String, dynamic> _$IpRiskCheckToJson(_IpRiskCheck instance) =>
    <String, dynamic>{
      'group': _$IpRiskGroupEnumMap[instance.group]!,
      'name': instance.name,
      'hit': instance.hit,
    };

const _$IpRiskGroupEnumMap = {
  IpRiskGroup.datacenter: 'datacenter',
  IpRiskGroup.blacklist: 'blacklist',
  IpRiskGroup.proxy: 'proxy',
};

_IpRiskNote _$IpRiskNoteFromJson(Map<String, dynamic> json) => _IpRiskNote(
  direct: json['direct'] as bool?,
  isp: json['isp'] as String? ?? '',
  amount: $enumDecodeNullable(_$IpRiskAmountEnumMap, json['amount']),
  share: $enumDecodeNullable(_$IpRiskShareEnumMap, json['share']),
  operatorName: json['operatorName'] as String? ?? '',
  operatorLevel: $enumDecodeNullable(
    _$IpRiskLevelEnumMap,
    json['operatorLevel'],
  ),
  ownerName: json['ownerName'] as String? ?? '',
  ownerLevel: $enumDecodeNullable(_$IpRiskLevelEnumMap, json['ownerLevel']),
  connection: $enumDecodeNullable(
    _$IpRiskConnectionEnumMap,
    json['connection'],
  ),
  warning: $enumDecodeNullable(_$IpRiskLevelEnumMap, json['warning']),
);

Map<String, dynamic> _$IpRiskNoteToJson(_IpRiskNote instance) =>
    <String, dynamic>{
      'direct': instance.direct,
      'isp': instance.isp,
      'amount': _$IpRiskAmountEnumMap[instance.amount],
      'share': _$IpRiskShareEnumMap[instance.share],
      'operatorName': instance.operatorName,
      'operatorLevel': _$IpRiskLevelEnumMap[instance.operatorLevel],
      'ownerName': instance.ownerName,
      'ownerLevel': _$IpRiskLevelEnumMap[instance.ownerLevel],
      'connection': _$IpRiskConnectionEnumMap[instance.connection],
      'warning': _$IpRiskLevelEnumMap[instance.warning],
    };

const _$IpRiskAmountEnumMap = {
  IpRiskAmount.low: 'low',
  IpRiskAmount.medium: 'medium',
  IpRiskAmount.high: 'high',
};

const _$IpRiskShareEnumMap = {
  IpRiskShare.little: 'little',
  IpRiskShare.some: 'some',
  IpRiskShare.almostAll: 'almostAll',
};

const _$IpRiskLevelEnumMap = {
  IpRiskLevel.low: 'low',
  IpRiskLevel.medium: 'medium',
  IpRiskLevel.high: 'high',
  IpRiskLevel.veryHigh: 'veryHigh',
};

const _$IpRiskConnectionEnumMap = {
  IpRiskConnection.server: 'server',
  IpRiskConnection.vpn: 'vpn',
  IpRiskConnection.publicProxy: 'publicProxy',
  IpRiskConnection.tor: 'tor',
  IpRiskConnection.webProxy: 'webProxy',
};

_IpRisk _$IpRiskFromJson(Map<String, dynamic> json) => _IpRisk(
  ip: json['ip'] as String,
  score: (json['score'] as num).toInt(),
  level: $enumDecode(_$IpRiskLevelEnumMap, json['level']),
  hostname: json['hostname'] as String? ?? '',
  asn: json['asn'] as String? ?? '',
  isp: json['isp'] as String? ?? '',
  organization: json['organization'] as String? ?? '',
  country: json['country'] as String? ?? '',
  countryCode: json['countryCode'] as String? ?? '',
  region: json['region'] as String? ?? '',
  city: json['city'] as String? ?? '',
  checks:
      (json['checks'] as List<dynamic>?)
          ?.map((e) => IpRiskCheck.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  note: json['note'] == null
      ? null
      : IpRiskNote.fromJson(json['note'] as Map<String, dynamic>),
);

Map<String, dynamic> _$IpRiskToJson(_IpRisk instance) => <String, dynamic>{
  'ip': instance.ip,
  'score': instance.score,
  'level': _$IpRiskLevelEnumMap[instance.level]!,
  'hostname': instance.hostname,
  'asn': instance.asn,
  'isp': instance.isp,
  'organization': instance.organization,
  'country': instance.country,
  'countryCode': instance.countryCode,
  'region': instance.region,
  'city': instance.city,
  'checks': instance.checks,
  'note': instance.note,
};
