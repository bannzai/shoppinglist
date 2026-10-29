// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group_shopping_location.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GroupShoppingLocation {

 String get id; String get groupID; String get name;/// 逆ジオコードで取得した住所文字列。LocationPicker (PRO 限定地図設定) で
/// 緯度経度を確定したときに保存し、無料機能で場所名のみ登録した際は空文字。
/// 既存ドキュメントにはこのフィールドが存在しないため default で空文字。
 String get address;/// 店舗の緯度。nullの場合はジオフェンス対象外。
 double? get latitude;/// 店舗の経度。nullの場合はジオフェンス対象外。
 double? get longitude;/// ジオフェンスの半径（メートル単位）。nullの場合はデフォルト値を使用する。
 double? get geofenceRadiusMeters;@ClientCreatedTimestamp() DateTime? get createdDateTime;@ClientUpdatedTimestamp() DateTime? get updatedDateTime;@ServerCreatedTimestamp() DateTime? get serverCreatedDateTime;@ServerUpdatedTimestamp() DateTime? get serverUpdatedDateTime;
/// Create a copy of GroupShoppingLocation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupShoppingLocationCopyWith<GroupShoppingLocation> get copyWith => _$GroupShoppingLocationCopyWithImpl<GroupShoppingLocation>(this as GroupShoppingLocation, _$identity);

  /// Serializes this GroupShoppingLocation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as GroupShoppingLocation;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroupShoppingLocation&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.groupID, _this.groupID) || other.groupID == _this.groupID)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.address, _this.address) || other.address == _this.address)&&(identical(other.latitude, _this.latitude) || other.latitude == _this.latitude)&&(identical(other.longitude, _this.longitude) || other.longitude == _this.longitude)&&(identical(other.geofenceRadiusMeters, _this.geofenceRadiusMeters) || other.geofenceRadiusMeters == _this.geofenceRadiusMeters)&&(identical(other.createdDateTime, _this.createdDateTime) || other.createdDateTime == _this.createdDateTime)&&(identical(other.updatedDateTime, _this.updatedDateTime) || other.updatedDateTime == _this.updatedDateTime)&&(identical(other.serverCreatedDateTime, _this.serverCreatedDateTime) || other.serverCreatedDateTime == _this.serverCreatedDateTime)&&(identical(other.serverUpdatedDateTime, _this.serverUpdatedDateTime) || other.serverUpdatedDateTime == _this.serverUpdatedDateTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as GroupShoppingLocation;
  return Object.hash(runtimeType,_this.id,_this.groupID,_this.name,_this.address,_this.latitude,_this.longitude,_this.geofenceRadiusMeters,_this.createdDateTime,_this.updatedDateTime,_this.serverCreatedDateTime,_this.serverUpdatedDateTime);
}

@override
String toString() {
  final _this = this as GroupShoppingLocation;
  return 'GroupShoppingLocation(id: ${_this.id}, groupID: ${_this.groupID}, name: ${_this.name}, address: ${_this.address}, latitude: ${_this.latitude}, longitude: ${_this.longitude}, geofenceRadiusMeters: ${_this.geofenceRadiusMeters}, createdDateTime: ${_this.createdDateTime}, updatedDateTime: ${_this.updatedDateTime}, serverCreatedDateTime: ${_this.serverCreatedDateTime}, serverUpdatedDateTime: ${_this.serverUpdatedDateTime})';
}


}

/// @nodoc
abstract mixin class $GroupShoppingLocationCopyWith<$Res>  {
  factory $GroupShoppingLocationCopyWith(GroupShoppingLocation value, $Res Function(GroupShoppingLocation) _then) = _$GroupShoppingLocationCopyWithImpl;
@useResult
$Res call({
 String id, String groupID, String name, String address, double? latitude, double? longitude, double? geofenceRadiusMeters,@ClientCreatedTimestamp() DateTime? createdDateTime,@ClientUpdatedTimestamp() DateTime? updatedDateTime,@ServerCreatedTimestamp() DateTime? serverCreatedDateTime,@ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime
});




}
/// @nodoc
class _$GroupShoppingLocationCopyWithImpl<$Res>
    implements $GroupShoppingLocationCopyWith<$Res> {
  _$GroupShoppingLocationCopyWithImpl(this._self, this._then);

  final GroupShoppingLocation _self;
  final $Res Function(GroupShoppingLocation) _then;

/// Create a copy of GroupShoppingLocation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? groupID = null,Object? name = null,Object? address = null,Object? latitude = freezed,Object? longitude = freezed,Object? geofenceRadiusMeters = freezed,Object? createdDateTime = freezed,Object? updatedDateTime = freezed,Object? serverCreatedDateTime = freezed,Object? serverUpdatedDateTime = freezed,}) {
  return _then(GroupShoppingLocation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,groupID: null == groupID ? _self.groupID : groupID // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,geofenceRadiusMeters: freezed == geofenceRadiusMeters ? _self.geofenceRadiusMeters : geofenceRadiusMeters // ignore: cast_nullable_to_non_nullable
as double?,createdDateTime: freezed == createdDateTime ? _self.createdDateTime : createdDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedDateTime: freezed == updatedDateTime ? _self.updatedDateTime : updatedDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,serverCreatedDateTime: freezed == serverCreatedDateTime ? _self.serverCreatedDateTime : serverCreatedDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,serverUpdatedDateTime: freezed == serverUpdatedDateTime ? _self.serverUpdatedDateTime : serverUpdatedDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [GroupShoppingLocation].
extension GroupShoppingLocationPatterns on GroupShoppingLocation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroupShoppingLocation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroupShoppingLocation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroupShoppingLocation value)  $default,){
final _that = this;
switch (_that) {
case _GroupShoppingLocation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroupShoppingLocation value)?  $default,){
final _that = this;
switch (_that) {
case _GroupShoppingLocation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String groupID,  String name,  String address,  double? latitude,  double? longitude,  double? geofenceRadiusMeters, @ClientCreatedTimestamp()  DateTime? createdDateTime, @ClientUpdatedTimestamp()  DateTime? updatedDateTime, @ServerCreatedTimestamp()  DateTime? serverCreatedDateTime, @ServerUpdatedTimestamp()  DateTime? serverUpdatedDateTime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroupShoppingLocation() when $default != null:
return $default(_that.id,_that.groupID,_that.name,_that.address,_that.latitude,_that.longitude,_that.geofenceRadiusMeters,_that.createdDateTime,_that.updatedDateTime,_that.serverCreatedDateTime,_that.serverUpdatedDateTime);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String groupID,  String name,  String address,  double? latitude,  double? longitude,  double? geofenceRadiusMeters, @ClientCreatedTimestamp()  DateTime? createdDateTime, @ClientUpdatedTimestamp()  DateTime? updatedDateTime, @ServerCreatedTimestamp()  DateTime? serverCreatedDateTime, @ServerUpdatedTimestamp()  DateTime? serverUpdatedDateTime)  $default,) {final _that = this;
switch (_that) {
case _GroupShoppingLocation():
return $default(_that.id,_that.groupID,_that.name,_that.address,_that.latitude,_that.longitude,_that.geofenceRadiusMeters,_that.createdDateTime,_that.updatedDateTime,_that.serverCreatedDateTime,_that.serverUpdatedDateTime);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String groupID,  String name,  String address,  double? latitude,  double? longitude,  double? geofenceRadiusMeters, @ClientCreatedTimestamp()  DateTime? createdDateTime, @ClientUpdatedTimestamp()  DateTime? updatedDateTime, @ServerCreatedTimestamp()  DateTime? serverCreatedDateTime, @ServerUpdatedTimestamp()  DateTime? serverUpdatedDateTime)?  $default,) {final _that = this;
switch (_that) {
case _GroupShoppingLocation() when $default != null:
return $default(_that.id,_that.groupID,_that.name,_that.address,_that.latitude,_that.longitude,_that.geofenceRadiusMeters,_that.createdDateTime,_that.updatedDateTime,_that.serverCreatedDateTime,_that.serverUpdatedDateTime);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _GroupShoppingLocation extends GroupShoppingLocation {
  const _GroupShoppingLocation({required this.id, required this.groupID, required this.name, this.address = '', required this.latitude, required this.longitude, required this.geofenceRadiusMeters, @ClientCreatedTimestamp() this.createdDateTime, @ClientUpdatedTimestamp() this.updatedDateTime, @ServerCreatedTimestamp() this.serverCreatedDateTime, @ServerUpdatedTimestamp() this.serverUpdatedDateTime}): super._();
  factory _GroupShoppingLocation.fromJson(Map<String, dynamic> json) => _$GroupShoppingLocationFromJson(json);

@override final  String id;
@override final  String groupID;
@override final  String name;
/// 逆ジオコードで取得した住所文字列。LocationPicker (PRO 限定地図設定) で
/// 緯度経度を確定したときに保存し、無料機能で場所名のみ登録した際は空文字。
/// 既存ドキュメントにはこのフィールドが存在しないため default で空文字。
@override@JsonKey() final  String address;
/// 店舗の緯度。nullの場合はジオフェンス対象外。
@override final  double? latitude;
/// 店舗の経度。nullの場合はジオフェンス対象外。
@override final  double? longitude;
/// ジオフェンスの半径（メートル単位）。nullの場合はデフォルト値を使用する。
@override final  double? geofenceRadiusMeters;
@override@ClientCreatedTimestamp() final  DateTime? createdDateTime;
@override@ClientUpdatedTimestamp() final  DateTime? updatedDateTime;
@override@ServerCreatedTimestamp() final  DateTime? serverCreatedDateTime;
@override@ServerUpdatedTimestamp() final  DateTime? serverUpdatedDateTime;

/// Create a copy of GroupShoppingLocation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroupShoppingLocationCopyWith<_GroupShoppingLocation> get copyWith => __$GroupShoppingLocationCopyWithImpl<_GroupShoppingLocation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GroupShoppingLocationToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroupShoppingLocation&&(identical(other.id, id) || other.id == id)&&(identical(other.groupID, groupID) || other.groupID == groupID)&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.geofenceRadiusMeters, geofenceRadiusMeters) || other.geofenceRadiusMeters == geofenceRadiusMeters)&&(identical(other.createdDateTime, createdDateTime) || other.createdDateTime == createdDateTime)&&(identical(other.updatedDateTime, updatedDateTime) || other.updatedDateTime == updatedDateTime)&&(identical(other.serverCreatedDateTime, serverCreatedDateTime) || other.serverCreatedDateTime == serverCreatedDateTime)&&(identical(other.serverUpdatedDateTime, serverUpdatedDateTime) || other.serverUpdatedDateTime == serverUpdatedDateTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,groupID,name,address,latitude,longitude,geofenceRadiusMeters,createdDateTime,updatedDateTime,serverCreatedDateTime,serverUpdatedDateTime);
}

@override
String toString() {
    return 'GroupShoppingLocation(id: $id, groupID: $groupID, name: $name, address: $address, latitude: $latitude, longitude: $longitude, geofenceRadiusMeters: $geofenceRadiusMeters, createdDateTime: $createdDateTime, updatedDateTime: $updatedDateTime, serverCreatedDateTime: $serverCreatedDateTime, serverUpdatedDateTime: $serverUpdatedDateTime)';
}


}

/// @nodoc
abstract mixin class _$GroupShoppingLocationCopyWith<$Res> implements $GroupShoppingLocationCopyWith<$Res> {
  factory _$GroupShoppingLocationCopyWith(_GroupShoppingLocation value, $Res Function(_GroupShoppingLocation) _then) = __$GroupShoppingLocationCopyWithImpl;
@override @useResult
$Res call({
 String id, String groupID, String name, String address, double? latitude, double? longitude, double? geofenceRadiusMeters,@ClientCreatedTimestamp() DateTime? createdDateTime,@ClientUpdatedTimestamp() DateTime? updatedDateTime,@ServerCreatedTimestamp() DateTime? serverCreatedDateTime,@ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime
});




}
/// @nodoc
class __$GroupShoppingLocationCopyWithImpl<$Res>
    implements _$GroupShoppingLocationCopyWith<$Res> {
  __$GroupShoppingLocationCopyWithImpl(this._self, this._then);

  final _GroupShoppingLocation _self;
  final $Res Function(_GroupShoppingLocation) _then;

/// Create a copy of GroupShoppingLocation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? groupID = null,Object? name = null,Object? address = null,Object? latitude = freezed,Object? longitude = freezed,Object? geofenceRadiusMeters = freezed,Object? createdDateTime = freezed,Object? updatedDateTime = freezed,Object? serverCreatedDateTime = freezed,Object? serverUpdatedDateTime = freezed,}) {
  return _then(_GroupShoppingLocation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,groupID: null == groupID ? _self.groupID : groupID // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,geofenceRadiusMeters: freezed == geofenceRadiusMeters ? _self.geofenceRadiusMeters : geofenceRadiusMeters // ignore: cast_nullable_to_non_nullable
as double?,createdDateTime: freezed == createdDateTime ? _self.createdDateTime : createdDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedDateTime: freezed == updatedDateTime ? _self.updatedDateTime : updatedDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,serverCreatedDateTime: freezed == serverCreatedDateTime ? _self.serverCreatedDateTime : serverCreatedDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,serverUpdatedDateTime: freezed == serverUpdatedDateTime ? _self.serverUpdatedDateTime : serverUpdatedDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
