// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group_shopping_list_item_category_keyword.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GroupShoppingListItemCategoryKeyword {
  String get keyword;
  GroupShoppingListItemCategoryKeywordMatchingType get matchingType;

  /// Create a copy of GroupShoppingListItemCategoryKeyword
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $GroupShoppingListItemCategoryKeywordCopyWith<
          GroupShoppingListItemCategoryKeyword>
      get copyWith => _$GroupShoppingListItemCategoryKeywordCopyWithImpl<
              GroupShoppingListItemCategoryKeyword>(
          this as GroupShoppingListItemCategoryKeyword, _$identity);

  /// Serializes this GroupShoppingListItemCategoryKeyword to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is GroupShoppingListItemCategoryKeyword &&
            (identical(other.keyword, keyword) || other.keyword == keyword) &&
            (identical(other.matchingType, matchingType) ||
                other.matchingType == matchingType));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, keyword, matchingType);

  @override
  String toString() {
    return 'GroupShoppingListItemCategoryKeyword(keyword: $keyword, matchingType: $matchingType)';
  }
}

/// @nodoc
abstract mixin class $GroupShoppingListItemCategoryKeywordCopyWith<$Res> {
  factory $GroupShoppingListItemCategoryKeywordCopyWith(
          GroupShoppingListItemCategoryKeyword value,
          $Res Function(GroupShoppingListItemCategoryKeyword) _then) =
      _$GroupShoppingListItemCategoryKeywordCopyWithImpl;
  @useResult
  $Res call(
      {String keyword,
      GroupShoppingListItemCategoryKeywordMatchingType matchingType});
}

/// @nodoc
class _$GroupShoppingListItemCategoryKeywordCopyWithImpl<$Res>
    implements $GroupShoppingListItemCategoryKeywordCopyWith<$Res> {
  _$GroupShoppingListItemCategoryKeywordCopyWithImpl(this._self, this._then);

  final GroupShoppingListItemCategoryKeyword _self;
  final $Res Function(GroupShoppingListItemCategoryKeyword) _then;

  /// Create a copy of GroupShoppingListItemCategoryKeyword
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? keyword = null,
    Object? matchingType = null,
  }) {
    return _then(_self.copyWith(
      keyword: null == keyword
          ? _self.keyword
          : keyword // ignore: cast_nullable_to_non_nullable
              as String,
      matchingType: null == matchingType
          ? _self.matchingType
          : matchingType // ignore: cast_nullable_to_non_nullable
              as GroupShoppingListItemCategoryKeywordMatchingType,
    ));
  }
}

/// Adds pattern-matching-related methods to [GroupShoppingListItemCategoryKeyword].
extension GroupShoppingListItemCategoryKeywordPatterns
    on GroupShoppingListItemCategoryKeyword {
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_GroupShoppingListItemCategoryKeyword value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GroupShoppingListItemCategoryKeyword() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_GroupShoppingListItemCategoryKeyword value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GroupShoppingListItemCategoryKeyword():
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_GroupShoppingListItemCategoryKeyword value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GroupShoppingListItemCategoryKeyword() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String keyword,
            GroupShoppingListItemCategoryKeywordMatchingType matchingType)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GroupShoppingListItemCategoryKeyword() when $default != null:
        return $default(_that.keyword, _that.matchingType);
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(String keyword,
            GroupShoppingListItemCategoryKeywordMatchingType matchingType)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GroupShoppingListItemCategoryKeyword():
        return $default(_that.keyword, _that.matchingType);
      case _:
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(String keyword,
            GroupShoppingListItemCategoryKeywordMatchingType matchingType)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GroupShoppingListItemCategoryKeyword() when $default != null:
        return $default(_that.keyword, _that.matchingType);
      case _:
        return null;
    }
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _GroupShoppingListItemCategoryKeyword
    implements GroupShoppingListItemCategoryKeyword {
  const _GroupShoppingListItemCategoryKeyword(
      {required this.keyword, required this.matchingType});
  factory _GroupShoppingListItemCategoryKeyword.fromJson(
          Map<String, dynamic> json) =>
      _$GroupShoppingListItemCategoryKeywordFromJson(json);

  @override
  final String keyword;
  @override
  final GroupShoppingListItemCategoryKeywordMatchingType matchingType;

  /// Create a copy of GroupShoppingListItemCategoryKeyword
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$GroupShoppingListItemCategoryKeywordCopyWith<
          _GroupShoppingListItemCategoryKeyword>
      get copyWith => __$GroupShoppingListItemCategoryKeywordCopyWithImpl<
          _GroupShoppingListItemCategoryKeyword>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$GroupShoppingListItemCategoryKeywordToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _GroupShoppingListItemCategoryKeyword &&
            (identical(other.keyword, keyword) || other.keyword == keyword) &&
            (identical(other.matchingType, matchingType) ||
                other.matchingType == matchingType));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, keyword, matchingType);

  @override
  String toString() {
    return 'GroupShoppingListItemCategoryKeyword(keyword: $keyword, matchingType: $matchingType)';
  }
}

/// @nodoc
abstract mixin class _$GroupShoppingListItemCategoryKeywordCopyWith<$Res>
    implements $GroupShoppingListItemCategoryKeywordCopyWith<$Res> {
  factory _$GroupShoppingListItemCategoryKeywordCopyWith(
          _GroupShoppingListItemCategoryKeyword value,
          $Res Function(_GroupShoppingListItemCategoryKeyword) _then) =
      __$GroupShoppingListItemCategoryKeywordCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String keyword,
      GroupShoppingListItemCategoryKeywordMatchingType matchingType});
}

/// @nodoc
class __$GroupShoppingListItemCategoryKeywordCopyWithImpl<$Res>
    implements _$GroupShoppingListItemCategoryKeywordCopyWith<$Res> {
  __$GroupShoppingListItemCategoryKeywordCopyWithImpl(this._self, this._then);

  final _GroupShoppingListItemCategoryKeyword _self;
  final $Res Function(_GroupShoppingListItemCategoryKeyword) _then;

  /// Create a copy of GroupShoppingListItemCategoryKeyword
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? keyword = null,
    Object? matchingType = null,
  }) {
    return _then(_GroupShoppingListItemCategoryKeyword(
      keyword: null == keyword
          ? _self.keyword
          : keyword // ignore: cast_nullable_to_non_nullable
              as String,
      matchingType: null == matchingType
          ? _self.matchingType
          : matchingType // ignore: cast_nullable_to_non_nullable
              as GroupShoppingListItemCategoryKeywordMatchingType,
    ));
  }
}

// dart format on
