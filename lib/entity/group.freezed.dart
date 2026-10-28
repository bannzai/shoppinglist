// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Group {

 String get id;/// グループに所属するユーザーのAppUser.idの配列
 List<String> get memberUserIDs;/// グループ名
 String? get name;/// グループを作成したユーザーのAppUser.id
/// NOTE: 既存のグループドキュメントにはこのフィールドが存在しない場合があるためnullable
 String? get ownerUserID;/// グループに紐づくアイコンの識別子。
/// `design_handoff_shoppinglist/preview/screens-groups.jsx` の GroupCreatePage で
/// 選択する 6 種 (`home` / `cart` / `fork` / `cookie` / `pets` / `bag`) のいずれか。
/// 既存ドキュメントにはこのフィールドが存在しないため default で `home` を返す。
 String get iconName;@ClientCreatedTimestamp() DateTime? get createdDateTime;@ClientUpdatedTimestamp() DateTime? get updatedDateTime;@ServerCreatedTimestamp() DateTime? get serverCreatedDateTime;@ServerUpdatedTimestamp() DateTime? get serverUpdatedDateTime;
/// Create a copy of Group
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupCopyWith<Group> get copyWith => _$GroupCopyWithImpl<Group>(this as Group, _$identity);

  /// Serializes this Group to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Group;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Group&&(identical(other.id, _this.id) || other.id == _this.id)&&const DeepCollectionEquality().equals(other.memberUserIDs, _this.memberUserIDs)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.ownerUserID, _this.ownerUserID) || other.ownerUserID == _this.ownerUserID)&&(identical(other.iconName, _this.iconName) || other.iconName == _this.iconName)&&(identical(other.createdDateTime, _this.createdDateTime) || other.createdDateTime == _this.createdDateTime)&&(identical(other.updatedDateTime, _this.updatedDateTime) || other.updatedDateTime == _this.updatedDateTime)&&(identical(other.serverCreatedDateTime, _this.serverCreatedDateTime) || other.serverCreatedDateTime == _this.serverCreatedDateTime)&&(identical(other.serverUpdatedDateTime, _this.serverUpdatedDateTime) || other.serverUpdatedDateTime == _this.serverUpdatedDateTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Group;
  return Object.hash(runtimeType,_this.id,const DeepCollectionEquality().hash(_this.memberUserIDs),_this.name,_this.ownerUserID,_this.iconName,_this.createdDateTime,_this.updatedDateTime,_this.serverCreatedDateTime,_this.serverUpdatedDateTime);
}

@override
String toString() {
  final _this = this as Group;
  return 'Group(id: ${_this.id}, memberUserIDs: ${_this.memberUserIDs}, name: ${_this.name}, ownerUserID: ${_this.ownerUserID}, iconName: ${_this.iconName}, createdDateTime: ${_this.createdDateTime}, updatedDateTime: ${_this.updatedDateTime}, serverCreatedDateTime: ${_this.serverCreatedDateTime}, serverUpdatedDateTime: ${_this.serverUpdatedDateTime})';
}


}

/// @nodoc
abstract mixin class $GroupCopyWith<$Res>  {
  factory $GroupCopyWith(Group value, $Res Function(Group) _then) = _$GroupCopyWithImpl;
@useResult
$Res call({
 String id, List<String> memberUserIDs, String? name, String? ownerUserID, String iconName,@ClientCreatedTimestamp() DateTime? createdDateTime,@ClientUpdatedTimestamp() DateTime? updatedDateTime,@ServerCreatedTimestamp() DateTime? serverCreatedDateTime,@ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime
});




}
/// @nodoc
class _$GroupCopyWithImpl<$Res>
    implements $GroupCopyWith<$Res> {
  _$GroupCopyWithImpl(this._self, this._then);

  final Group _self;
  final $Res Function(Group) _then;

/// Create a copy of Group
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? memberUserIDs = null,Object? name = freezed,Object? ownerUserID = freezed,Object? iconName = null,Object? createdDateTime = freezed,Object? updatedDateTime = freezed,Object? serverCreatedDateTime = freezed,Object? serverUpdatedDateTime = freezed,}) {
  return _then(Group(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,memberUserIDs: null == memberUserIDs ? _self.memberUserIDs : memberUserIDs // ignore: cast_nullable_to_non_nullable
as List<String>,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,ownerUserID: freezed == ownerUserID ? _self.ownerUserID : ownerUserID // ignore: cast_nullable_to_non_nullable
as String?,iconName: null == iconName ? _self.iconName : iconName // ignore: cast_nullable_to_non_nullable
as String,createdDateTime: freezed == createdDateTime ? _self.createdDateTime : createdDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedDateTime: freezed == updatedDateTime ? _self.updatedDateTime : updatedDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,serverCreatedDateTime: freezed == serverCreatedDateTime ? _self.serverCreatedDateTime : serverCreatedDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,serverUpdatedDateTime: freezed == serverUpdatedDateTime ? _self.serverUpdatedDateTime : serverUpdatedDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Group].
extension GroupPatterns on Group {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Group value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Group() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Group value)  $default,){
final _that = this;
switch (_that) {
case _Group():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Group value)?  $default,){
final _that = this;
switch (_that) {
case _Group() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  List<String> memberUserIDs,  String? name,  String? ownerUserID,  String iconName, @ClientCreatedTimestamp()  DateTime? createdDateTime, @ClientUpdatedTimestamp()  DateTime? updatedDateTime, @ServerCreatedTimestamp()  DateTime? serverCreatedDateTime, @ServerUpdatedTimestamp()  DateTime? serverUpdatedDateTime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Group() when $default != null:
return $default(_that.id,_that.memberUserIDs,_that.name,_that.ownerUserID,_that.iconName,_that.createdDateTime,_that.updatedDateTime,_that.serverCreatedDateTime,_that.serverUpdatedDateTime);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  List<String> memberUserIDs,  String? name,  String? ownerUserID,  String iconName, @ClientCreatedTimestamp()  DateTime? createdDateTime, @ClientUpdatedTimestamp()  DateTime? updatedDateTime, @ServerCreatedTimestamp()  DateTime? serverCreatedDateTime, @ServerUpdatedTimestamp()  DateTime? serverUpdatedDateTime)  $default,) {final _that = this;
switch (_that) {
case _Group():
return $default(_that.id,_that.memberUserIDs,_that.name,_that.ownerUserID,_that.iconName,_that.createdDateTime,_that.updatedDateTime,_that.serverCreatedDateTime,_that.serverUpdatedDateTime);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  List<String> memberUserIDs,  String? name,  String? ownerUserID,  String iconName, @ClientCreatedTimestamp()  DateTime? createdDateTime, @ClientUpdatedTimestamp()  DateTime? updatedDateTime, @ServerCreatedTimestamp()  DateTime? serverCreatedDateTime, @ServerUpdatedTimestamp()  DateTime? serverUpdatedDateTime)?  $default,) {final _that = this;
switch (_that) {
case _Group() when $default != null:
return $default(_that.id,_that.memberUserIDs,_that.name,_that.ownerUserID,_that.iconName,_that.createdDateTime,_that.updatedDateTime,_that.serverCreatedDateTime,_that.serverUpdatedDateTime);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _Group extends Group {
  const _Group({required this.id, required  List<String> memberUserIDs, required this.name, this.ownerUserID, this.iconName = 'home', @ClientCreatedTimestamp() this.createdDateTime, @ClientUpdatedTimestamp() this.updatedDateTime, @ServerCreatedTimestamp() this.serverCreatedDateTime, @ServerUpdatedTimestamp() this.serverUpdatedDateTime}): _memberUserIDs = memberUserIDs,super._();
  factory _Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);

@override final  String id;
/// グループに所属するユーザーのAppUser.idの配列
 final  List<String> _memberUserIDs;
/// グループに所属するユーザーのAppUser.idの配列
@override List<String> get memberUserIDs {
  if (_memberUserIDs is EqualUnmodifiableListView) return _memberUserIDs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_memberUserIDs);
}

/// グループ名
@override final  String? name;
/// グループを作成したユーザーのAppUser.id
/// NOTE: 既存のグループドキュメントにはこのフィールドが存在しない場合があるためnullable
@override final  String? ownerUserID;
/// グループに紐づくアイコンの識別子。
/// `design_handoff_shoppinglist/preview/screens-groups.jsx` の GroupCreatePage で
/// 選択する 6 種 (`home` / `cart` / `fork` / `cookie` / `pets` / `bag`) のいずれか。
/// 既存ドキュメントにはこのフィールドが存在しないため default で `home` を返す。
@override@JsonKey() final  String iconName;
@override@ClientCreatedTimestamp() final  DateTime? createdDateTime;
@override@ClientUpdatedTimestamp() final  DateTime? updatedDateTime;
@override@ServerCreatedTimestamp() final  DateTime? serverCreatedDateTime;
@override@ServerUpdatedTimestamp() final  DateTime? serverUpdatedDateTime;

/// Create a copy of Group
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroupCopyWith<_Group> get copyWith => __$GroupCopyWithImpl<_Group>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GroupToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Group&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.memberUserIDs, _memberUserIDs)&&(identical(other.name, name) || other.name == name)&&(identical(other.ownerUserID, ownerUserID) || other.ownerUserID == ownerUserID)&&(identical(other.iconName, iconName) || other.iconName == iconName)&&(identical(other.createdDateTime, createdDateTime) || other.createdDateTime == createdDateTime)&&(identical(other.updatedDateTime, updatedDateTime) || other.updatedDateTime == updatedDateTime)&&(identical(other.serverCreatedDateTime, serverCreatedDateTime) || other.serverCreatedDateTime == serverCreatedDateTime)&&(identical(other.serverUpdatedDateTime, serverUpdatedDateTime) || other.serverUpdatedDateTime == serverUpdatedDateTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,const DeepCollectionEquality().hash(_memberUserIDs),name,ownerUserID,iconName,createdDateTime,updatedDateTime,serverCreatedDateTime,serverUpdatedDateTime);
}

@override
String toString() {
    return 'Group(id: $id, memberUserIDs: $memberUserIDs, name: $name, ownerUserID: $ownerUserID, iconName: $iconName, createdDateTime: $createdDateTime, updatedDateTime: $updatedDateTime, serverCreatedDateTime: $serverCreatedDateTime, serverUpdatedDateTime: $serverUpdatedDateTime)';
}


}

/// @nodoc
abstract mixin class _$GroupCopyWith<$Res> implements $GroupCopyWith<$Res> {
  factory _$GroupCopyWith(_Group value, $Res Function(_Group) _then) = __$GroupCopyWithImpl;
@override @useResult
$Res call({
 String id, List<String> memberUserIDs, String? name, String? ownerUserID, String iconName,@ClientCreatedTimestamp() DateTime? createdDateTime,@ClientUpdatedTimestamp() DateTime? updatedDateTime,@ServerCreatedTimestamp() DateTime? serverCreatedDateTime,@ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime
});




}
/// @nodoc
class __$GroupCopyWithImpl<$Res>
    implements _$GroupCopyWith<$Res> {
  __$GroupCopyWithImpl(this._self, this._then);

  final _Group _self;
  final $Res Function(_Group) _then;

/// Create a copy of Group
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? memberUserIDs = null,Object? name = freezed,Object? ownerUserID = freezed,Object? iconName = null,Object? createdDateTime = freezed,Object? updatedDateTime = freezed,Object? serverCreatedDateTime = freezed,Object? serverUpdatedDateTime = freezed,}) {
  return _then(_Group(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,memberUserIDs: null == memberUserIDs ? _self._memberUserIDs : memberUserIDs // ignore: cast_nullable_to_non_nullable
as List<String>,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,ownerUserID: freezed == ownerUserID ? _self.ownerUserID : ownerUserID // ignore: cast_nullable_to_non_nullable
as String?,iconName: null == iconName ? _self.iconName : iconName // ignore: cast_nullable_to_non_nullable
as String,createdDateTime: freezed == createdDateTime ? _self.createdDateTime : createdDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedDateTime: freezed == updatedDateTime ? _self.updatedDateTime : updatedDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,serverCreatedDateTime: freezed == serverCreatedDateTime ? _self.serverCreatedDateTime : serverCreatedDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,serverUpdatedDateTime: freezed == serverUpdatedDateTime ? _self.serverUpdatedDateTime : serverUpdatedDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
