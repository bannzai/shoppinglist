// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group_shopping_list_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GroupShoppingListItem {
  String get id;
  String get groupID;
  String get shoppingListID;
  String get userID;
  String get message; // NOTE: 0,1,3と飛ぶことがある。削除時にorderを詰めることはしてない
// NOTE: 0,1,2,2 と同列になることも許容する。確認はされてないが、orderが同じであっても良い
  int get order;
  GroupShoppingListItemStatus get status;
  String? get description;
  String? get color;
  @NullableTimestampConverter()
  DateTime? get reminderDateTime;
  String? get checkedByUserID;
  @NullableTimestampConverter()
  DateTime? get lastCheckedDateTime;
  String? get lastEditedByUserID;
  @NullableTimestampConverter()
  DateTime? get lastEditedDateTime;
  @ClientCreatedTimestamp()
  DateTime? get createdDateTime;
  @ClientUpdatedTimestamp()
  DateTime? get updatedDateTime;
  @ServerCreatedTimestamp()
  DateTime? get serverCreatedDateTime;
  @ServerUpdatedTimestamp()
  DateTime? get serverUpdatedDateTime;

  /// Create a copy of GroupShoppingListItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $GroupShoppingListItemCopyWith<GroupShoppingListItem> get copyWith =>
      _$GroupShoppingListItemCopyWithImpl<GroupShoppingListItem>(
          this as GroupShoppingListItem, _$identity);

  /// Serializes this GroupShoppingListItem to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is GroupShoppingListItem &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.groupID, groupID) || other.groupID == groupID) &&
            (identical(other.shoppingListID, shoppingListID) ||
                other.shoppingListID == shoppingListID) &&
            (identical(other.userID, userID) || other.userID == userID) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.reminderDateTime, reminderDateTime) ||
                other.reminderDateTime == reminderDateTime) &&
            (identical(other.checkedByUserID, checkedByUserID) ||
                other.checkedByUserID == checkedByUserID) &&
            (identical(other.lastCheckedDateTime, lastCheckedDateTime) ||
                other.lastCheckedDateTime == lastCheckedDateTime) &&
            (identical(other.lastEditedByUserID, lastEditedByUserID) ||
                other.lastEditedByUserID == lastEditedByUserID) &&
            (identical(other.lastEditedDateTime, lastEditedDateTime) ||
                other.lastEditedDateTime == lastEditedDateTime) &&
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
      shoppingListID,
      userID,
      message,
      order,
      status,
      description,
      color,
      reminderDateTime,
      checkedByUserID,
      lastCheckedDateTime,
      lastEditedByUserID,
      lastEditedDateTime,
      createdDateTime,
      updatedDateTime,
      serverCreatedDateTime,
      serverUpdatedDateTime);

  @override
  String toString() {
    return 'GroupShoppingListItem(id: $id, groupID: $groupID, shoppingListID: $shoppingListID, userID: $userID, message: $message, order: $order, status: $status, description: $description, color: $color, reminderDateTime: $reminderDateTime, checkedByUserID: $checkedByUserID, lastCheckedDateTime: $lastCheckedDateTime, lastEditedByUserID: $lastEditedByUserID, lastEditedDateTime: $lastEditedDateTime, createdDateTime: $createdDateTime, updatedDateTime: $updatedDateTime, serverCreatedDateTime: $serverCreatedDateTime, serverUpdatedDateTime: $serverUpdatedDateTime)';
  }
}

/// @nodoc
abstract mixin class $GroupShoppingListItemCopyWith<$Res> {
  factory $GroupShoppingListItemCopyWith(GroupShoppingListItem value,
          $Res Function(GroupShoppingListItem) _then) =
      _$GroupShoppingListItemCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String groupID,
      String shoppingListID,
      String userID,
      String message,
      int order,
      GroupShoppingListItemStatus status,
      String? description,
      String? color,
      @NullableTimestampConverter() DateTime? reminderDateTime,
      String? checkedByUserID,
      @NullableTimestampConverter() DateTime? lastCheckedDateTime,
      String? lastEditedByUserID,
      @NullableTimestampConverter() DateTime? lastEditedDateTime,
      @ClientCreatedTimestamp() DateTime? createdDateTime,
      @ClientUpdatedTimestamp() DateTime? updatedDateTime,
      @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
      @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime});
}

/// @nodoc
class _$GroupShoppingListItemCopyWithImpl<$Res>
    implements $GroupShoppingListItemCopyWith<$Res> {
  _$GroupShoppingListItemCopyWithImpl(this._self, this._then);

  final GroupShoppingListItem _self;
  final $Res Function(GroupShoppingListItem) _then;

  /// Create a copy of GroupShoppingListItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? groupID = null,
    Object? shoppingListID = null,
    Object? userID = null,
    Object? message = null,
    Object? order = null,
    Object? status = null,
    Object? description = freezed,
    Object? color = freezed,
    Object? reminderDateTime = freezed,
    Object? checkedByUserID = freezed,
    Object? lastCheckedDateTime = freezed,
    Object? lastEditedByUserID = freezed,
    Object? lastEditedDateTime = freezed,
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
      shoppingListID: null == shoppingListID
          ? _self.shoppingListID
          : shoppingListID // ignore: cast_nullable_to_non_nullable
              as String,
      userID: null == userID
          ? _self.userID
          : userID // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      order: null == order
          ? _self.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as GroupShoppingListItemStatus,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      color: freezed == color
          ? _self.color
          : color // ignore: cast_nullable_to_non_nullable
              as String?,
      reminderDateTime: freezed == reminderDateTime
          ? _self.reminderDateTime
          : reminderDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      checkedByUserID: freezed == checkedByUserID
          ? _self.checkedByUserID
          : checkedByUserID // ignore: cast_nullable_to_non_nullable
              as String?,
      lastCheckedDateTime: freezed == lastCheckedDateTime
          ? _self.lastCheckedDateTime
          : lastCheckedDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastEditedByUserID: freezed == lastEditedByUserID
          ? _self.lastEditedByUserID
          : lastEditedByUserID // ignore: cast_nullable_to_non_nullable
              as String?,
      lastEditedDateTime: freezed == lastEditedDateTime
          ? _self.lastEditedDateTime
          : lastEditedDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
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

/// Adds pattern-matching-related methods to [GroupShoppingListItem].
extension GroupShoppingListItemPatterns on GroupShoppingListItem {
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
    TResult Function(_GroupShoppingListItem value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GroupShoppingListItem() when $default != null:
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
    TResult Function(_GroupShoppingListItem value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GroupShoppingListItem():
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
    TResult? Function(_GroupShoppingListItem value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GroupShoppingListItem() when $default != null:
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
            String shoppingListID,
            String userID,
            String message,
            int order,
            GroupShoppingListItemStatus status,
            String? description,
            String? color,
            @NullableTimestampConverter() DateTime? reminderDateTime,
            String? checkedByUserID,
            @NullableTimestampConverter() DateTime? lastCheckedDateTime,
            String? lastEditedByUserID,
            @NullableTimestampConverter() DateTime? lastEditedDateTime,
            @ClientCreatedTimestamp() DateTime? createdDateTime,
            @ClientUpdatedTimestamp() DateTime? updatedDateTime,
            @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
            @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GroupShoppingListItem() when $default != null:
        return $default(
            _that.id,
            _that.groupID,
            _that.shoppingListID,
            _that.userID,
            _that.message,
            _that.order,
            _that.status,
            _that.description,
            _that.color,
            _that.reminderDateTime,
            _that.checkedByUserID,
            _that.lastCheckedDateTime,
            _that.lastEditedByUserID,
            _that.lastEditedDateTime,
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
            String shoppingListID,
            String userID,
            String message,
            int order,
            GroupShoppingListItemStatus status,
            String? description,
            String? color,
            @NullableTimestampConverter() DateTime? reminderDateTime,
            String? checkedByUserID,
            @NullableTimestampConverter() DateTime? lastCheckedDateTime,
            String? lastEditedByUserID,
            @NullableTimestampConverter() DateTime? lastEditedDateTime,
            @ClientCreatedTimestamp() DateTime? createdDateTime,
            @ClientUpdatedTimestamp() DateTime? updatedDateTime,
            @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
            @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GroupShoppingListItem():
        return $default(
            _that.id,
            _that.groupID,
            _that.shoppingListID,
            _that.userID,
            _that.message,
            _that.order,
            _that.status,
            _that.description,
            _that.color,
            _that.reminderDateTime,
            _that.checkedByUserID,
            _that.lastCheckedDateTime,
            _that.lastEditedByUserID,
            _that.lastEditedDateTime,
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
            String shoppingListID,
            String userID,
            String message,
            int order,
            GroupShoppingListItemStatus status,
            String? description,
            String? color,
            @NullableTimestampConverter() DateTime? reminderDateTime,
            String? checkedByUserID,
            @NullableTimestampConverter() DateTime? lastCheckedDateTime,
            String? lastEditedByUserID,
            @NullableTimestampConverter() DateTime? lastEditedDateTime,
            @ClientCreatedTimestamp() DateTime? createdDateTime,
            @ClientUpdatedTimestamp() DateTime? updatedDateTime,
            @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
            @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GroupShoppingListItem() when $default != null:
        return $default(
            _that.id,
            _that.groupID,
            _that.shoppingListID,
            _that.userID,
            _that.message,
            _that.order,
            _that.status,
            _that.description,
            _that.color,
            _that.reminderDateTime,
            _that.checkedByUserID,
            _that.lastCheckedDateTime,
            _that.lastEditedByUserID,
            _that.lastEditedDateTime,
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
class _GroupShoppingListItem implements GroupShoppingListItem {
  const _GroupShoppingListItem(
      {required this.id,
      required this.groupID,
      required this.shoppingListID,
      required this.userID,
      required this.message,
      required this.order,
      this.status = GroupShoppingListItemStatus.unchecked,
      this.description,
      this.color,
      @NullableTimestampConverter() this.reminderDateTime,
      this.checkedByUserID,
      @NullableTimestampConverter() this.lastCheckedDateTime,
      this.lastEditedByUserID,
      @NullableTimestampConverter() this.lastEditedDateTime,
      @ClientCreatedTimestamp() this.createdDateTime,
      @ClientUpdatedTimestamp() this.updatedDateTime,
      @ServerCreatedTimestamp() this.serverCreatedDateTime,
      @ServerUpdatedTimestamp() this.serverUpdatedDateTime});
  factory _GroupShoppingListItem.fromJson(Map<String, dynamic> json) =>
      _$GroupShoppingListItemFromJson(json);

  @override
  final String id;
  @override
  final String groupID;
  @override
  final String shoppingListID;
  @override
  final String userID;
  @override
  final String message;
// NOTE: 0,1,3と飛ぶことがある。削除時にorderを詰めることはしてない
// NOTE: 0,1,2,2 と同列になることも許容する。確認はされてないが、orderが同じであっても良い
  @override
  final int order;
  @override
  @JsonKey()
  final GroupShoppingListItemStatus status;
  @override
  final String? description;
  @override
  final String? color;
  @override
  @NullableTimestampConverter()
  final DateTime? reminderDateTime;
  @override
  final String? checkedByUserID;
  @override
  @NullableTimestampConverter()
  final DateTime? lastCheckedDateTime;
  @override
  final String? lastEditedByUserID;
  @override
  @NullableTimestampConverter()
  final DateTime? lastEditedDateTime;
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

  /// Create a copy of GroupShoppingListItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$GroupShoppingListItemCopyWith<_GroupShoppingListItem> get copyWith =>
      __$GroupShoppingListItemCopyWithImpl<_GroupShoppingListItem>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$GroupShoppingListItemToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _GroupShoppingListItem &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.groupID, groupID) || other.groupID == groupID) &&
            (identical(other.shoppingListID, shoppingListID) ||
                other.shoppingListID == shoppingListID) &&
            (identical(other.userID, userID) || other.userID == userID) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.reminderDateTime, reminderDateTime) ||
                other.reminderDateTime == reminderDateTime) &&
            (identical(other.checkedByUserID, checkedByUserID) ||
                other.checkedByUserID == checkedByUserID) &&
            (identical(other.lastCheckedDateTime, lastCheckedDateTime) ||
                other.lastCheckedDateTime == lastCheckedDateTime) &&
            (identical(other.lastEditedByUserID, lastEditedByUserID) ||
                other.lastEditedByUserID == lastEditedByUserID) &&
            (identical(other.lastEditedDateTime, lastEditedDateTime) ||
                other.lastEditedDateTime == lastEditedDateTime) &&
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
      shoppingListID,
      userID,
      message,
      order,
      status,
      description,
      color,
      reminderDateTime,
      checkedByUserID,
      lastCheckedDateTime,
      lastEditedByUserID,
      lastEditedDateTime,
      createdDateTime,
      updatedDateTime,
      serverCreatedDateTime,
      serverUpdatedDateTime);

  @override
  String toString() {
    return 'GroupShoppingListItem(id: $id, groupID: $groupID, shoppingListID: $shoppingListID, userID: $userID, message: $message, order: $order, status: $status, description: $description, color: $color, reminderDateTime: $reminderDateTime, checkedByUserID: $checkedByUserID, lastCheckedDateTime: $lastCheckedDateTime, lastEditedByUserID: $lastEditedByUserID, lastEditedDateTime: $lastEditedDateTime, createdDateTime: $createdDateTime, updatedDateTime: $updatedDateTime, serverCreatedDateTime: $serverCreatedDateTime, serverUpdatedDateTime: $serverUpdatedDateTime)';
  }
}

/// @nodoc
abstract mixin class _$GroupShoppingListItemCopyWith<$Res>
    implements $GroupShoppingListItemCopyWith<$Res> {
  factory _$GroupShoppingListItemCopyWith(_GroupShoppingListItem value,
          $Res Function(_GroupShoppingListItem) _then) =
      __$GroupShoppingListItemCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String groupID,
      String shoppingListID,
      String userID,
      String message,
      int order,
      GroupShoppingListItemStatus status,
      String? description,
      String? color,
      @NullableTimestampConverter() DateTime? reminderDateTime,
      String? checkedByUserID,
      @NullableTimestampConverter() DateTime? lastCheckedDateTime,
      String? lastEditedByUserID,
      @NullableTimestampConverter() DateTime? lastEditedDateTime,
      @ClientCreatedTimestamp() DateTime? createdDateTime,
      @ClientUpdatedTimestamp() DateTime? updatedDateTime,
      @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
      @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime});
}

/// @nodoc
class __$GroupShoppingListItemCopyWithImpl<$Res>
    implements _$GroupShoppingListItemCopyWith<$Res> {
  __$GroupShoppingListItemCopyWithImpl(this._self, this._then);

  final _GroupShoppingListItem _self;
  final $Res Function(_GroupShoppingListItem) _then;

  /// Create a copy of GroupShoppingListItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? groupID = null,
    Object? shoppingListID = null,
    Object? userID = null,
    Object? message = null,
    Object? order = null,
    Object? status = null,
    Object? description = freezed,
    Object? color = freezed,
    Object? reminderDateTime = freezed,
    Object? checkedByUserID = freezed,
    Object? lastCheckedDateTime = freezed,
    Object? lastEditedByUserID = freezed,
    Object? lastEditedDateTime = freezed,
    Object? createdDateTime = freezed,
    Object? updatedDateTime = freezed,
    Object? serverCreatedDateTime = freezed,
    Object? serverUpdatedDateTime = freezed,
  }) {
    return _then(_GroupShoppingListItem(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      groupID: null == groupID
          ? _self.groupID
          : groupID // ignore: cast_nullable_to_non_nullable
              as String,
      shoppingListID: null == shoppingListID
          ? _self.shoppingListID
          : shoppingListID // ignore: cast_nullable_to_non_nullable
              as String,
      userID: null == userID
          ? _self.userID
          : userID // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      order: null == order
          ? _self.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as GroupShoppingListItemStatus,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      color: freezed == color
          ? _self.color
          : color // ignore: cast_nullable_to_non_nullable
              as String?,
      reminderDateTime: freezed == reminderDateTime
          ? _self.reminderDateTime
          : reminderDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      checkedByUserID: freezed == checkedByUserID
          ? _self.checkedByUserID
          : checkedByUserID // ignore: cast_nullable_to_non_nullable
              as String?,
      lastCheckedDateTime: freezed == lastCheckedDateTime
          ? _self.lastCheckedDateTime
          : lastCheckedDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastEditedByUserID: freezed == lastEditedByUserID
          ? _self.lastEditedByUserID
          : lastEditedByUserID // ignore: cast_nullable_to_non_nullable
              as String?,
      lastEditedDateTime: freezed == lastEditedDateTime
          ? _self.lastEditedDateTime
          : lastEditedDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
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
