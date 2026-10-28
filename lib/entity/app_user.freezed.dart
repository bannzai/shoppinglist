// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppUser {

 String get id; String? get defaultGroupID; String? get name; String? get iconImageURL; String? get themeColorHex; String? get developerToken;@ClientCreatedTimestamp() DateTime? get createdDateTime;@ClientUpdatedTimestamp() DateTime? get updatedDateTime;@ServerCreatedTimestamp() DateTime? get serverCreatedDateTime;@ServerUpdatedTimestamp() DateTime? get serverUpdatedDateTime;
/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppUserCopyWith<AppUser> get copyWith => _$AppUserCopyWithImpl<AppUser>(this as AppUser, _$identity);

  /// Serializes this AppUser to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AppUser;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppUser&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.defaultGroupID, _this.defaultGroupID) || other.defaultGroupID == _this.defaultGroupID)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.iconImageURL, _this.iconImageURL) || other.iconImageURL == _this.iconImageURL)&&(identical(other.themeColorHex, _this.themeColorHex) || other.themeColorHex == _this.themeColorHex)&&(identical(other.developerToken, _this.developerToken) || other.developerToken == _this.developerToken)&&(identical(other.createdDateTime, _this.createdDateTime) || other.createdDateTime == _this.createdDateTime)&&(identical(other.updatedDateTime, _this.updatedDateTime) || other.updatedDateTime == _this.updatedDateTime)&&(identical(other.serverCreatedDateTime, _this.serverCreatedDateTime) || other.serverCreatedDateTime == _this.serverCreatedDateTime)&&(identical(other.serverUpdatedDateTime, _this.serverUpdatedDateTime) || other.serverUpdatedDateTime == _this.serverUpdatedDateTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AppUser;
  return Object.hash(runtimeType,_this.id,_this.defaultGroupID,_this.name,_this.iconImageURL,_this.themeColorHex,_this.developerToken,_this.createdDateTime,_this.updatedDateTime,_this.serverCreatedDateTime,_this.serverUpdatedDateTime);
}

@override
String toString() {
  final _this = this as AppUser;
  return 'AppUser(id: ${_this.id}, defaultGroupID: ${_this.defaultGroupID}, name: ${_this.name}, iconImageURL: ${_this.iconImageURL}, themeColorHex: ${_this.themeColorHex}, developerToken: ${_this.developerToken}, createdDateTime: ${_this.createdDateTime}, updatedDateTime: ${_this.updatedDateTime}, serverCreatedDateTime: ${_this.serverCreatedDateTime}, serverUpdatedDateTime: ${_this.serverUpdatedDateTime})';
}


}

/// @nodoc
abstract mixin class $AppUserCopyWith<$Res>  {
  factory $AppUserCopyWith(AppUser value, $Res Function(AppUser) _then) = _$AppUserCopyWithImpl;
@useResult
$Res call({
 String id, String? defaultGroupID, String? name, String? iconImageURL, String? themeColorHex, String? developerToken,@ClientCreatedTimestamp() DateTime? createdDateTime,@ClientUpdatedTimestamp() DateTime? updatedDateTime,@ServerCreatedTimestamp() DateTime? serverCreatedDateTime,@ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime
});




}
/// @nodoc
class _$AppUserCopyWithImpl<$Res>
    implements $AppUserCopyWith<$Res> {
  _$AppUserCopyWithImpl(this._self, this._then);

  final AppUser _self;
  final $Res Function(AppUser) _then;

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? defaultGroupID = freezed,Object? name = freezed,Object? iconImageURL = freezed,Object? themeColorHex = freezed,Object? developerToken = freezed,Object? createdDateTime = freezed,Object? updatedDateTime = freezed,Object? serverCreatedDateTime = freezed,Object? serverUpdatedDateTime = freezed,}) {
  return _then(AppUser(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,defaultGroupID: freezed == defaultGroupID ? _self.defaultGroupID : defaultGroupID // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,iconImageURL: freezed == iconImageURL ? _self.iconImageURL : iconImageURL // ignore: cast_nullable_to_non_nullable
as String?,themeColorHex: freezed == themeColorHex ? _self.themeColorHex : themeColorHex // ignore: cast_nullable_to_non_nullable
as String?,developerToken: freezed == developerToken ? _self.developerToken : developerToken // ignore: cast_nullable_to_non_nullable
as String?,createdDateTime: freezed == createdDateTime ? _self.createdDateTime : createdDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedDateTime: freezed == updatedDateTime ? _self.updatedDateTime : updatedDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,serverCreatedDateTime: freezed == serverCreatedDateTime ? _self.serverCreatedDateTime : serverCreatedDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,serverUpdatedDateTime: freezed == serverUpdatedDateTime ? _self.serverUpdatedDateTime : serverUpdatedDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [AppUser].
extension AppUserPatterns on AppUser {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppUser() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppUser value)  $default,){
final _that = this;
switch (_that) {
case _AppUser():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppUser value)?  $default,){
final _that = this;
switch (_that) {
case _AppUser() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? defaultGroupID,  String? name,  String? iconImageURL,  String? themeColorHex,  String? developerToken, @ClientCreatedTimestamp()  DateTime? createdDateTime, @ClientUpdatedTimestamp()  DateTime? updatedDateTime, @ServerCreatedTimestamp()  DateTime? serverCreatedDateTime, @ServerUpdatedTimestamp()  DateTime? serverUpdatedDateTime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppUser() when $default != null:
return $default(_that.id,_that.defaultGroupID,_that.name,_that.iconImageURL,_that.themeColorHex,_that.developerToken,_that.createdDateTime,_that.updatedDateTime,_that.serverCreatedDateTime,_that.serverUpdatedDateTime);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? defaultGroupID,  String? name,  String? iconImageURL,  String? themeColorHex,  String? developerToken, @ClientCreatedTimestamp()  DateTime? createdDateTime, @ClientUpdatedTimestamp()  DateTime? updatedDateTime, @ServerCreatedTimestamp()  DateTime? serverCreatedDateTime, @ServerUpdatedTimestamp()  DateTime? serverUpdatedDateTime)  $default,) {final _that = this;
switch (_that) {
case _AppUser():
return $default(_that.id,_that.defaultGroupID,_that.name,_that.iconImageURL,_that.themeColorHex,_that.developerToken,_that.createdDateTime,_that.updatedDateTime,_that.serverCreatedDateTime,_that.serverUpdatedDateTime);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? defaultGroupID,  String? name,  String? iconImageURL,  String? themeColorHex,  String? developerToken, @ClientCreatedTimestamp()  DateTime? createdDateTime, @ClientUpdatedTimestamp()  DateTime? updatedDateTime, @ServerCreatedTimestamp()  DateTime? serverCreatedDateTime, @ServerUpdatedTimestamp()  DateTime? serverUpdatedDateTime)?  $default,) {final _that = this;
switch (_that) {
case _AppUser() when $default != null:
return $default(_that.id,_that.defaultGroupID,_that.name,_that.iconImageURL,_that.themeColorHex,_that.developerToken,_that.createdDateTime,_that.updatedDateTime,_that.serverCreatedDateTime,_that.serverUpdatedDateTime);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _AppUser extends AppUser {
  const _AppUser({required this.id, this.defaultGroupID, this.name, this.iconImageURL, this.themeColorHex, this.developerToken, @ClientCreatedTimestamp() this.createdDateTime, @ClientUpdatedTimestamp() this.updatedDateTime, @ServerCreatedTimestamp() this.serverCreatedDateTime, @ServerUpdatedTimestamp() this.serverUpdatedDateTime}): super._();
  factory _AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);

@override final  String id;
@override final  String? defaultGroupID;
@override final  String? name;
@override final  String? iconImageURL;
@override final  String? themeColorHex;
@override final  String? developerToken;
@override@ClientCreatedTimestamp() final  DateTime? createdDateTime;
@override@ClientUpdatedTimestamp() final  DateTime? updatedDateTime;
@override@ServerCreatedTimestamp() final  DateTime? serverCreatedDateTime;
@override@ServerUpdatedTimestamp() final  DateTime? serverUpdatedDateTime;

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppUserCopyWith<_AppUser> get copyWith => __$AppUserCopyWithImpl<_AppUser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppUserToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppUser&&(identical(other.id, id) || other.id == id)&&(identical(other.defaultGroupID, defaultGroupID) || other.defaultGroupID == defaultGroupID)&&(identical(other.name, name) || other.name == name)&&(identical(other.iconImageURL, iconImageURL) || other.iconImageURL == iconImageURL)&&(identical(other.themeColorHex, themeColorHex) || other.themeColorHex == themeColorHex)&&(identical(other.developerToken, developerToken) || other.developerToken == developerToken)&&(identical(other.createdDateTime, createdDateTime) || other.createdDateTime == createdDateTime)&&(identical(other.updatedDateTime, updatedDateTime) || other.updatedDateTime == updatedDateTime)&&(identical(other.serverCreatedDateTime, serverCreatedDateTime) || other.serverCreatedDateTime == serverCreatedDateTime)&&(identical(other.serverUpdatedDateTime, serverUpdatedDateTime) || other.serverUpdatedDateTime == serverUpdatedDateTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,defaultGroupID,name,iconImageURL,themeColorHex,developerToken,createdDateTime,updatedDateTime,serverCreatedDateTime,serverUpdatedDateTime);
}

@override
String toString() {
    return 'AppUser(id: $id, defaultGroupID: $defaultGroupID, name: $name, iconImageURL: $iconImageURL, themeColorHex: $themeColorHex, developerToken: $developerToken, createdDateTime: $createdDateTime, updatedDateTime: $updatedDateTime, serverCreatedDateTime: $serverCreatedDateTime, serverUpdatedDateTime: $serverUpdatedDateTime)';
}


}

/// @nodoc
abstract mixin class _$AppUserCopyWith<$Res> implements $AppUserCopyWith<$Res> {
  factory _$AppUserCopyWith(_AppUser value, $Res Function(_AppUser) _then) = __$AppUserCopyWithImpl;
@override @useResult
$Res call({
 String id, String? defaultGroupID, String? name, String? iconImageURL, String? themeColorHex, String? developerToken,@ClientCreatedTimestamp() DateTime? createdDateTime,@ClientUpdatedTimestamp() DateTime? updatedDateTime,@ServerCreatedTimestamp() DateTime? serverCreatedDateTime,@ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime
});




}
/// @nodoc
class __$AppUserCopyWithImpl<$Res>
    implements _$AppUserCopyWith<$Res> {
  __$AppUserCopyWithImpl(this._self, this._then);

  final _AppUser _self;
  final $Res Function(_AppUser) _then;

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? defaultGroupID = freezed,Object? name = freezed,Object? iconImageURL = freezed,Object? themeColorHex = freezed,Object? developerToken = freezed,Object? createdDateTime = freezed,Object? updatedDateTime = freezed,Object? serverCreatedDateTime = freezed,Object? serverUpdatedDateTime = freezed,}) {
  return _then(_AppUser(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,defaultGroupID: freezed == defaultGroupID ? _self.defaultGroupID : defaultGroupID // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,iconImageURL: freezed == iconImageURL ? _self.iconImageURL : iconImageURL // ignore: cast_nullable_to_non_nullable
as String?,themeColorHex: freezed == themeColorHex ? _self.themeColorHex : themeColorHex // ignore: cast_nullable_to_non_nullable
as String?,developerToken: freezed == developerToken ? _self.developerToken : developerToken // ignore: cast_nullable_to_non_nullable
as String?,createdDateTime: freezed == createdDateTime ? _self.createdDateTime : createdDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedDateTime: freezed == updatedDateTime ? _self.updatedDateTime : updatedDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,serverCreatedDateTime: freezed == serverCreatedDateTime ? _self.serverCreatedDateTime : serverCreatedDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,serverUpdatedDateTime: freezed == serverUpdatedDateTime ? _self.serverUpdatedDateTime : serverUpdatedDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
