// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../toolbox_ip.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$IpRiskCheck {

 IpRiskGroup get group; String get name; bool? get hit;
/// Create a copy of IpRiskCheck
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IpRiskCheckCopyWith<IpRiskCheck> get copyWith => _$IpRiskCheckCopyWithImpl<IpRiskCheck>(this as IpRiskCheck, _$identity);

  /// Serializes this IpRiskCheck to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as IpRiskCheck;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IpRiskCheck&&(identical(other.group, _this.group) || other.group == _this.group)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.hit, _this.hit) || other.hit == _this.hit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as IpRiskCheck;
  return Object.hash(runtimeType,_this.group,_this.name,_this.hit);
}

@override
String toString() {
  final _this = this as IpRiskCheck;
  return 'IpRiskCheck(group: ${_this.group}, name: ${_this.name}, hit: ${_this.hit})';
}


}

/// @nodoc
abstract mixin class $IpRiskCheckCopyWith<$Res>  {
  factory $IpRiskCheckCopyWith(IpRiskCheck value, $Res Function(IpRiskCheck) _then) = _$IpRiskCheckCopyWithImpl;
@useResult
$Res call({
 IpRiskGroup group, String name, bool? hit
});




}
/// @nodoc
class _$IpRiskCheckCopyWithImpl<$Res>
    implements $IpRiskCheckCopyWith<$Res> {
  _$IpRiskCheckCopyWithImpl(this._self, this._then);

  final IpRiskCheck _self;
  final $Res Function(IpRiskCheck) _then;

/// Create a copy of IpRiskCheck
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? group = null,Object? name = null,Object? hit = freezed,}) {
  return _then(IpRiskCheck(
group: null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as IpRiskGroup,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,hit: freezed == hit ? _self.hit : hit // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [IpRiskCheck].
extension IpRiskCheckPatterns on IpRiskCheck {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IpRiskCheck value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IpRiskCheck() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IpRiskCheck value)  $default,){
final _that = this;
switch (_that) {
case _IpRiskCheck():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IpRiskCheck value)?  $default,){
final _that = this;
switch (_that) {
case _IpRiskCheck() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( IpRiskGroup group,  String name,  bool? hit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IpRiskCheck() when $default != null:
return $default(_that.group,_that.name,_that.hit);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( IpRiskGroup group,  String name,  bool? hit)  $default,) {final _that = this;
switch (_that) {
case _IpRiskCheck():
return $default(_that.group,_that.name,_that.hit);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( IpRiskGroup group,  String name,  bool? hit)?  $default,) {final _that = this;
switch (_that) {
case _IpRiskCheck() when $default != null:
return $default(_that.group,_that.name,_that.hit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IpRiskCheck implements IpRiskCheck {
  const _IpRiskCheck({required this.group, required this.name, this.hit});
  factory _IpRiskCheck.fromJson(Map<String, dynamic> json) => _$IpRiskCheckFromJson(json);

@override final  IpRiskGroup group;
@override final  String name;
@override final  bool? hit;

/// Create a copy of IpRiskCheck
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IpRiskCheckCopyWith<_IpRiskCheck> get copyWith => __$IpRiskCheckCopyWithImpl<_IpRiskCheck>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IpRiskCheckToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _IpRiskCheck&&(identical(other.group, group) || other.group == group)&&(identical(other.name, name) || other.name == name)&&(identical(other.hit, hit) || other.hit == hit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,group,name,hit);
}

@override
String toString() {
    return 'IpRiskCheck(group: $group, name: $name, hit: $hit)';
}


}

/// @nodoc
abstract mixin class _$IpRiskCheckCopyWith<$Res> implements $IpRiskCheckCopyWith<$Res> {
  factory _$IpRiskCheckCopyWith(_IpRiskCheck value, $Res Function(_IpRiskCheck) _then) = __$IpRiskCheckCopyWithImpl;
@override @useResult
$Res call({
 IpRiskGroup group, String name, bool? hit
});




}
/// @nodoc
class __$IpRiskCheckCopyWithImpl<$Res>
    implements _$IpRiskCheckCopyWith<$Res> {
  __$IpRiskCheckCopyWithImpl(this._self, this._then);

  final _IpRiskCheck _self;
  final $Res Function(_IpRiskCheck) _then;

/// Create a copy of IpRiskCheck
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? group = null,Object? name = null,Object? hit = freezed,}) {
  return _then(_IpRiskCheck(
group: null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as IpRiskGroup,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,hit: freezed == hit ? _self.hit : hit // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}


/// @nodoc
mixin _$IpRiskNote {

 bool? get direct; String get isp; IpRiskAmount? get amount; IpRiskShare? get share; String get operatorName; IpRiskLevel? get operatorLevel; String get ownerName; IpRiskLevel? get ownerLevel; IpRiskConnection? get connection; IpRiskLevel? get warning;
/// Create a copy of IpRiskNote
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IpRiskNoteCopyWith<IpRiskNote> get copyWith => _$IpRiskNoteCopyWithImpl<IpRiskNote>(this as IpRiskNote, _$identity);

  /// Serializes this IpRiskNote to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as IpRiskNote;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IpRiskNote&&(identical(other.direct, _this.direct) || other.direct == _this.direct)&&(identical(other.isp, _this.isp) || other.isp == _this.isp)&&(identical(other.amount, _this.amount) || other.amount == _this.amount)&&(identical(other.share, _this.share) || other.share == _this.share)&&(identical(other.operatorName, _this.operatorName) || other.operatorName == _this.operatorName)&&(identical(other.operatorLevel, _this.operatorLevel) || other.operatorLevel == _this.operatorLevel)&&(identical(other.ownerName, _this.ownerName) || other.ownerName == _this.ownerName)&&(identical(other.ownerLevel, _this.ownerLevel) || other.ownerLevel == _this.ownerLevel)&&(identical(other.connection, _this.connection) || other.connection == _this.connection)&&(identical(other.warning, _this.warning) || other.warning == _this.warning));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as IpRiskNote;
  return Object.hash(runtimeType,_this.direct,_this.isp,_this.amount,_this.share,_this.operatorName,_this.operatorLevel,_this.ownerName,_this.ownerLevel,_this.connection,_this.warning);
}

@override
String toString() {
  final _this = this as IpRiskNote;
  return 'IpRiskNote(direct: ${_this.direct}, isp: ${_this.isp}, amount: ${_this.amount}, share: ${_this.share}, operatorName: ${_this.operatorName}, operatorLevel: ${_this.operatorLevel}, ownerName: ${_this.ownerName}, ownerLevel: ${_this.ownerLevel}, connection: ${_this.connection}, warning: ${_this.warning})';
}


}

/// @nodoc
abstract mixin class $IpRiskNoteCopyWith<$Res>  {
  factory $IpRiskNoteCopyWith(IpRiskNote value, $Res Function(IpRiskNote) _then) = _$IpRiskNoteCopyWithImpl;
@useResult
$Res call({
 bool? direct, String isp, IpRiskAmount? amount, IpRiskShare? share, String operatorName, IpRiskLevel? operatorLevel, String ownerName, IpRiskLevel? ownerLevel, IpRiskConnection? connection, IpRiskLevel? warning
});




}
/// @nodoc
class _$IpRiskNoteCopyWithImpl<$Res>
    implements $IpRiskNoteCopyWith<$Res> {
  _$IpRiskNoteCopyWithImpl(this._self, this._then);

  final IpRiskNote _self;
  final $Res Function(IpRiskNote) _then;

/// Create a copy of IpRiskNote
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? direct = freezed,Object? isp = null,Object? amount = freezed,Object? share = freezed,Object? operatorName = null,Object? operatorLevel = freezed,Object? ownerName = null,Object? ownerLevel = freezed,Object? connection = freezed,Object? warning = freezed,}) {
  return _then(IpRiskNote(
direct: freezed == direct ? _self.direct : direct // ignore: cast_nullable_to_non_nullable
as bool?,isp: null == isp ? _self.isp : isp // ignore: cast_nullable_to_non_nullable
as String,amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as IpRiskAmount?,share: freezed == share ? _self.share : share // ignore: cast_nullable_to_non_nullable
as IpRiskShare?,operatorName: null == operatorName ? _self.operatorName : operatorName // ignore: cast_nullable_to_non_nullable
as String,operatorLevel: freezed == operatorLevel ? _self.operatorLevel : operatorLevel // ignore: cast_nullable_to_non_nullable
as IpRiskLevel?,ownerName: null == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String,ownerLevel: freezed == ownerLevel ? _self.ownerLevel : ownerLevel // ignore: cast_nullable_to_non_nullable
as IpRiskLevel?,connection: freezed == connection ? _self.connection : connection // ignore: cast_nullable_to_non_nullable
as IpRiskConnection?,warning: freezed == warning ? _self.warning : warning // ignore: cast_nullable_to_non_nullable
as IpRiskLevel?,
  ));
}

}


/// Adds pattern-matching-related methods to [IpRiskNote].
extension IpRiskNotePatterns on IpRiskNote {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IpRiskNote value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IpRiskNote() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IpRiskNote value)  $default,){
final _that = this;
switch (_that) {
case _IpRiskNote():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IpRiskNote value)?  $default,){
final _that = this;
switch (_that) {
case _IpRiskNote() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool? direct,  String isp,  IpRiskAmount? amount,  IpRiskShare? share,  String operatorName,  IpRiskLevel? operatorLevel,  String ownerName,  IpRiskLevel? ownerLevel,  IpRiskConnection? connection,  IpRiskLevel? warning)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IpRiskNote() when $default != null:
return $default(_that.direct,_that.isp,_that.amount,_that.share,_that.operatorName,_that.operatorLevel,_that.ownerName,_that.ownerLevel,_that.connection,_that.warning);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool? direct,  String isp,  IpRiskAmount? amount,  IpRiskShare? share,  String operatorName,  IpRiskLevel? operatorLevel,  String ownerName,  IpRiskLevel? ownerLevel,  IpRiskConnection? connection,  IpRiskLevel? warning)  $default,) {final _that = this;
switch (_that) {
case _IpRiskNote():
return $default(_that.direct,_that.isp,_that.amount,_that.share,_that.operatorName,_that.operatorLevel,_that.ownerName,_that.ownerLevel,_that.connection,_that.warning);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool? direct,  String isp,  IpRiskAmount? amount,  IpRiskShare? share,  String operatorName,  IpRiskLevel? operatorLevel,  String ownerName,  IpRiskLevel? ownerLevel,  IpRiskConnection? connection,  IpRiskLevel? warning)?  $default,) {final _that = this;
switch (_that) {
case _IpRiskNote() when $default != null:
return $default(_that.direct,_that.isp,_that.amount,_that.share,_that.operatorName,_that.operatorLevel,_that.ownerName,_that.ownerLevel,_that.connection,_that.warning);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IpRiskNote implements IpRiskNote {
  const _IpRiskNote({this.direct, this.isp = '', this.amount, this.share, this.operatorName = '', this.operatorLevel, this.ownerName = '', this.ownerLevel, this.connection, this.warning});
  factory _IpRiskNote.fromJson(Map<String, dynamic> json) => _$IpRiskNoteFromJson(json);

@override final  bool? direct;
@override@JsonKey() final  String isp;
@override final  IpRiskAmount? amount;
@override final  IpRiskShare? share;
@override@JsonKey() final  String operatorName;
@override final  IpRiskLevel? operatorLevel;
@override@JsonKey() final  String ownerName;
@override final  IpRiskLevel? ownerLevel;
@override final  IpRiskConnection? connection;
@override final  IpRiskLevel? warning;

/// Create a copy of IpRiskNote
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IpRiskNoteCopyWith<_IpRiskNote> get copyWith => __$IpRiskNoteCopyWithImpl<_IpRiskNote>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IpRiskNoteToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _IpRiskNote&&(identical(other.direct, direct) || other.direct == direct)&&(identical(other.isp, isp) || other.isp == isp)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.share, share) || other.share == share)&&(identical(other.operatorName, operatorName) || other.operatorName == operatorName)&&(identical(other.operatorLevel, operatorLevel) || other.operatorLevel == operatorLevel)&&(identical(other.ownerName, ownerName) || other.ownerName == ownerName)&&(identical(other.ownerLevel, ownerLevel) || other.ownerLevel == ownerLevel)&&(identical(other.connection, connection) || other.connection == connection)&&(identical(other.warning, warning) || other.warning == warning));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,direct,isp,amount,share,operatorName,operatorLevel,ownerName,ownerLevel,connection,warning);
}

@override
String toString() {
    return 'IpRiskNote(direct: $direct, isp: $isp, amount: $amount, share: $share, operatorName: $operatorName, operatorLevel: $operatorLevel, ownerName: $ownerName, ownerLevel: $ownerLevel, connection: $connection, warning: $warning)';
}


}

/// @nodoc
abstract mixin class _$IpRiskNoteCopyWith<$Res> implements $IpRiskNoteCopyWith<$Res> {
  factory _$IpRiskNoteCopyWith(_IpRiskNote value, $Res Function(_IpRiskNote) _then) = __$IpRiskNoteCopyWithImpl;
@override @useResult
$Res call({
 bool? direct, String isp, IpRiskAmount? amount, IpRiskShare? share, String operatorName, IpRiskLevel? operatorLevel, String ownerName, IpRiskLevel? ownerLevel, IpRiskConnection? connection, IpRiskLevel? warning
});




}
/// @nodoc
class __$IpRiskNoteCopyWithImpl<$Res>
    implements _$IpRiskNoteCopyWith<$Res> {
  __$IpRiskNoteCopyWithImpl(this._self, this._then);

  final _IpRiskNote _self;
  final $Res Function(_IpRiskNote) _then;

/// Create a copy of IpRiskNote
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? direct = freezed,Object? isp = null,Object? amount = freezed,Object? share = freezed,Object? operatorName = null,Object? operatorLevel = freezed,Object? ownerName = null,Object? ownerLevel = freezed,Object? connection = freezed,Object? warning = freezed,}) {
  return _then(_IpRiskNote(
direct: freezed == direct ? _self.direct : direct // ignore: cast_nullable_to_non_nullable
as bool?,isp: null == isp ? _self.isp : isp // ignore: cast_nullable_to_non_nullable
as String,amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as IpRiskAmount?,share: freezed == share ? _self.share : share // ignore: cast_nullable_to_non_nullable
as IpRiskShare?,operatorName: null == operatorName ? _self.operatorName : operatorName // ignore: cast_nullable_to_non_nullable
as String,operatorLevel: freezed == operatorLevel ? _self.operatorLevel : operatorLevel // ignore: cast_nullable_to_non_nullable
as IpRiskLevel?,ownerName: null == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String,ownerLevel: freezed == ownerLevel ? _self.ownerLevel : ownerLevel // ignore: cast_nullable_to_non_nullable
as IpRiskLevel?,connection: freezed == connection ? _self.connection : connection // ignore: cast_nullable_to_non_nullable
as IpRiskConnection?,warning: freezed == warning ? _self.warning : warning // ignore: cast_nullable_to_non_nullable
as IpRiskLevel?,
  ));
}


}


/// @nodoc
mixin _$IpRisk {

 String get ip; int get score; IpRiskLevel get level; String get hostname; String get asn; String get isp; String get organization; String get country; String get countryCode; String get region; String get city; List<IpRiskCheck> get checks; IpRiskNote? get note;
/// Create a copy of IpRisk
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IpRiskCopyWith<IpRisk> get copyWith => _$IpRiskCopyWithImpl<IpRisk>(this as IpRisk, _$identity);

  /// Serializes this IpRisk to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as IpRisk;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IpRisk&&(identical(other.ip, _this.ip) || other.ip == _this.ip)&&(identical(other.score, _this.score) || other.score == _this.score)&&(identical(other.level, _this.level) || other.level == _this.level)&&(identical(other.hostname, _this.hostname) || other.hostname == _this.hostname)&&(identical(other.asn, _this.asn) || other.asn == _this.asn)&&(identical(other.isp, _this.isp) || other.isp == _this.isp)&&(identical(other.organization, _this.organization) || other.organization == _this.organization)&&(identical(other.country, _this.country) || other.country == _this.country)&&(identical(other.countryCode, _this.countryCode) || other.countryCode == _this.countryCode)&&(identical(other.region, _this.region) || other.region == _this.region)&&(identical(other.city, _this.city) || other.city == _this.city)&&const DeepCollectionEquality().equals(other.checks, _this.checks)&&(identical(other.note, _this.note) || other.note == _this.note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as IpRisk;
  return Object.hash(runtimeType,_this.ip,_this.score,_this.level,_this.hostname,_this.asn,_this.isp,_this.organization,_this.country,_this.countryCode,_this.region,_this.city,const DeepCollectionEquality().hash(_this.checks),_this.note);
}

@override
String toString() {
  final _this = this as IpRisk;
  return 'IpRisk(ip: ${_this.ip}, score: ${_this.score}, level: ${_this.level}, hostname: ${_this.hostname}, asn: ${_this.asn}, isp: ${_this.isp}, organization: ${_this.organization}, country: ${_this.country}, countryCode: ${_this.countryCode}, region: ${_this.region}, city: ${_this.city}, checks: ${_this.checks}, note: ${_this.note})';
}


}

/// @nodoc
abstract mixin class $IpRiskCopyWith<$Res>  {
  factory $IpRiskCopyWith(IpRisk value, $Res Function(IpRisk) _then) = _$IpRiskCopyWithImpl;
@useResult
$Res call({
 String ip, int score, IpRiskLevel level, String hostname, String asn, String isp, String organization, String country, String countryCode, String region, String city, List<IpRiskCheck> checks, IpRiskNote? note
});


$IpRiskNoteCopyWith<$Res>? get note;

}
/// @nodoc
class _$IpRiskCopyWithImpl<$Res>
    implements $IpRiskCopyWith<$Res> {
  _$IpRiskCopyWithImpl(this._self, this._then);

  final IpRisk _self;
  final $Res Function(IpRisk) _then;

/// Create a copy of IpRisk
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ip = null,Object? score = null,Object? level = null,Object? hostname = null,Object? asn = null,Object? isp = null,Object? organization = null,Object? country = null,Object? countryCode = null,Object? region = null,Object? city = null,Object? checks = null,Object? note = freezed,}) {
  return _then(IpRisk(
ip: null == ip ? _self.ip : ip // ignore: cast_nullable_to_non_nullable
as String,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as int,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as IpRiskLevel,hostname: null == hostname ? _self.hostname : hostname // ignore: cast_nullable_to_non_nullable
as String,asn: null == asn ? _self.asn : asn // ignore: cast_nullable_to_non_nullable
as String,isp: null == isp ? _self.isp : isp // ignore: cast_nullable_to_non_nullable
as String,organization: null == organization ? _self.organization : organization // ignore: cast_nullable_to_non_nullable
as String,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,countryCode: null == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String,region: null == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,checks: null == checks ? _self.checks : checks // ignore: cast_nullable_to_non_nullable
as List<IpRiskCheck>,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as IpRiskNote?,
  ));
}
/// Create a copy of IpRisk
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IpRiskNoteCopyWith<$Res>? get note {
    if (_self.note == null) {
    return null;
  }

  return $IpRiskNoteCopyWith<$Res>(_self.note!, (value) {
    return _then(_self.copyWith(note: value));
  });
}
}


/// Adds pattern-matching-related methods to [IpRisk].
extension IpRiskPatterns on IpRisk {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IpRisk value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IpRisk() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IpRisk value)  $default,){
final _that = this;
switch (_that) {
case _IpRisk():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IpRisk value)?  $default,){
final _that = this;
switch (_that) {
case _IpRisk() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String ip,  int score,  IpRiskLevel level,  String hostname,  String asn,  String isp,  String organization,  String country,  String countryCode,  String region,  String city,  List<IpRiskCheck> checks,  IpRiskNote? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IpRisk() when $default != null:
return $default(_that.ip,_that.score,_that.level,_that.hostname,_that.asn,_that.isp,_that.organization,_that.country,_that.countryCode,_that.region,_that.city,_that.checks,_that.note);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String ip,  int score,  IpRiskLevel level,  String hostname,  String asn,  String isp,  String organization,  String country,  String countryCode,  String region,  String city,  List<IpRiskCheck> checks,  IpRiskNote? note)  $default,) {final _that = this;
switch (_that) {
case _IpRisk():
return $default(_that.ip,_that.score,_that.level,_that.hostname,_that.asn,_that.isp,_that.organization,_that.country,_that.countryCode,_that.region,_that.city,_that.checks,_that.note);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String ip,  int score,  IpRiskLevel level,  String hostname,  String asn,  String isp,  String organization,  String country,  String countryCode,  String region,  String city,  List<IpRiskCheck> checks,  IpRiskNote? note)?  $default,) {final _that = this;
switch (_that) {
case _IpRisk() when $default != null:
return $default(_that.ip,_that.score,_that.level,_that.hostname,_that.asn,_that.isp,_that.organization,_that.country,_that.countryCode,_that.region,_that.city,_that.checks,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IpRisk implements IpRisk {
  const _IpRisk({required this.ip, required this.score, required this.level, this.hostname = '', this.asn = '', this.isp = '', this.organization = '', this.country = '', this.countryCode = '', this.region = '', this.city = '',  List<IpRiskCheck> checks = const [], this.note}): _checks = checks;
  factory _IpRisk.fromJson(Map<String, dynamic> json) => _$IpRiskFromJson(json);

@override final  String ip;
@override final  int score;
@override final  IpRiskLevel level;
@override@JsonKey() final  String hostname;
@override@JsonKey() final  String asn;
@override@JsonKey() final  String isp;
@override@JsonKey() final  String organization;
@override@JsonKey() final  String country;
@override@JsonKey() final  String countryCode;
@override@JsonKey() final  String region;
@override@JsonKey() final  String city;
 final  List<IpRiskCheck> _checks;
@override@JsonKey() List<IpRiskCheck> get checks {
  if (_checks is EqualUnmodifiableListView) return _checks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_checks);
}

@override final  IpRiskNote? note;

/// Create a copy of IpRisk
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IpRiskCopyWith<_IpRisk> get copyWith => __$IpRiskCopyWithImpl<_IpRisk>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IpRiskToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _IpRisk&&(identical(other.ip, ip) || other.ip == ip)&&(identical(other.score, score) || other.score == score)&&(identical(other.level, level) || other.level == level)&&(identical(other.hostname, hostname) || other.hostname == hostname)&&(identical(other.asn, asn) || other.asn == asn)&&(identical(other.isp, isp) || other.isp == isp)&&(identical(other.organization, organization) || other.organization == organization)&&(identical(other.country, country) || other.country == country)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode)&&(identical(other.region, region) || other.region == region)&&(identical(other.city, city) || other.city == city)&&const DeepCollectionEquality().equals(other.checks, _checks)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,ip,score,level,hostname,asn,isp,organization,country,countryCode,region,city,const DeepCollectionEquality().hash(_checks),note);
}

@override
String toString() {
    return 'IpRisk(ip: $ip, score: $score, level: $level, hostname: $hostname, asn: $asn, isp: $isp, organization: $organization, country: $country, countryCode: $countryCode, region: $region, city: $city, checks: $checks, note: $note)';
}


}

/// @nodoc
abstract mixin class _$IpRiskCopyWith<$Res> implements $IpRiskCopyWith<$Res> {
  factory _$IpRiskCopyWith(_IpRisk value, $Res Function(_IpRisk) _then) = __$IpRiskCopyWithImpl;
@override @useResult
$Res call({
 String ip, int score, IpRiskLevel level, String hostname, String asn, String isp, String organization, String country, String countryCode, String region, String city, List<IpRiskCheck> checks, IpRiskNote? note
});


@override $IpRiskNoteCopyWith<$Res>? get note;

}
/// @nodoc
class __$IpRiskCopyWithImpl<$Res>
    implements _$IpRiskCopyWith<$Res> {
  __$IpRiskCopyWithImpl(this._self, this._then);

  final _IpRisk _self;
  final $Res Function(_IpRisk) _then;

/// Create a copy of IpRisk
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ip = null,Object? score = null,Object? level = null,Object? hostname = null,Object? asn = null,Object? isp = null,Object? organization = null,Object? country = null,Object? countryCode = null,Object? region = null,Object? city = null,Object? checks = null,Object? note = freezed,}) {
  return _then(_IpRisk(
ip: null == ip ? _self.ip : ip // ignore: cast_nullable_to_non_nullable
as String,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as int,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as IpRiskLevel,hostname: null == hostname ? _self.hostname : hostname // ignore: cast_nullable_to_non_nullable
as String,asn: null == asn ? _self.asn : asn // ignore: cast_nullable_to_non_nullable
as String,isp: null == isp ? _self.isp : isp // ignore: cast_nullable_to_non_nullable
as String,organization: null == organization ? _self.organization : organization // ignore: cast_nullable_to_non_nullable
as String,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,countryCode: null == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String,region: null == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,checks: null == checks ? _self._checks : checks // ignore: cast_nullable_to_non_nullable
as List<IpRiskCheck>,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as IpRiskNote?,
  ));
}

/// Create a copy of IpRisk
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IpRiskNoteCopyWith<$Res>? get note {
    if (_self.note == null) {
    return null;
  }

  return $IpRiskNoteCopyWith<$Res>(_self.note!, (value) {
    return _then(_self.copyWith(note: value));
  });
}
}

// dart format on
