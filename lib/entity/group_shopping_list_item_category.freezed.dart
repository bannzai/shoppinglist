// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group_shopping_list_item_category.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GroupShoppingListItemCategory {
  String get id;
  String get groupID;
  String get groupShoppingListItemCategoryAxisID;
  String get name;
  int get order;
  List<GroupShoppingListItemCategoryKeyword> get keywords;
  @ClientCreatedTimestamp()
  DateTime? get createdDateTime;
  @ClientUpdatedTimestamp()
  DateTime? get updatedDateTime;
  @ServerCreatedTimestamp()
  DateTime? get serverCreatedDateTime;
  @ServerUpdatedTimestamp()
  DateTime? get serverUpdatedDateTime;

  /// Create a copy of GroupShoppingListItemCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $GroupShoppingListItemCategoryCopyWith<GroupShoppingListItemCategory>
      get copyWith => _$GroupShoppingListItemCategoryCopyWithImpl<
              GroupShoppingListItemCategory>(
          this as GroupShoppingListItemCategory, _$identity);

  /// Serializes this GroupShoppingListItemCategory to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is GroupShoppingListItemCategory &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.groupID, groupID) || other.groupID == groupID) &&
            (identical(other.groupShoppingListItemCategoryAxisID,
                    groupShoppingListItemCategoryAxisID) ||
                other.groupShoppingListItemCategoryAxisID ==
                    groupShoppingListItemCategoryAxisID) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.order, order) || other.order == order) &&
            const DeepCollectionEquality().equals(other.keywords, keywords) &&
            (identical(other.createdDateTime, createdDateTime) ||
                other.createdDateTime == createdDateTime) &&
            (identical(other.updatedDateTime, updatedDateTime) ||
                other.updatedDateTime == updatedDateTime) &&
            (identical(other.serverCreatedDateTime, serverCreatedDateTime) ||
                other.serverCreatedDateTime == serverCreatedDateTime) &&
            (identical(other.serverUpdatedDateTime, serverUpdatedDateTime) ||
                other.serverUpdatedDateTime == serverUpdatedDateTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      groupID,
      groupShoppingListItemCategoryAxisID,
      name,
      order,
      const DeepCollectionEquality().hash(keywords),
      createdDateTime,
      updatedDateTime,
      serverCreatedDateTime,
      serverUpdatedDateTime);

  @override
  String toString() {
    return 'GroupShoppingListItemCategory(id: $id, groupID: $groupID, groupShoppingListItemCategoryAxisID: $groupShoppingListItemCategoryAxisID, name: $name, order: $order, keywords: $keywords, createdDateTime: $createdDateTime, updatedDateTime: $updatedDateTime, serverCreatedDateTime: $serverCreatedDateTime, serverUpdatedDateTime: $serverUpdatedDateTime)';
  }
}

/// @nodoc
abstract mixin class $GroupShoppingListItemCategoryCopyWith<$Res> {
  factory $GroupShoppingListItemCategoryCopyWith(
          GroupShoppingListItemCategory value,
          $Res Function(GroupShoppingListItemCategory) _then) =
      _$GroupShoppingListItemCategoryCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String groupID,
      String groupShoppingListItemCategoryAxisID,
      String name,
      int order,
      List<GroupShoppingListItemCategoryKeyword> keywords,
      @ClientCreatedTimestamp() DateTime? createdDateTime,
      @ClientUpdatedTimestamp() DateTime? updatedDateTime,
      @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
      @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime});
}

/// @nodoc
class _$GroupShoppingListItemCategoryCopyWithImpl<$Res>
    implements $GroupShoppingListItemCategoryCopyWith<$Res> {
  _$GroupShoppingListItemCategoryCopyWithImpl(this._self, this._then);

  final GroupShoppingListItemCategory _self;
  final $Res Function(GroupShoppingListItemCategory) _then;

  /// Create a copy of GroupShoppingListItemCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? groupID = null,
    Object? groupShoppingListItemCategoryAxisID = null,
    Object? name = null,
    Object? order = null,
    Object? keywords = null,
    Object? createdDateTime = freezed,
    Object? updatedDateTime = freezed,
    Object? serverCreatedDateTime = freezed,
    Object? serverUpdatedDateTime = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      groupID: null == groupID
          ? _self.groupID
          : groupID // ignore: cast_nullable_to_non_nullable
              as String,
      groupShoppingListItemCategoryAxisID: null ==
              groupShoppingListItemCategoryAxisID
          ? _self.groupShoppingListItemCategoryAxisID
          : groupShoppingListItemCategoryAxisID // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      order: null == order
          ? _self.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      keywords: null == keywords
          ? _self.keywords
          : keywords // ignore: cast_nullable_to_non_nullable
              as List<GroupShoppingListItemCategoryKeyword>,
      createdDateTime: freezed == createdDateTime
          ? _self.createdDateTime
          : createdDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedDateTime: freezed == updatedDateTime
          ? _self.updatedDateTime
          : updatedDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      serverCreatedDateTime: freezed == serverCreatedDateTime
          ? _self.serverCreatedDateTime
          : serverCreatedDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      serverUpdatedDateTime: freezed == serverUpdatedDateTime
          ? _self.serverUpdatedDateTime
          : serverUpdatedDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// Adds pattern-matching-related methods to [GroupShoppingListItemCategory].
extension GroupShoppingListItemCategoryPatterns
    on GroupShoppingListItemCategory {
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
    TResult Function(_GroupShoppingListItemCategory value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GroupShoppingListItemCategory() when $default != null:
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
    TResult Function(_GroupShoppingListItemCategory value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GroupShoppingListItemCategory():
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
    TResult? Function(_GroupShoppingListItemCategory value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GroupShoppingListItemCategory() when $default != null:
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
    TResult Function(
            String id,
            String groupID,
            String groupShoppingListItemCategoryAxisID,
            String name,
            int order,
            List<GroupShoppingListItemCategoryKeyword> keywords,
            @ClientCreatedTimestamp() DateTime? createdDateTime,
            @ClientUpdatedTimestamp() DateTime? updatedDateTime,
            @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
            @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GroupShoppingListItemCategory() when $default != null:
        return $default(
            _that.id,
            _that.groupID,
            _that.groupShoppingListItemCategoryAxisID,
            _that.name,
            _that.order,
            _that.keywords,
            _that.createdDateTime,
            _that.updatedDateTime,
            _that.serverCreatedDateTime,
            _that.serverUpdatedDateTime);
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
    TResult Function(
            String id,
            String groupID,
            String groupShoppingListItemCategoryAxisID,
            String name,
            int order,
            List<GroupShoppingListItemCategoryKeyword> keywords,
            @ClientCreatedTimestamp() DateTime? createdDateTime,
            @ClientUpdatedTimestamp() DateTime? updatedDateTime,
            @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
            @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GroupShoppingListItemCategory():
        return $default(
            _that.id,
            _that.groupID,
            _that.groupShoppingListItemCategoryAxisID,
            _that.name,
            _that.order,
            _that.keywords,
            _that.createdDateTime,
            _that.updatedDateTime,
            _that.serverCreatedDateTime,
            _that.serverUpdatedDateTime);
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
    TResult? Function(
            String id,
            String groupID,
            String groupShoppingListItemCategoryAxisID,
            String name,
            int order,
            List<GroupShoppingListItemCategoryKeyword> keywords,
            @ClientCreatedTimestamp() DateTime? createdDateTime,
            @ClientUpdatedTimestamp() DateTime? updatedDateTime,
            @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
            @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GroupShoppingListItemCategory() when $default != null:
        return $default(
            _that.id,
            _that.groupID,
            _that.groupShoppingListItemCategoryAxisID,
            _that.name,
            _that.order,
            _that.keywords,
            _that.createdDateTime,
            _that.updatedDateTime,
            _that.serverCreatedDateTime,
            _that.serverUpdatedDateTime);
      case _:
        return null;
    }
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _GroupShoppingListItemCategory extends GroupShoppingListItemCategory {
  const _GroupShoppingListItemCategory(
      {required this.id,
      required this.groupID,
      required this.groupShoppingListItemCategoryAxisID,
      required this.name,
      required this.order,
      final List<GroupShoppingListItemCategoryKeyword> keywords = const [],
      @ClientCreatedTimestamp() this.createdDateTime,
      @ClientUpdatedTimestamp() this.updatedDateTime,
      @ServerCreatedTimestamp() this.serverCreatedDateTime,
      @ServerUpdatedTimestamp() this.serverUpdatedDateTime})
      : _keywords = keywords,
        super._();
  factory _GroupShoppingListItemCategory.fromJson(Map<String, dynamic> json) =>
      _$GroupShoppingListItemCategoryFromJson(json);

  @override
  final String id;
  @override
  final String groupID;
  @override
  final String groupShoppingListItemCategoryAxisID;
  @override
  final String name;
  @override
  final int order;
  final List<GroupShoppingListItemCategoryKeyword> _keywords;
  @override
  @JsonKey()
  List<GroupShoppingListItemCategoryKeyword> get keywords {
    if (_keywords is EqualUnmodifiableListView) return _keywords;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_keywords);
  }

  @override
  @ClientCreatedTimestamp()
  final DateTime? createdDateTime;
  @override
  @ClientUpdatedTimestamp()
  final DateTime? updatedDateTime;
  @override
  @ServerCreatedTimestamp()
  final DateTime? serverCreatedDateTime;
  @override
  @ServerUpdatedTimestamp()
  final DateTime? serverUpdatedDateTime;

  /// Create a copy of GroupShoppingListItemCategory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$GroupShoppingListItemCategoryCopyWith<_GroupShoppingListItemCategory>
      get copyWith => __$GroupShoppingListItemCategoryCopyWithImpl<
          _GroupShoppingListItemCategory>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$GroupShoppingListItemCategoryToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _GroupShoppingListItemCategory &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.groupID, groupID) || other.groupID == groupID) &&
            (identical(other.groupShoppingListItemCategoryAxisID,
                    groupShoppingListItemCategoryAxisID) ||
                other.groupShoppingListItemCategoryAxisID ==
                    groupShoppingListItemCategoryAxisID) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.order, order) || other.order == order) &&
            const DeepCollectionEquality().equals(other._keywords, _keywords) &&
            (identical(other.createdDateTime, createdDateTime) ||
                other.createdDateTime == createdDateTime) &&
            (identical(other.updatedDateTime, updatedDateTime) ||
                other.updatedDateTime == updatedDateTime) &&
            (identical(other.serverCreatedDateTime, serverCreatedDateTime) ||
                other.serverCreatedDateTime == serverCreatedDateTime) &&
            (identical(other.serverUpdatedDateTime, serverUpdatedDateTime) ||
                other.serverUpdatedDateTime == serverUpdatedDateTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      groupID,
      groupShoppingListItemCategoryAxisID,
      name,
      order,
      const DeepCollectionEquality().hash(_keywords),
      createdDateTime,
      updatedDateTime,
      serverCreatedDateTime,
      serverUpdatedDateTime);

  @override
  String toString() {
    return 'GroupShoppingListItemCategory(id: $id, groupID: $groupID, groupShoppingListItemCategoryAxisID: $groupShoppingListItemCategoryAxisID, name: $name, order: $order, keywords: $keywords, createdDateTime: $createdDateTime, updatedDateTime: $updatedDateTime, serverCreatedDateTime: $serverCreatedDateTime, serverUpdatedDateTime: $serverUpdatedDateTime)';
  }
}

/// @nodoc
abstract mixin class _$GroupShoppingListItemCategoryCopyWith<$Res>
    implements $GroupShoppingListItemCategoryCopyWith<$Res> {
  factory _$GroupShoppingListItemCategoryCopyWith(
          _GroupShoppingListItemCategory value,
          $Res Function(_GroupShoppingListItemCategory) _then) =
      __$GroupShoppingListItemCategoryCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String groupID,
      String groupShoppingListItemCategoryAxisID,
      String name,
      int order,
      List<GroupShoppingListItemCategoryKeyword> keywords,
      @ClientCreatedTimestamp() DateTime? createdDateTime,
      @ClientUpdatedTimestamp() DateTime? updatedDateTime,
      @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
      @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime});
}

/// @nodoc
class __$GroupShoppingListItemCategoryCopyWithImpl<$Res>
    implements _$GroupShoppingListItemCategoryCopyWith<$Res> {
  __$GroupShoppingListItemCategoryCopyWithImpl(this._self, this._then);

  final _GroupShoppingListItemCategory _self;
  final $Res Function(_GroupShoppingListItemCategory) _then;

  /// Create a copy of GroupShoppingListItemCategory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? groupID = null,
    Object? groupShoppingListItemCategoryAxisID = null,
    Object? name = null,
    Object? order = null,
    Object? keywords = null,
    Object? createdDateTime = freezed,
    Object? updatedDateTime = freezed,
    Object? serverCreatedDateTime = freezed,
    Object? serverUpdatedDateTime = freezed,
  }) {
    return _then(_GroupShoppingListItemCategory(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      groupID: null == groupID
          ? _self.groupID
          : groupID // ignore: cast_nullable_to_non_nullable
              as String,
      groupShoppingListItemCategoryAxisID: null ==
              groupShoppingListItemCategoryAxisID
          ? _self.groupShoppingListItemCategoryAxisID
          : groupShoppingListItemCategoryAxisID // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      order: null == order
          ? _self.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      keywords: null == keywords
          ? _self._keywords
          : keywords // ignore: cast_nullable_to_non_nullable
              as List<GroupShoppingListItemCategoryKeyword>,
      createdDateTime: freezed == createdDateTime
          ? _self.createdDateTime
          : createdDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedDateTime: freezed == updatedDateTime
          ? _self.updatedDateTime
          : updatedDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      serverCreatedDateTime: freezed == serverCreatedDateTime
          ? _self.serverCreatedDateTime
          : serverCreatedDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      serverUpdatedDateTime: freezed == serverUpdatedDateTime
          ? _self.serverUpdatedDateTime
          : serverUpdatedDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

// dart format on
