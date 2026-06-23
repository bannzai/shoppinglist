// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group_shopping_list.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GroupShoppingList {

 String get id; String get createUserID; String get groupID; String get name; GroupShoppingListStatus get status; String? get shoppingLocationID; String? get duplicatedFromGroupShoppingListID;@TimestampConverter() DateTime? get ttlExpiresDateTime;@ClientCreatedTimestamp() DateTime? get createdDateTime;@ClientUpdatedTimestamp() DateTime? get updatedDateTime;@ServerCreatedTimestamp() DateTime? get serverCreatedDateTime;@ServerUpdatedTimestamp() DateTime? get serverUpdatedDateTime;
/// Create a copy of GroupShoppingList
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupShoppingListCopyWith<GroupShoppingList> get copyWith => _$GroupShoppingListCopyWithImpl<GroupShoppingList>(this as GroupShoppingList, _$identity);

  /// Serializes this GroupShoppingList to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroupShoppingList&&(identical(other.id, id) || other.id == id)&&(identical(other.createUserID, createUserID) || other.createUserID == createUserID)&&(identical(other.groupID, groupID) || other.groupID == groupID)&&(identical(other.name, name) || other.name == name)&&(identical(other.status, status) || other.status == status)&&(identical(other.shoppingLocationID, shoppingLocationID) || other.shoppingLocationID == shoppingLocationID)&&(identical(other.duplicatedFromGroupShoppingListID, duplicatedFromGroupShoppingListID) || other.duplicatedFromGroupShoppingListID == duplicatedFromGroupShoppingListID)&&(identical(other.ttlExpiresDateTime, ttlExpiresDateTime) || other.ttlExpiresDateTime == ttlExpiresDateTime)&&(identical(other.createdDateTime, createdDateTime) || other.createdDateTime == createdDateTime)&&(identical(other.updatedDateTime, updatedDateTime) || other.updatedDateTime == updatedDateTime)&&(identical(other.serverCreatedDateTime, serverCreatedDateTime) || other.serverCreatedDateTime == serverCreatedDateTime)&&(identical(other.serverUpdatedDateTime, serverUpdatedDateTime) || other.serverUpdatedDateTime == serverUpdatedDateTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,createUserID,groupID,name,status,shoppingLocationID,duplicatedFromGroupShoppingListID,ttlExpiresDateTime,createdDateTime,updatedDateTime,serverCreatedDateTime,serverUpdatedDateTime);

@override
String toString() {
  return 'GroupShoppingList(id: $id, createUserID: $createUserID, groupID: $groupID, name: $name, status: $status, shoppingLocationID: $shoppingLocationID, duplicatedFromGroupShoppingListID: $duplicatedFromGroupShoppingListID, ttlExpiresDateTime: $ttlExpiresDateTime, createdDateTime: $createdDateTime, updatedDateTime: $updatedDateTime, serverCreatedDateTime: $serverCreatedDateTime, serverUpdatedDateTime: $serverUpdatedDateTime)';
}


}

/// @nodoc
abstract mixin class $GroupShoppingListCopyWith<$Res>  {
  factory $GroupShoppingListCopyWith(GroupShoppingList value, $Res Function(GroupShoppingList) _then) = _$GroupShoppingListCopyWithImpl;
@useResult
$Res call({
 String id, String createUserID, String groupID, String name, GroupShoppingListStatus status, String? shoppingLocationID, String? duplicatedFromGroupShoppingListID,@TimestampConverter() DateTime? ttlExpiresDateTime,@ClientCreatedTimestamp() DateTime? createdDateTime,@ClientUpdatedTimestamp() DateTime? updatedDateTime,@ServerCreatedTimestamp() DateTime? serverCreatedDateTime,@ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime
});




}
/// @nodoc
class _$GroupShoppingListCopyWithImpl<$Res>
    implements $GroupShoppingListCopyWith<$Res> {
  _$GroupShoppingListCopyWithImpl(this._self, this._then);

  final GroupShoppingList _self;
  final $Res Function(GroupShoppingList) _then;

/// Create a copy of GroupShoppingList
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? createUserID = null,Object? groupID = null,Object? name = null,Object? status = null,Object? shoppingLocationID = freezed,Object? duplicatedFromGroupShoppingListID = freezed,Object? ttlExpiresDateTime = freezed,Object? createdDateTime = freezed,Object? updatedDateTime = freezed,Object? serverCreatedDateTime = freezed,Object? serverUpdatedDateTime = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,createUserID: null == createUserID ? _self.createUserID : createUserID // ignore: cast_nullable_to_non_nullable
as String,groupID: null == groupID ? _self.groupID : groupID // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as GroupShoppingListStatus,shoppingLocationID: freezed == shoppingLocationID ? _self.shoppingLocationID : shoppingLocationID // ignore: cast_nullable_to_non_nullable
as String?,duplicatedFromGroupShoppingListID: freezed == duplicatedFromGroupShoppingListID ? _self.duplicatedFromGroupShoppingListID : duplicatedFromGroupShoppingListID // ignore: cast_nullable_to_non_nullable
as String?,ttlExpiresDateTime: freezed == ttlExpiresDateTime ? _self.ttlExpiresDateTime : ttlExpiresDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,createdDateTime: freezed == createdDateTime ? _self.createdDateTime : createdDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedDateTime: freezed == updatedDateTime ? _self.updatedDateTime : updatedDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,serverCreatedDateTime: freezed == serverCreatedDateTime ? _self.serverCreatedDateTime : serverCreatedDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,serverUpdatedDateTime: freezed == serverUpdatedDateTime ? _self.serverUpdatedDateTime : serverUpdatedDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [GroupShoppingList].
extension GroupShoppingListPatterns on GroupShoppingList {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroupShoppingList value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroupShoppingList() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroupShoppingList value)  $default,){
final _that = this;
switch (_that) {
case _GroupShoppingList():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroupShoppingList value)?  $default,){
final _that = this;
switch (_that) {
case _GroupShoppingList() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String createUserID,  String groupID,  String name,  GroupShoppingListStatus status,  String? shoppingLocationID,  String? duplicatedFromGroupShoppingListID, @TimestampConverter()  DateTime? ttlExpiresDateTime, @ClientCreatedTimestamp()  DateTime? createdDateTime, @ClientUpdatedTimestamp()  DateTime? updatedDateTime, @ServerCreatedTimestamp()  DateTime? serverCreatedDateTime, @ServerUpdatedTimestamp()  DateTime? serverUpdatedDateTime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroupShoppingList() when $default != null:
return $default(_that.id,_that.createUserID,_that.groupID,_that.name,_that.status,_that.shoppingLocationID,_that.duplicatedFromGroupShoppingListID,_that.ttlExpiresDateTime,_that.createdDateTime,_that.updatedDateTime,_that.serverCreatedDateTime,_that.serverUpdatedDateTime);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String createUserID,  String groupID,  String name,  GroupShoppingListStatus status,  String? shoppingLocationID,  String? duplicatedFromGroupShoppingListID, @TimestampConverter()  DateTime? ttlExpiresDateTime, @ClientCreatedTimestamp()  DateTime? createdDateTime, @ClientUpdatedTimestamp()  DateTime? updatedDateTime, @ServerCreatedTimestamp()  DateTime? serverCreatedDateTime, @ServerUpdatedTimestamp()  DateTime? serverUpdatedDateTime)  $default,) {final _that = this;
switch (_that) {
case _GroupShoppingList():
return $default(_that.id,_that.createUserID,_that.groupID,_that.name,_that.status,_that.shoppingLocationID,_that.duplicatedFromGroupShoppingListID,_that.ttlExpiresDateTime,_that.createdDateTime,_that.updatedDateTime,_that.serverCreatedDateTime,_that.serverUpdatedDateTime);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String createUserID,  String groupID,  String name,  GroupShoppingListStatus status,  String? shoppingLocationID,  String? duplicatedFromGroupShoppingListID, @TimestampConverter()  DateTime? ttlExpiresDateTime, @ClientCreatedTimestamp()  DateTime? createdDateTime, @ClientUpdatedTimestamp()  DateTime? updatedDateTime, @ServerCreatedTimestamp()  DateTime? serverCreatedDateTime, @ServerUpdatedTimestamp()  DateTime? serverUpdatedDateTime)?  $default,) {final _that = this;
switch (_that) {
case _GroupShoppingList() when $default != null:
return $default(_that.id,_that.createUserID,_that.groupID,_that.name,_that.status,_that.shoppingLocationID,_that.duplicatedFromGroupShoppingListID,_that.ttlExpiresDateTime,_that.createdDateTime,_that.updatedDateTime,_that.serverCreatedDateTime,_that.serverUpdatedDateTime);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _GroupShoppingList extends GroupShoppingList {
  const _GroupShoppingList({required this.id, required this.createUserID, required this.groupID, this.name = '', this.status = GroupShoppingListStatus.active, required this.shoppingLocationID, required this.duplicatedFromGroupShoppingListID, @TimestampConverter() required this.ttlExpiresDateTime, @ClientCreatedTimestamp() this.createdDateTime, @ClientUpdatedTimestamp() this.updatedDateTime, @ServerCreatedTimestamp() this.serverCreatedDateTime, @ServerUpdatedTimestamp() this.serverUpdatedDateTime}): super._();
  factory _GroupShoppingList.fromJson(Map<String, dynamic> json) => _$GroupShoppingListFromJson(json);

@override final  String id;
@override final  String createUserID;
@override final  String groupID;
@override@JsonKey() final  String name;
@override@JsonKey() final  GroupShoppingListStatus status;
@override final  String? shoppingLocationID;
@override final  String? duplicatedFromGroupShoppingListID;
@override@TimestampConverter() final  DateTime? ttlExpiresDateTime;
@override@ClientCreatedTimestamp() final  DateTime? createdDateTime;
@override@ClientUpdatedTimestamp() final  DateTime? updatedDateTime;
@override@ServerCreatedTimestamp() final  DateTime? serverCreatedDateTime;
@override@ServerUpdatedTimestamp() final  DateTime? serverUpdatedDateTime;

/// Create a copy of GroupShoppingList
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroupShoppingListCopyWith<_GroupShoppingList> get copyWith => __$GroupShoppingListCopyWithImpl<_GroupShoppingList>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GroupShoppingListToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroupShoppingList&&(identical(other.id, id) || other.id == id)&&(identical(other.createUserID, createUserID) || other.createUserID == createUserID)&&(identical(other.groupID, groupID) || other.groupID == groupID)&&(identical(other.name, name) || other.name == name)&&(identical(other.status, status) || other.status == status)&&(identical(other.shoppingLocationID, shoppingLocationID) || other.shoppingLocationID == shoppingLocationID)&&(identical(other.duplicatedFromGroupShoppingListID, duplicatedFromGroupShoppingListID) || other.duplicatedFromGroupShoppingListID == duplicatedFromGroupShoppingListID)&&(identical(other.ttlExpiresDateTime, ttlExpiresDateTime) || other.ttlExpiresDateTime == ttlExpiresDateTime)&&(identical(other.createdDateTime, createdDateTime) || other.createdDateTime == createdDateTime)&&(identical(other.updatedDateTime, updatedDateTime) || other.updatedDateTime == updatedDateTime)&&(identical(other.serverCreatedDateTime, serverCreatedDateTime) || other.serverCreatedDateTime == serverCreatedDateTime)&&(identical(other.serverUpdatedDateTime, serverUpdatedDateTime) || other.serverUpdatedDateTime == serverUpdatedDateTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,createUserID,groupID,name,status,shoppingLocationID,duplicatedFromGroupShoppingListID,ttlExpiresDateTime,createdDateTime,updatedDateTime,serverCreatedDateTime,serverUpdatedDateTime);

@override
String toString() {
  return 'GroupShoppingList(id: $id, createUserID: $createUserID, groupID: $groupID, name: $name, status: $status, shoppingLocationID: $shoppingLocationID, duplicatedFromGroupShoppingListID: $duplicatedFromGroupShoppingListID, ttlExpiresDateTime: $ttlExpiresDateTime, createdDateTime: $createdDateTime, updatedDateTime: $updatedDateTime, serverCreatedDateTime: $serverCreatedDateTime, serverUpdatedDateTime: $serverUpdatedDateTime)';
}


}

/// @nodoc
abstract mixin class _$GroupShoppingListCopyWith<$Res> implements $GroupShoppingListCopyWith<$Res> {
  factory _$GroupShoppingListCopyWith(_GroupShoppingList value, $Res Function(_GroupShoppingList) _then) = __$GroupShoppingListCopyWithImpl;
@override @useResult
$Res call({
 String id, String createUserID, String groupID, String name, GroupShoppingListStatus status, String? shoppingLocationID, String? duplicatedFromGroupShoppingListID,@TimestampConverter() DateTime? ttlExpiresDateTime,@ClientCreatedTimestamp() DateTime? createdDateTime,@ClientUpdatedTimestamp() DateTime? updatedDateTime,@ServerCreatedTimestamp() DateTime? serverCreatedDateTime,@ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime
});




}
/// @nodoc
class __$GroupShoppingListCopyWithImpl<$Res>
    implements _$GroupShoppingListCopyWith<$Res> {
  __$GroupShoppingListCopyWithImpl(this._self, this._then);

  final _GroupShoppingList _self;
  final $Res Function(_GroupShoppingList) _then;

/// Create a copy of GroupShoppingList
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? createUserID = null,Object? groupID = null,Object? name = null,Object? status = null,Object? shoppingLocationID = freezed,Object? duplicatedFromGroupShoppingListID = freezed,Object? ttlExpiresDateTime = freezed,Object? createdDateTime = freezed,Object? updatedDateTime = freezed,Object? serverCreatedDateTime = freezed,Object? serverUpdatedDateTime = freezed,}) {
  return _then(_GroupShoppingList(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,createUserID: null == createUserID ? _self.createUserID : createUserID // ignore: cast_nullable_to_non_nullable
as String,groupID: null == groupID ? _self.groupID : groupID // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as GroupShoppingListStatus,shoppingLocationID: freezed == shoppingLocationID ? _self.shoppingLocationID : shoppingLocationID // ignore: cast_nullable_to_non_nullable
as String?,duplicatedFromGroupShoppingListID: freezed == duplicatedFromGroupShoppingListID ? _self.duplicatedFromGroupShoppingListID : duplicatedFromGroupShoppingListID // ignore: cast_nullable_to_non_nullable
as String?,ttlExpiresDateTime: freezed == ttlExpiresDateTime ? _self.ttlExpiresDateTime : ttlExpiresDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,createdDateTime: freezed == createdDateTime ? _self.createdDateTime : createdDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedDateTime: freezed == updatedDateTime ? _self.updatedDateTime : updatedDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,serverCreatedDateTime: freezed == serverCreatedDateTime ? _self.serverCreatedDateTime : serverCreatedDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,serverUpdatedDateTime: freezed == serverUpdatedDateTime ? _self.serverUpdatedDateTime : serverUpdatedDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
