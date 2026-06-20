// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group_category_keyword.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GroupCategoryKeyword {

 String get keyword; GroupCategoryKeywordMatchingType get matchingType;
/// Create a copy of GroupCategoryKeyword
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupCategoryKeywordCopyWith<GroupCategoryKeyword> get copyWith => _$GroupCategoryKeywordCopyWithImpl<GroupCategoryKeyword>(this as GroupCategoryKeyword, _$identity);

  /// Serializes this GroupCategoryKeyword to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroupCategoryKeyword&&(identical(other.keyword, keyword) || other.keyword == keyword)&&(identical(other.matchingType, matchingType) || other.matchingType == matchingType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,keyword,matchingType);

@override
String toString() {
  return 'GroupCategoryKeyword(keyword: $keyword, matchingType: $matchingType)';
}


}

/// @nodoc
abstract mixin class $GroupCategoryKeywordCopyWith<$Res>  {
  factory $GroupCategoryKeywordCopyWith(GroupCategoryKeyword value, $Res Function(GroupCategoryKeyword) _then) = _$GroupCategoryKeywordCopyWithImpl;
@useResult
$Res call({
 String keyword, GroupCategoryKeywordMatchingType matchingType
});




}
/// @nodoc
class _$GroupCategoryKeywordCopyWithImpl<$Res>
    implements $GroupCategoryKeywordCopyWith<$Res> {
  _$GroupCategoryKeywordCopyWithImpl(this._self, this._then);

  final GroupCategoryKeyword _self;
  final $Res Function(GroupCategoryKeyword) _then;

/// Create a copy of GroupCategoryKeyword
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? keyword = null,Object? matchingType = null,}) {
  return _then(_self.copyWith(
keyword: null == keyword ? _self.keyword : keyword // ignore: cast_nullable_to_non_nullable
as String,matchingType: null == matchingType ? _self.matchingType : matchingType // ignore: cast_nullable_to_non_nullable
as GroupCategoryKeywordMatchingType,
  ));
}

}


/// Adds pattern-matching-related methods to [GroupCategoryKeyword].
extension GroupCategoryKeywordPatterns on GroupCategoryKeyword {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroupCategoryKeyword value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroupCategoryKeyword() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroupCategoryKeyword value)  $default,){
final _that = this;
switch (_that) {
case _GroupCategoryKeyword():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroupCategoryKeyword value)?  $default,){
final _that = this;
switch (_that) {
case _GroupCategoryKeyword() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String keyword,  GroupCategoryKeywordMatchingType matchingType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroupCategoryKeyword() when $default != null:
return $default(_that.keyword,_that.matchingType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String keyword,  GroupCategoryKeywordMatchingType matchingType)  $default,) {final _that = this;
switch (_that) {
case _GroupCategoryKeyword():
return $default(_that.keyword,_that.matchingType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String keyword,  GroupCategoryKeywordMatchingType matchingType)?  $default,) {final _that = this;
switch (_that) {
case _GroupCategoryKeyword() when $default != null:
return $default(_that.keyword,_that.matchingType);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _GroupCategoryKeyword implements GroupCategoryKeyword {
  const _GroupCategoryKeyword({required this.keyword, required this.matchingType});
  factory _GroupCategoryKeyword.fromJson(Map<String, dynamic> json) => _$GroupCategoryKeywordFromJson(json);

@override final  String keyword;
@override final  GroupCategoryKeywordMatchingType matchingType;

/// Create a copy of GroupCategoryKeyword
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroupCategoryKeywordCopyWith<_GroupCategoryKeyword> get copyWith => __$GroupCategoryKeywordCopyWithImpl<_GroupCategoryKeyword>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GroupCategoryKeywordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroupCategoryKeyword&&(identical(other.keyword, keyword) || other.keyword == keyword)&&(identical(other.matchingType, matchingType) || other.matchingType == matchingType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,keyword,matchingType);

@override
String toString() {
  return 'GroupCategoryKeyword(keyword: $keyword, matchingType: $matchingType)';
}


}

/// @nodoc
abstract mixin class _$GroupCategoryKeywordCopyWith<$Res> implements $GroupCategoryKeywordCopyWith<$Res> {
  factory _$GroupCategoryKeywordCopyWith(_GroupCategoryKeyword value, $Res Function(_GroupCategoryKeyword) _then) = __$GroupCategoryKeywordCopyWithImpl;
@override @useResult
$Res call({
 String keyword, GroupCategoryKeywordMatchingType matchingType
});




}
/// @nodoc
class __$GroupCategoryKeywordCopyWithImpl<$Res>
    implements _$GroupCategoryKeywordCopyWith<$Res> {
  __$GroupCategoryKeywordCopyWithImpl(this._self, this._then);

  final _GroupCategoryKeyword _self;
  final $Res Function(_GroupCategoryKeyword) _then;

/// Create a copy of GroupCategoryKeyword
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? keyword = null,Object? matchingType = null,}) {
  return _then(_GroupCategoryKeyword(
keyword: null == keyword ? _self.keyword : keyword // ignore: cast_nullable_to_non_nullable
as String,matchingType: null == matchingType ? _self.matchingType : matchingType // ignore: cast_nullable_to_non_nullable
as GroupCategoryKeywordMatchingType,
  ));
}


}

// dart format on
