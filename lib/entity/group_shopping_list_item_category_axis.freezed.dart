// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group_shopping_list_item_category_axis.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GroupShoppingListItemCategoryAxis {
  String get id;
  String get groupID;
  String get userID;
  String get name;
  int get order;
  @ClientCreatedTimestamp()
  DateTime? get createdDateTime;
  @ClientUpdatedTimestamp()
  DateTime? get updatedDateTime;
  @ServerCreatedTimestamp()
  DateTime? get serverCreatedDateTime;
  @ServerUpdatedTimestamp()
  DateTime? get serverUpdatedDateTime;

  /// Create a copy of GroupShoppingListItemCategoryAxis
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $GroupShoppingListItemCategoryAxisCopyWith<GroupShoppingListItemCategoryAxis>
      get copyWith => _$GroupShoppingListItemCategoryAxisCopyWithImpl<
              GroupShoppingListItemCategoryAxis>(
          this as GroupShoppingListItemCategoryAxis, _$identity);

  /// Serializes this GroupShoppingListItemCategoryAxis to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is GroupShoppingListItemCategoryAxis &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.groupID, groupID) || other.groupID == groupID) &&
            (identical(other.userID, userID) || other.userID == userID) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.order, order) || other.order == order) &&
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
      userID,
      name,
      order,
      createdDateTime,
      updatedDateTime,
      serverCreatedDateTime,
      serverUpdatedDateTime);

  @override
  String toString() {
    return 'GroupShoppingListItemCategoryAxis(id: $id, groupID: $groupID, userID: $userID, name: $name, order: $order, createdDateTime: $createdDateTime, updatedDateTime: $updatedDateTime, serverCreatedDateTime: $serverCreatedDateTime, serverUpdatedDateTime: $serverUpdatedDateTime)';
  }
}

/// @nodoc
abstract mixin class $GroupShoppingListItemCategoryAxisCopyWith<$Res> {
  factory $GroupShoppingListItemCategoryAxisCopyWith(
          GroupShoppingListItemCategoryAxis value,
          $Res Function(GroupShoppingListItemCategoryAxis) _then) =
      _$GroupShoppingListItemCategoryAxisCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String groupID,
      String userID,
      String name,
      int order,
      @ClientCreatedTimestamp() DateTime? createdDateTime,
      @ClientUpdatedTimestamp() DateTime? updatedDateTime,
      @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
      @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime});
}

/// @nodoc
class _$GroupShoppingListItemCategoryAxisCopyWithImpl<$Res>
    implements $GroupShoppingListItemCategoryAxisCopyWith<$Res> {
  _$GroupShoppingListItemCategoryAxisCopyWithImpl(this._self, this._then);

  final GroupShoppingListItemCategoryAxis _self;
  final $Res Function(GroupShoppingListItemCategoryAxis) _then;

  /// Create a copy of GroupShoppingListItemCategoryAxis
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? groupID = null,
    Object? userID = null,
    Object? name = null,
    Object? order = null,
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
      userID: null == userID
          ? _self.userID
          : userID // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      order: null == order
          ? _self.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
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

/// Adds pattern-matching-related methods to [GroupShoppingListItemCategoryAxis].
extension GroupShoppingListItemCategoryAxisPatterns
    on GroupShoppingListItemCategoryAxis {
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
    TResult Function(_GroupShoppingListItemCategoryAxis value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GroupShoppingListItemCategoryAxis() when $default != null:
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
    TResult Function(_GroupShoppingListItemCategoryAxis value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GroupShoppingListItemCategoryAxis():
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
    TResult? Function(_GroupShoppingListItemCategoryAxis value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GroupShoppingListItemCategoryAxis() when $default != null:
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
            String userID,
            String name,
            int order,
            @ClientCreatedTimestamp() DateTime? createdDateTime,
            @ClientUpdatedTimestamp() DateTime? updatedDateTime,
            @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
            @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GroupShoppingListItemCategoryAxis() when $default != null:
        return $default(
            _that.id,
            _that.groupID,
            _that.userID,
            _that.name,
            _that.order,
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
            String userID,
            String name,
            int order,
            @ClientCreatedTimestamp() DateTime? createdDateTime,
            @ClientUpdatedTimestamp() DateTime? updatedDateTime,
            @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
            @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GroupShoppingListItemCategoryAxis():
        return $default(
            _that.id,
            _that.groupID,
            _that.userID,
            _that.name,
            _that.order,
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
            String userID,
            String name,
            int order,
            @ClientCreatedTimestamp() DateTime? createdDateTime,
            @ClientUpdatedTimestamp() DateTime? updatedDateTime,
            @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
            @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GroupShoppingListItemCategoryAxis() when $default != null:
        return $default(
            _that.id,
            _that.groupID,
            _that.userID,
            _that.name,
            _that.order,
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
class _GroupShoppingListItemCategoryAxis
    extends GroupShoppingListItemCategoryAxis {
  const _GroupShoppingListItemCategoryAxis(
      {required this.id,
      required this.groupID,
      required this.userID,
      required this.name,
      required this.order,
      @ClientCreatedTimestamp() this.createdDateTime,
      @ClientUpdatedTimestamp() this.updatedDateTime,
      @ServerCreatedTimestamp() this.serverCreatedDateTime,
      @ServerUpdatedTimestamp() this.serverUpdatedDateTime})
      : super._();
  factory _GroupShoppingListItemCategoryAxis.fromJson(
          Map<String, dynamic> json) =>
      _$GroupShoppingListItemCategoryAxisFromJson(json);

  @override
  final String id;
  @override
  final String groupID;
  @override
  final String userID;
  @override
  final String name;
  @override
  final int order;
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

  /// Create a copy of GroupShoppingListItemCategoryAxis
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$GroupShoppingListItemCategoryAxisCopyWith<
          _GroupShoppingListItemCategoryAxis>
      get copyWith => __$GroupShoppingListItemCategoryAxisCopyWithImpl<
          _GroupShoppingListItemCategoryAxis>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$GroupShoppingListItemCategoryAxisToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _GroupShoppingListItemCategoryAxis &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.groupID, groupID) || other.groupID == groupID) &&
            (identical(other.userID, userID) || other.userID == userID) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.order, order) || other.order == order) &&
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
      userID,
      name,
      order,
      createdDateTime,
      updatedDateTime,
      serverCreatedDateTime,
      serverUpdatedDateTime);

  @override
  String toString() {
    return 'GroupShoppingListItemCategoryAxis(id: $id, groupID: $groupID, userID: $userID, name: $name, order: $order, createdDateTime: $createdDateTime, updatedDateTime: $updatedDateTime, serverCreatedDateTime: $serverCreatedDateTime, serverUpdatedDateTime: $serverUpdatedDateTime)';
  }
}

/// @nodoc
abstract mixin class _$GroupShoppingListItemCategoryAxisCopyWith<$Res>
    implements $GroupShoppingListItemCategoryAxisCopyWith<$Res> {
  factory _$GroupShoppingListItemCategoryAxisCopyWith(
          _GroupShoppingListItemCategoryAxis value,
          $Res Function(_GroupShoppingListItemCategoryAxis) _then) =
      __$GroupShoppingListItemCategoryAxisCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String groupID,
      String userID,
      String name,
      int order,
      @ClientCreatedTimestamp() DateTime? createdDateTime,
      @ClientUpdatedTimestamp() DateTime? updatedDateTime,
      @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
      @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime});
}

/// @nodoc
class __$GroupShoppingListItemCategoryAxisCopyWithImpl<$Res>
    implements _$GroupShoppingListItemCategoryAxisCopyWith<$Res> {
  __$GroupShoppingListItemCategoryAxisCopyWithImpl(this._self, this._then);

  final _GroupShoppingListItemCategoryAxis _self;
  final $Res Function(_GroupShoppingListItemCategoryAxis) _then;

  /// Create a copy of GroupShoppingListItemCategoryAxis
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? groupID = null,
    Object? userID = null,
    Object? name = null,
    Object? order = null,
    Object? createdDateTime = freezed,
    Object? updatedDateTime = freezed,
    Object? serverCreatedDateTime = freezed,
    Object? serverUpdatedDateTime = freezed,
  }) {
    return _then(_GroupShoppingListItemCategoryAxis(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      groupID: null == groupID
          ? _self.groupID
          : groupID // ignore: cast_nullable_to_non_nullable
              as String,
      userID: null == userID
          ? _self.userID
          : userID // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      order: null == order
          ? _self.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
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
