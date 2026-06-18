// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_usage.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserAIUsage {

/// ドキュメントID（yearMonth形式、例: "2026-04"）
 String get id;/// このドキュメントの所有ユーザーID
 String get userID;/// AI画像認識の利用回数
 int get imageRecognitionCount;/// URLからの買い物リスト生成の利用回数
 int get urlRecognitionCount;/// AIカテゴリ分けの利用回数
 int get categorizeCount;@ServerCreatedTimestamp() DateTime? get serverCreatedDateTime;@ServerUpdatedTimestamp() DateTime? get serverUpdatedDateTime;
/// Create a copy of UserAIUsage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserAIUsageCopyWith<UserAIUsage> get copyWith => _$UserAIUsageCopyWithImpl<UserAIUsage>(this as UserAIUsage, _$identity);

  /// Serializes this UserAIUsage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserAIUsage&&(identical(other.id, id) || other.id == id)&&(identical(other.userID, userID) || other.userID == userID)&&(identical(other.imageRecognitionCount, imageRecognitionCount) || other.imageRecognitionCount == imageRecognitionCount)&&(identical(other.urlRecognitionCount, urlRecognitionCount) || other.urlRecognitionCount == urlRecognitionCount)&&(identical(other.categorizeCount, categorizeCount) || other.categorizeCount == categorizeCount)&&(identical(other.serverCreatedDateTime, serverCreatedDateTime) || other.serverCreatedDateTime == serverCreatedDateTime)&&(identical(other.serverUpdatedDateTime, serverUpdatedDateTime) || other.serverUpdatedDateTime == serverUpdatedDateTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userID,imageRecognitionCount,urlRecognitionCount,categorizeCount,serverCreatedDateTime,serverUpdatedDateTime);

@override
String toString() {
  return 'UserAIUsage(id: $id, userID: $userID, imageRecognitionCount: $imageRecognitionCount, urlRecognitionCount: $urlRecognitionCount, categorizeCount: $categorizeCount, serverCreatedDateTime: $serverCreatedDateTime, serverUpdatedDateTime: $serverUpdatedDateTime)';
}


}

/// @nodoc
abstract mixin class $UserAIUsageCopyWith<$Res>  {
  factory $UserAIUsageCopyWith(UserAIUsage value, $Res Function(UserAIUsage) _then) = _$UserAIUsageCopyWithImpl;
@useResult
$Res call({
 String id, String userID, int imageRecognitionCount, int urlRecognitionCount, int categorizeCount,@ServerCreatedTimestamp() DateTime? serverCreatedDateTime,@ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime
});




}
/// @nodoc
class _$UserAIUsageCopyWithImpl<$Res>
    implements $UserAIUsageCopyWith<$Res> {
  _$UserAIUsageCopyWithImpl(this._self, this._then);

  final UserAIUsage _self;
  final $Res Function(UserAIUsage) _then;

/// Create a copy of UserAIUsage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userID = null,Object? imageRecognitionCount = null,Object? urlRecognitionCount = null,Object? categorizeCount = null,Object? serverCreatedDateTime = freezed,Object? serverUpdatedDateTime = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userID: null == userID ? _self.userID : userID // ignore: cast_nullable_to_non_nullable
as String,imageRecognitionCount: null == imageRecognitionCount ? _self.imageRecognitionCount : imageRecognitionCount // ignore: cast_nullable_to_non_nullable
as int,urlRecognitionCount: null == urlRecognitionCount ? _self.urlRecognitionCount : urlRecognitionCount // ignore: cast_nullable_to_non_nullable
as int,categorizeCount: null == categorizeCount ? _self.categorizeCount : categorizeCount // ignore: cast_nullable_to_non_nullable
as int,serverCreatedDateTime: freezed == serverCreatedDateTime ? _self.serverCreatedDateTime : serverCreatedDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,serverUpdatedDateTime: freezed == serverUpdatedDateTime ? _self.serverUpdatedDateTime : serverUpdatedDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserAIUsage].
extension UserAIUsagePatterns on UserAIUsage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserAIUsage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserAIUsage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserAIUsage value)  $default,){
final _that = this;
switch (_that) {
case _UserAIUsage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserAIUsage value)?  $default,){
final _that = this;
switch (_that) {
case _UserAIUsage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userID,  int imageRecognitionCount,  int urlRecognitionCount,  int categorizeCount, @ServerCreatedTimestamp()  DateTime? serverCreatedDateTime, @ServerUpdatedTimestamp()  DateTime? serverUpdatedDateTime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserAIUsage() when $default != null:
return $default(_that.id,_that.userID,_that.imageRecognitionCount,_that.urlRecognitionCount,_that.categorizeCount,_that.serverCreatedDateTime,_that.serverUpdatedDateTime);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userID,  int imageRecognitionCount,  int urlRecognitionCount,  int categorizeCount, @ServerCreatedTimestamp()  DateTime? serverCreatedDateTime, @ServerUpdatedTimestamp()  DateTime? serverUpdatedDateTime)  $default,) {final _that = this;
switch (_that) {
case _UserAIUsage():
return $default(_that.id,_that.userID,_that.imageRecognitionCount,_that.urlRecognitionCount,_that.categorizeCount,_that.serverCreatedDateTime,_that.serverUpdatedDateTime);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userID,  int imageRecognitionCount,  int urlRecognitionCount,  int categorizeCount, @ServerCreatedTimestamp()  DateTime? serverCreatedDateTime, @ServerUpdatedTimestamp()  DateTime? serverUpdatedDateTime)?  $default,) {final _that = this;
switch (_that) {
case _UserAIUsage() when $default != null:
return $default(_that.id,_that.userID,_that.imageRecognitionCount,_that.urlRecognitionCount,_that.categorizeCount,_that.serverCreatedDateTime,_that.serverUpdatedDateTime);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _UserAIUsage extends UserAIUsage {
  const _UserAIUsage({required this.id, required this.userID, required this.imageRecognitionCount, this.urlRecognitionCount = 0, this.categorizeCount = 0, @ServerCreatedTimestamp() this.serverCreatedDateTime, @ServerUpdatedTimestamp() this.serverUpdatedDateTime}): super._();
  factory _UserAIUsage.fromJson(Map<String, dynamic> json) => _$UserAIUsageFromJson(json);

/// ドキュメントID（yearMonth形式、例: "2026-04"）
@override final  String id;
/// このドキュメントの所有ユーザーID
@override final  String userID;
/// AI画像認識の利用回数
@override final  int imageRecognitionCount;
/// URLからの買い物リスト生成の利用回数
@override@JsonKey() final  int urlRecognitionCount;
/// AIカテゴリ分けの利用回数
@override@JsonKey() final  int categorizeCount;
@override@ServerCreatedTimestamp() final  DateTime? serverCreatedDateTime;
@override@ServerUpdatedTimestamp() final  DateTime? serverUpdatedDateTime;

/// Create a copy of UserAIUsage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserAIUsageCopyWith<_UserAIUsage> get copyWith => __$UserAIUsageCopyWithImpl<_UserAIUsage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserAIUsageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserAIUsage&&(identical(other.id, id) || other.id == id)&&(identical(other.userID, userID) || other.userID == userID)&&(identical(other.imageRecognitionCount, imageRecognitionCount) || other.imageRecognitionCount == imageRecognitionCount)&&(identical(other.urlRecognitionCount, urlRecognitionCount) || other.urlRecognitionCount == urlRecognitionCount)&&(identical(other.categorizeCount, categorizeCount) || other.categorizeCount == categorizeCount)&&(identical(other.serverCreatedDateTime, serverCreatedDateTime) || other.serverCreatedDateTime == serverCreatedDateTime)&&(identical(other.serverUpdatedDateTime, serverUpdatedDateTime) || other.serverUpdatedDateTime == serverUpdatedDateTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userID,imageRecognitionCount,urlRecognitionCount,categorizeCount,serverCreatedDateTime,serverUpdatedDateTime);

@override
String toString() {
  return 'UserAIUsage(id: $id, userID: $userID, imageRecognitionCount: $imageRecognitionCount, urlRecognitionCount: $urlRecognitionCount, categorizeCount: $categorizeCount, serverCreatedDateTime: $serverCreatedDateTime, serverUpdatedDateTime: $serverUpdatedDateTime)';
}


}

/// @nodoc
abstract mixin class _$UserAIUsageCopyWith<$Res> implements $UserAIUsageCopyWith<$Res> {
  factory _$UserAIUsageCopyWith(_UserAIUsage value, $Res Function(_UserAIUsage) _then) = __$UserAIUsageCopyWithImpl;
@override @useResult
$Res call({
 String id, String userID, int imageRecognitionCount, int urlRecognitionCount, int categorizeCount,@ServerCreatedTimestamp() DateTime? serverCreatedDateTime,@ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime
});




}
/// @nodoc
class __$UserAIUsageCopyWithImpl<$Res>
    implements _$UserAIUsageCopyWith<$Res> {
  __$UserAIUsageCopyWithImpl(this._self, this._then);

  final _UserAIUsage _self;
  final $Res Function(_UserAIUsage) _then;

/// Create a copy of UserAIUsage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userID = null,Object? imageRecognitionCount = null,Object? urlRecognitionCount = null,Object? categorizeCount = null,Object? serverCreatedDateTime = freezed,Object? serverUpdatedDateTime = freezed,}) {
  return _then(_UserAIUsage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userID: null == userID ? _self.userID : userID // ignore: cast_nullable_to_non_nullable
as String,imageRecognitionCount: null == imageRecognitionCount ? _self.imageRecognitionCount : imageRecognitionCount // ignore: cast_nullable_to_non_nullable
as int,urlRecognitionCount: null == urlRecognitionCount ? _self.urlRecognitionCount : urlRecognitionCount // ignore: cast_nullable_to_non_nullable
as int,categorizeCount: null == categorizeCount ? _self.categorizeCount : categorizeCount // ignore: cast_nullable_to_non_nullable
as int,serverCreatedDateTime: freezed == serverCreatedDateTime ? _self.serverCreatedDateTime : serverCreatedDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,serverUpdatedDateTime: freezed == serverUpdatedDateTime ? _self.serverUpdatedDateTime : serverUpdatedDateTime // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
