// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group_shopping_list_receipt.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GroupShoppingListReceipt {

 String get id; String get groupID; String get shoppingListID; String get userID;/// Firebase Storage 上のレシート画像のパス。
/// 例: groups/{groupID}/shoppingLists/{shoppingListID}/receipts/{receiptID}.jpeg
/// download URL は Firestore に保存せず、表示時に storagePath から getDownloadURL で
/// 都度取得する（storage.rules でグループメンバーのみ read 許可）。
 String? get storagePath;/// レシートの金額（円・整数）。
 int? get amount;/// レシートに関するメモ。
 String? get memo;@ClientCreatedTimestamp() DateTime? get createdDateTime;@ClientUpdatedTimestamp() DateTime? get updatedDateTime;@ServerCreatedTimestamp() DateTime? get serverCreatedDateTime;@ServerUpdatedTimestamp() DateTime? get serverUpdatedDateTime;
/// Create a copy of GroupShoppingListReceipt
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupShoppingListReceiptCopyWith<GroupShoppingListReceipt> get copyWith => _$GroupShoppingListReceiptCopyWithImpl<GroupShoppingListReceipt>(this as GroupShoppingListReceipt, _$identity);

  /// Serializes this GroupShoppingListReceipt to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroupShoppingListReceipt&&(identical(other.id, id) || other.id == id)&&(identical(other.groupID, groupID) || other.groupID == groupID)&&(identical(other.shoppingListID, shoppingListID) || other.shoppingListID == shoppingListID)&&(identical(other.userID, userID) || other.userID == userID)&&(identical(other.storagePath, storagePath) || other.storagePath == storagePath)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.memo, memo) || other.memo == memo)&&(identical(other.createdDateTime, createdDateTime) || other.createdDateTime == createdDateTime)&&(identical(other.updatedDateTime, updatedDateTime) || other.updatedDateTime == updatedDateTime)&&(identical(other.serverCreatedDateTime, serverCreatedDateTime) || other.serverCreatedDateTime == serverCreatedDateTime)&&(identical(other.serverUpdatedDateTime, serverUpdatedDateTime) || other.serverUpdatedDateTime == serverUpdatedDateTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,groupID,shoppingListID,userID,storagePath,amount,memo,createdDateTime,updatedDateTime,serverCreatedDateTime,serverUpdatedDateTime);

@override
String toString() {
  return 'GroupShoppingListReceipt(id: $id, groupID: $groupID, shoppingListID: $shoppingListID, userID: $userID, storagePath: $storagePath, amount: $amount, memo: $memo, createdDateTime: $createdDateTime, updatedDateTime: $updatedDateTime, serverCreatedDateTime: $serverCreatedDateTime, serverUpdatedDateTime: $serverUpdatedDateTime)';
}


}

/// @nodoc
abstract mixin class $GroupShoppingListReceiptCopyWith<$Res>  {
  factory $GroupShoppingListReceiptCopyWith(GroupShoppingListReceipt value, $Res Function(GroupShoppingListReceipt) _then) = _$GroupShoppingListReceiptCopyWithImpl;
@useResult
$Res call({
 String id, String groupID, String shoppingListID, String userID, String? storagePath, int? amount, String? memo,@ClientCreatedTimestamp() DateTime? createdDateTime,@ClientUpdatedTimestamp() DateTime? updatedDateTime,@ServerCreatedTimestamp() DateTime? serverCreatedDateTime,@ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime
});




}
/// @nodoc
class _$GroupShoppingListReceiptCopyWithImpl<$Res>
    implements $GroupShoppingListReceiptCopyWith<$Res> {
  _$GroupShoppingListReceiptCopyWithImpl(this._self, this._then);

  final GroupShoppingListReceipt _self;
  final $Res Function(GroupShoppingListReceipt) _then;

/// Create a copy of GroupShoppingListReceipt
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? groupID = null,Object? shoppingListID = null,Object? userID = null,Object? storagePath = freezed,Object? amount = freezed,Object? memo = freezed,Object? createdDateTime = freezed,Object? updatedDateTime = freezed,Object? serverCreatedDateTime = freezed,Object? serverUpdatedDateTime = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,groupID: null == groupID ? _self.groupID : groupID // ignore: cast_nullable_to_non_nullable
as String,shoppingListID: null == shoppingListID ? _self.shoppingListID : shoppingListID // ignore: cast_nullable_to_non_nullable
as String,userID: null == userID ? _self.userID : userID // ignore: cast_nullable_to_non_nullable
as String,storagePath: freezed == storagePath ? _self.storagePath : storagePath // ignore: cast_nullable_to_non_nullable
as String?,amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int?,memo: freezed == memo ? _self.memo : memo // ignore: cast_nullable_to_non_nullable
as String?,createdDateTime: freezed == createdDateTime ? _self.createdDateTime : createdDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedDateTime: freezed == updatedDateTime ? _self.updatedDateTime : updatedDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,serverCreatedDateTime: freezed == serverCreatedDateTime ? _self.serverCreatedDateTime : serverCreatedDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,serverUpdatedDateTime: freezed == serverUpdatedDateTime ? _self.serverUpdatedDateTime : serverUpdatedDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [GroupShoppingListReceipt].
extension GroupShoppingListReceiptPatterns on GroupShoppingListReceipt {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroupShoppingListReceipt value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroupShoppingListReceipt() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroupShoppingListReceipt value)  $default,){
final _that = this;
switch (_that) {
case _GroupShoppingListReceipt():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroupShoppingListReceipt value)?  $default,){
final _that = this;
switch (_that) {
case _GroupShoppingListReceipt() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String groupID,  String shoppingListID,  String userID,  String? storagePath,  int? amount,  String? memo, @ClientCreatedTimestamp()  DateTime? createdDateTime, @ClientUpdatedTimestamp()  DateTime? updatedDateTime, @ServerCreatedTimestamp()  DateTime? serverCreatedDateTime, @ServerUpdatedTimestamp()  DateTime? serverUpdatedDateTime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroupShoppingListReceipt() when $default != null:
return $default(_that.id,_that.groupID,_that.shoppingListID,_that.userID,_that.storagePath,_that.amount,_that.memo,_that.createdDateTime,_that.updatedDateTime,_that.serverCreatedDateTime,_that.serverUpdatedDateTime);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String groupID,  String shoppingListID,  String userID,  String? storagePath,  int? amount,  String? memo, @ClientCreatedTimestamp()  DateTime? createdDateTime, @ClientUpdatedTimestamp()  DateTime? updatedDateTime, @ServerCreatedTimestamp()  DateTime? serverCreatedDateTime, @ServerUpdatedTimestamp()  DateTime? serverUpdatedDateTime)  $default,) {final _that = this;
switch (_that) {
case _GroupShoppingListReceipt():
return $default(_that.id,_that.groupID,_that.shoppingListID,_that.userID,_that.storagePath,_that.amount,_that.memo,_that.createdDateTime,_that.updatedDateTime,_that.serverCreatedDateTime,_that.serverUpdatedDateTime);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String groupID,  String shoppingListID,  String userID,  String? storagePath,  int? amount,  String? memo, @ClientCreatedTimestamp()  DateTime? createdDateTime, @ClientUpdatedTimestamp()  DateTime? updatedDateTime, @ServerCreatedTimestamp()  DateTime? serverCreatedDateTime, @ServerUpdatedTimestamp()  DateTime? serverUpdatedDateTime)?  $default,) {final _that = this;
switch (_that) {
case _GroupShoppingListReceipt() when $default != null:
return $default(_that.id,_that.groupID,_that.shoppingListID,_that.userID,_that.storagePath,_that.amount,_that.memo,_that.createdDateTime,_that.updatedDateTime,_that.serverCreatedDateTime,_that.serverUpdatedDateTime);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _GroupShoppingListReceipt implements GroupShoppingListReceipt {
  const _GroupShoppingListReceipt({required this.id, required this.groupID, required this.shoppingListID, required this.userID, required this.storagePath, required this.amount, required this.memo, @ClientCreatedTimestamp() this.createdDateTime, @ClientUpdatedTimestamp() this.updatedDateTime, @ServerCreatedTimestamp() this.serverCreatedDateTime, @ServerUpdatedTimestamp() this.serverUpdatedDateTime});
  factory _GroupShoppingListReceipt.fromJson(Map<String, dynamic> json) => _$GroupShoppingListReceiptFromJson(json);

@override final  String id;
@override final  String groupID;
@override final  String shoppingListID;
@override final  String userID;
/// Firebase Storage 上のレシート画像のパス。
/// 例: groups/{groupID}/shoppingLists/{shoppingListID}/receipts/{receiptID}.jpeg
/// download URL は Firestore に保存せず、表示時に storagePath から getDownloadURL で
/// 都度取得する（storage.rules でグループメンバーのみ read 許可）。
@override final  String? storagePath;
/// レシートの金額（円・整数）。
@override final  int? amount;
/// レシートに関するメモ。
@override final  String? memo;
@override@ClientCreatedTimestamp() final  DateTime? createdDateTime;
@override@ClientUpdatedTimestamp() final  DateTime? updatedDateTime;
@override@ServerCreatedTimestamp() final  DateTime? serverCreatedDateTime;
@override@ServerUpdatedTimestamp() final  DateTime? serverUpdatedDateTime;

/// Create a copy of GroupShoppingListReceipt
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroupShoppingListReceiptCopyWith<_GroupShoppingListReceipt> get copyWith => __$GroupShoppingListReceiptCopyWithImpl<_GroupShoppingListReceipt>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GroupShoppingListReceiptToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroupShoppingListReceipt&&(identical(other.id, id) || other.id == id)&&(identical(other.groupID, groupID) || other.groupID == groupID)&&(identical(other.shoppingListID, shoppingListID) || other.shoppingListID == shoppingListID)&&(identical(other.userID, userID) || other.userID == userID)&&(identical(other.storagePath, storagePath) || other.storagePath == storagePath)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.memo, memo) || other.memo == memo)&&(identical(other.createdDateTime, createdDateTime) || other.createdDateTime == createdDateTime)&&(identical(other.updatedDateTime, updatedDateTime) || other.updatedDateTime == updatedDateTime)&&(identical(other.serverCreatedDateTime, serverCreatedDateTime) || other.serverCreatedDateTime == serverCreatedDateTime)&&(identical(other.serverUpdatedDateTime, serverUpdatedDateTime) || other.serverUpdatedDateTime == serverUpdatedDateTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,groupID,shoppingListID,userID,storagePath,amount,memo,createdDateTime,updatedDateTime,serverCreatedDateTime,serverUpdatedDateTime);

@override
String toString() {
  return 'GroupShoppingListReceipt(id: $id, groupID: $groupID, shoppingListID: $shoppingListID, userID: $userID, storagePath: $storagePath, amount: $amount, memo: $memo, createdDateTime: $createdDateTime, updatedDateTime: $updatedDateTime, serverCreatedDateTime: $serverCreatedDateTime, serverUpdatedDateTime: $serverUpdatedDateTime)';
}


}

/// @nodoc
abstract mixin class _$GroupShoppingListReceiptCopyWith<$Res> implements $GroupShoppingListReceiptCopyWith<$Res> {
  factory _$GroupShoppingListReceiptCopyWith(_GroupShoppingListReceipt value, $Res Function(_GroupShoppingListReceipt) _then) = __$GroupShoppingListReceiptCopyWithImpl;
@override @useResult
$Res call({
 String id, String groupID, String shoppingListID, String userID, String? storagePath, int? amount, String? memo,@ClientCreatedTimestamp() DateTime? createdDateTime,@ClientUpdatedTimestamp() DateTime? updatedDateTime,@ServerCreatedTimestamp() DateTime? serverCreatedDateTime,@ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime
});




}
/// @nodoc
class __$GroupShoppingListReceiptCopyWithImpl<$Res>
    implements _$GroupShoppingListReceiptCopyWith<$Res> {
  __$GroupShoppingListReceiptCopyWithImpl(this._self, this._then);

  final _GroupShoppingListReceipt _self;
  final $Res Function(_GroupShoppingListReceipt) _then;

/// Create a copy of GroupShoppingListReceipt
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? groupID = null,Object? shoppingListID = null,Object? userID = null,Object? storagePath = freezed,Object? amount = freezed,Object? memo = freezed,Object? createdDateTime = freezed,Object? updatedDateTime = freezed,Object? serverCreatedDateTime = freezed,Object? serverUpdatedDateTime = freezed,}) {
  return _then(_GroupShoppingListReceipt(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,groupID: null == groupID ? _self.groupID : groupID // ignore: cast_nullable_to_non_nullable
as String,shoppingListID: null == shoppingListID ? _self.shoppingListID : shoppingListID // ignore: cast_nullable_to_non_nullable
as String,userID: null == userID ? _self.userID : userID // ignore: cast_nullable_to_non_nullable
as String,storagePath: freezed == storagePath ? _self.storagePath : storagePath // ignore: cast_nullable_to_non_nullable
as String?,amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int?,memo: freezed == memo ? _self.memo : memo // ignore: cast_nullable_to_non_nullable
as String?,createdDateTime: freezed == createdDateTime ? _self.createdDateTime : createdDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedDateTime: freezed == updatedDateTime ? _self.updatedDateTime : updatedDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,serverCreatedDateTime: freezed == serverCreatedDateTime ? _self.serverCreatedDateTime : serverCreatedDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,serverUpdatedDateTime: freezed == serverUpdatedDateTime ? _self.serverUpdatedDateTime : serverUpdatedDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
