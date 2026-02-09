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
GroupShoppingListItem _$GroupShoppingListItemFromJson(
    Map<String, dynamic> json) {
  switch (json['type']) {
    case 'text':
      return TextGroupShoppingListItem.fromJson(json);
    case 'link':
      return LinkGroupShoppingListItem.fromJson(json);

    default:
      throw CheckedFromJsonException(json, 'type', 'GroupShoppingListItem',
          'Invalid union type "${json['type']}"!');
  }
}

/// @nodoc
mixin _$GroupShoppingListItem {
  String get id;
  String get shoppingListID; // NOTE: 0,1,3と飛ぶことがある。削除時にorderを詰めることはしてない
// NOTE: 0,1,2,2 と同列になることも許容する。確認はされてないが、orderが同じであっても良い
  int get order;
  GroupShoppingListItemStatus get status;
  String? get description;
  String? get color;
  String? get groupShoppingListItemCategoryID;
  @NullableTimestampConverter()
  DateTime? get reminderDateTime;
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
            (identical(other.shoppingListID, shoppingListID) ||
                other.shoppingListID == shoppingListID) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.groupShoppingListItemCategoryID,
                    groupShoppingListItemCategoryID) ||
                other.groupShoppingListItemCategoryID ==
                    groupShoppingListItemCategoryID) &&
            (identical(other.reminderDateTime, reminderDateTime) ||
                other.reminderDateTime == reminderDateTime) &&
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
      shoppingListID,
      order,
      status,
      description,
      color,
      groupShoppingListItemCategoryID,
      reminderDateTime,
      createdDateTime,
      updatedDateTime,
      serverCreatedDateTime,
      serverUpdatedDateTime);

  @override
  String toString() {
    return 'GroupShoppingListItem(id: $id, shoppingListID: $shoppingListID, order: $order, status: $status, description: $description, color: $color, groupShoppingListItemCategoryID: $groupShoppingListItemCategoryID, reminderDateTime: $reminderDateTime, createdDateTime: $createdDateTime, updatedDateTime: $updatedDateTime, serverCreatedDateTime: $serverCreatedDateTime, serverUpdatedDateTime: $serverUpdatedDateTime)';
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
      String shoppingListID,
      int order,
      GroupShoppingListItemStatus status,
      String? description,
      String? color,
      String? groupShoppingListItemCategoryID,
      @NullableTimestampConverter() DateTime? reminderDateTime,
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
    Object? shoppingListID = null,
    Object? order = null,
    Object? status = null,
    Object? description = freezed,
    Object? color = freezed,
    Object? groupShoppingListItemCategoryID = freezed,
    Object? reminderDateTime = freezed,
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
      shoppingListID: null == shoppingListID
          ? _self.shoppingListID
          : shoppingListID // ignore: cast_nullable_to_non_nullable
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
      groupShoppingListItemCategoryID: freezed ==
              groupShoppingListItemCategoryID
          ? _self.groupShoppingListItemCategoryID
          : groupShoppingListItemCategoryID // ignore: cast_nullable_to_non_nullable
              as String?,
      reminderDateTime: freezed == reminderDateTime
          ? _self.reminderDateTime
          : reminderDateTime // ignore: cast_nullable_to_non_nullable
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
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TextGroupShoppingListItem value)? text,
    TResult Function(LinkGroupShoppingListItem value)? link,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case TextGroupShoppingListItem() when text != null:
        return text(_that);
      case LinkGroupShoppingListItem() when link != null:
        return link(_that);
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
  TResult map<TResult extends Object?>({
    required TResult Function(TextGroupShoppingListItem value) text,
    required TResult Function(LinkGroupShoppingListItem value) link,
  }) {
    final _that = this;
    switch (_that) {
      case TextGroupShoppingListItem():
        return text(_that);
      case LinkGroupShoppingListItem():
        return link(_that);
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
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TextGroupShoppingListItem value)? text,
    TResult? Function(LinkGroupShoppingListItem value)? link,
  }) {
    final _that = this;
    switch (_that) {
      case TextGroupShoppingListItem() when text != null:
        return text(_that);
      case LinkGroupShoppingListItem() when link != null:
        return link(_that);
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
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String id,
            String shoppingListID,
            String message,
            int order,
            GroupShoppingListItemStatus status,
            String? description,
            String? color,
            String? groupShoppingListItemCategoryID,
            @NullableTimestampConverter() DateTime? reminderDateTime,
            @ClientCreatedTimestamp() DateTime? createdDateTime,
            @ClientUpdatedTimestamp() DateTime? updatedDateTime,
            @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
            @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime)?
        text,
    TResult Function(
            String id,
            String shoppingListID,
            String url,
            int order,
            String? metadataTitle,
            String? metadataDescription,
            String? metadataImageURL,
            GroupShoppingListItemStatus status,
            String? description,
            String? color,
            String? groupShoppingListItemCategoryID,
            @NullableTimestampConverter() DateTime? reminderDateTime,
            @ClientCreatedTimestamp() DateTime? createdDateTime,
            @ClientUpdatedTimestamp() DateTime? updatedDateTime,
            @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
            @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime)?
        link,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case TextGroupShoppingListItem() when text != null:
        return text(
            _that.id,
            _that.shoppingListID,
            _that.message,
            _that.order,
            _that.status,
            _that.description,
            _that.color,
            _that.groupShoppingListItemCategoryID,
            _that.reminderDateTime,
            _that.createdDateTime,
            _that.updatedDateTime,
            _that.serverCreatedDateTime,
            _that.serverUpdatedDateTime);
      case LinkGroupShoppingListItem() when link != null:
        return link(
            _that.id,
            _that.shoppingListID,
            _that.url,
            _that.order,
            _that.metadataTitle,
            _that.metadataDescription,
            _that.metadataImageURL,
            _that.status,
            _that.description,
            _that.color,
            _that.groupShoppingListItemCategoryID,
            _that.reminderDateTime,
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
  TResult when<TResult extends Object?>({
    required TResult Function(
            String id,
            String shoppingListID,
            String message,
            int order,
            GroupShoppingListItemStatus status,
            String? description,
            String? color,
            String? groupShoppingListItemCategoryID,
            @NullableTimestampConverter() DateTime? reminderDateTime,
            @ClientCreatedTimestamp() DateTime? createdDateTime,
            @ClientUpdatedTimestamp() DateTime? updatedDateTime,
            @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
            @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime)
        text,
    required TResult Function(
            String id,
            String shoppingListID,
            String url,
            int order,
            String? metadataTitle,
            String? metadataDescription,
            String? metadataImageURL,
            GroupShoppingListItemStatus status,
            String? description,
            String? color,
            String? groupShoppingListItemCategoryID,
            @NullableTimestampConverter() DateTime? reminderDateTime,
            @ClientCreatedTimestamp() DateTime? createdDateTime,
            @ClientUpdatedTimestamp() DateTime? updatedDateTime,
            @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
            @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime)
        link,
  }) {
    final _that = this;
    switch (_that) {
      case TextGroupShoppingListItem():
        return text(
            _that.id,
            _that.shoppingListID,
            _that.message,
            _that.order,
            _that.status,
            _that.description,
            _that.color,
            _that.groupShoppingListItemCategoryID,
            _that.reminderDateTime,
            _that.createdDateTime,
            _that.updatedDateTime,
            _that.serverCreatedDateTime,
            _that.serverUpdatedDateTime);
      case LinkGroupShoppingListItem():
        return link(
            _that.id,
            _that.shoppingListID,
            _that.url,
            _that.order,
            _that.metadataTitle,
            _that.metadataDescription,
            _that.metadataImageURL,
            _that.status,
            _that.description,
            _that.color,
            _that.groupShoppingListItemCategoryID,
            _that.reminderDateTime,
            _that.createdDateTime,
            _that.updatedDateTime,
            _that.serverCreatedDateTime,
            _that.serverUpdatedDateTime);
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
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String id,
            String shoppingListID,
            String message,
            int order,
            GroupShoppingListItemStatus status,
            String? description,
            String? color,
            String? groupShoppingListItemCategoryID,
            @NullableTimestampConverter() DateTime? reminderDateTime,
            @ClientCreatedTimestamp() DateTime? createdDateTime,
            @ClientUpdatedTimestamp() DateTime? updatedDateTime,
            @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
            @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime)?
        text,
    TResult? Function(
            String id,
            String shoppingListID,
            String url,
            int order,
            String? metadataTitle,
            String? metadataDescription,
            String? metadataImageURL,
            GroupShoppingListItemStatus status,
            String? description,
            String? color,
            String? groupShoppingListItemCategoryID,
            @NullableTimestampConverter() DateTime? reminderDateTime,
            @ClientCreatedTimestamp() DateTime? createdDateTime,
            @ClientUpdatedTimestamp() DateTime? updatedDateTime,
            @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
            @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime)?
        link,
  }) {
    final _that = this;
    switch (_that) {
      case TextGroupShoppingListItem() when text != null:
        return text(
            _that.id,
            _that.shoppingListID,
            _that.message,
            _that.order,
            _that.status,
            _that.description,
            _that.color,
            _that.groupShoppingListItemCategoryID,
            _that.reminderDateTime,
            _that.createdDateTime,
            _that.updatedDateTime,
            _that.serverCreatedDateTime,
            _that.serverUpdatedDateTime);
      case LinkGroupShoppingListItem() when link != null:
        return link(
            _that.id,
            _that.shoppingListID,
            _that.url,
            _that.order,
            _that.metadataTitle,
            _that.metadataDescription,
            _that.metadataImageURL,
            _that.status,
            _that.description,
            _that.color,
            _that.groupShoppingListItemCategoryID,
            _that.reminderDateTime,
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
class TextGroupShoppingListItem implements GroupShoppingListItem {
  const TextGroupShoppingListItem(
      {required this.id,
      required this.shoppingListID,
      required this.message,
      required this.order,
      this.status = GroupShoppingListItemStatus.unchecked,
      this.description,
      this.color,
      this.groupShoppingListItemCategoryID,
      @NullableTimestampConverter() this.reminderDateTime,
      @ClientCreatedTimestamp() this.createdDateTime,
      @ClientUpdatedTimestamp() this.updatedDateTime,
      @ServerCreatedTimestamp() this.serverCreatedDateTime,
      @ServerUpdatedTimestamp() this.serverUpdatedDateTime,
      final String? $type})
      : $type = $type ?? 'text';
  factory TextGroupShoppingListItem.fromJson(Map<String, dynamic> json) =>
      _$TextGroupShoppingListItemFromJson(json);

  @override
  final String id;
  @override
  final String shoppingListID;
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
  final String? groupShoppingListItemCategoryID;
  @override
  @NullableTimestampConverter()
  final DateTime? reminderDateTime;
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

  @JsonKey(name: 'type')
  final String $type;

  /// Create a copy of GroupShoppingListItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TextGroupShoppingListItemCopyWith<TextGroupShoppingListItem> get copyWith =>
      _$TextGroupShoppingListItemCopyWithImpl<TextGroupShoppingListItem>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$TextGroupShoppingListItemToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TextGroupShoppingListItem &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.shoppingListID, shoppingListID) ||
                other.shoppingListID == shoppingListID) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.groupShoppingListItemCategoryID,
                    groupShoppingListItemCategoryID) ||
                other.groupShoppingListItemCategoryID ==
                    groupShoppingListItemCategoryID) &&
            (identical(other.reminderDateTime, reminderDateTime) ||
                other.reminderDateTime == reminderDateTime) &&
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
      shoppingListID,
      message,
      order,
      status,
      description,
      color,
      groupShoppingListItemCategoryID,
      reminderDateTime,
      createdDateTime,
      updatedDateTime,
      serverCreatedDateTime,
      serverUpdatedDateTime);

  @override
  String toString() {
    return 'GroupShoppingListItem.text(id: $id, shoppingListID: $shoppingListID, message: $message, order: $order, status: $status, description: $description, color: $color, groupShoppingListItemCategoryID: $groupShoppingListItemCategoryID, reminderDateTime: $reminderDateTime, createdDateTime: $createdDateTime, updatedDateTime: $updatedDateTime, serverCreatedDateTime: $serverCreatedDateTime, serverUpdatedDateTime: $serverUpdatedDateTime)';
  }
}

/// @nodoc
abstract mixin class $TextGroupShoppingListItemCopyWith<$Res>
    implements $GroupShoppingListItemCopyWith<$Res> {
  factory $TextGroupShoppingListItemCopyWith(TextGroupShoppingListItem value,
          $Res Function(TextGroupShoppingListItem) _then) =
      _$TextGroupShoppingListItemCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String shoppingListID,
      String message,
      int order,
      GroupShoppingListItemStatus status,
      String? description,
      String? color,
      String? groupShoppingListItemCategoryID,
      @NullableTimestampConverter() DateTime? reminderDateTime,
      @ClientCreatedTimestamp() DateTime? createdDateTime,
      @ClientUpdatedTimestamp() DateTime? updatedDateTime,
      @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
      @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime});
}

/// @nodoc
class _$TextGroupShoppingListItemCopyWithImpl<$Res>
    implements $TextGroupShoppingListItemCopyWith<$Res> {
  _$TextGroupShoppingListItemCopyWithImpl(this._self, this._then);

  final TextGroupShoppingListItem _self;
  final $Res Function(TextGroupShoppingListItem) _then;

  /// Create a copy of GroupShoppingListItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? shoppingListID = null,
    Object? message = null,
    Object? order = null,
    Object? status = null,
    Object? description = freezed,
    Object? color = freezed,
    Object? groupShoppingListItemCategoryID = freezed,
    Object? reminderDateTime = freezed,
    Object? createdDateTime = freezed,
    Object? updatedDateTime = freezed,
    Object? serverCreatedDateTime = freezed,
    Object? serverUpdatedDateTime = freezed,
  }) {
    return _then(TextGroupShoppingListItem(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      shoppingListID: null == shoppingListID
          ? _self.shoppingListID
          : shoppingListID // ignore: cast_nullable_to_non_nullable
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
      groupShoppingListItemCategoryID: freezed ==
              groupShoppingListItemCategoryID
          ? _self.groupShoppingListItemCategoryID
          : groupShoppingListItemCategoryID // ignore: cast_nullable_to_non_nullable
              as String?,
      reminderDateTime: freezed == reminderDateTime
          ? _self.reminderDateTime
          : reminderDateTime // ignore: cast_nullable_to_non_nullable
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

/// @nodoc

@JsonSerializable(explicitToJson: true)
class LinkGroupShoppingListItem implements GroupShoppingListItem {
  const LinkGroupShoppingListItem(
      {required this.id,
      required this.shoppingListID,
      required this.url,
      required this.order,
      this.metadataTitle,
      this.metadataDescription,
      this.metadataImageURL,
      this.status = GroupShoppingListItemStatus.unchecked,
      this.description,
      this.color,
      this.groupShoppingListItemCategoryID,
      @NullableTimestampConverter() this.reminderDateTime,
      @ClientCreatedTimestamp() this.createdDateTime,
      @ClientUpdatedTimestamp() this.updatedDateTime,
      @ServerCreatedTimestamp() this.serverCreatedDateTime,
      @ServerUpdatedTimestamp() this.serverUpdatedDateTime,
      final String? $type})
      : $type = $type ?? 'link';
  factory LinkGroupShoppingListItem.fromJson(Map<String, dynamic> json) =>
      _$LinkGroupShoppingListItemFromJson(json);

  @override
  final String id;
  @override
  final String shoppingListID;
  final String url;
// NOTE: 0,1,3と飛ぶことがある。削除時にorderを詰めることはしてない
// NOTE: 0,1,2,2 と同列になることも許容する。確認はされてないが、orderが同じであっても良い
  @override
  final int order;
  final String? metadataTitle;
  final String? metadataDescription;
  final String? metadataImageURL;
  @override
  @JsonKey()
  final GroupShoppingListItemStatus status;
  @override
  final String? description;
  @override
  final String? color;
  @override
  final String? groupShoppingListItemCategoryID;
  @override
  @NullableTimestampConverter()
  final DateTime? reminderDateTime;
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

  @JsonKey(name: 'type')
  final String $type;

  /// Create a copy of GroupShoppingListItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $LinkGroupShoppingListItemCopyWith<LinkGroupShoppingListItem> get copyWith =>
      _$LinkGroupShoppingListItemCopyWithImpl<LinkGroupShoppingListItem>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$LinkGroupShoppingListItemToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is LinkGroupShoppingListItem &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.shoppingListID, shoppingListID) ||
                other.shoppingListID == shoppingListID) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.metadataTitle, metadataTitle) ||
                other.metadataTitle == metadataTitle) &&
            (identical(other.metadataDescription, metadataDescription) ||
                other.metadataDescription == metadataDescription) &&
            (identical(other.metadataImageURL, metadataImageURL) ||
                other.metadataImageURL == metadataImageURL) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.groupShoppingListItemCategoryID,
                    groupShoppingListItemCategoryID) ||
                other.groupShoppingListItemCategoryID ==
                    groupShoppingListItemCategoryID) &&
            (identical(other.reminderDateTime, reminderDateTime) ||
                other.reminderDateTime == reminderDateTime) &&
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
      shoppingListID,
      url,
      order,
      metadataTitle,
      metadataDescription,
      metadataImageURL,
      status,
      description,
      color,
      groupShoppingListItemCategoryID,
      reminderDateTime,
      createdDateTime,
      updatedDateTime,
      serverCreatedDateTime,
      serverUpdatedDateTime);

  @override
  String toString() {
    return 'GroupShoppingListItem.link(id: $id, shoppingListID: $shoppingListID, url: $url, order: $order, metadataTitle: $metadataTitle, metadataDescription: $metadataDescription, metadataImageURL: $metadataImageURL, status: $status, description: $description, color: $color, groupShoppingListItemCategoryID: $groupShoppingListItemCategoryID, reminderDateTime: $reminderDateTime, createdDateTime: $createdDateTime, updatedDateTime: $updatedDateTime, serverCreatedDateTime: $serverCreatedDateTime, serverUpdatedDateTime: $serverUpdatedDateTime)';
  }
}

/// @nodoc
abstract mixin class $LinkGroupShoppingListItemCopyWith<$Res>
    implements $GroupShoppingListItemCopyWith<$Res> {
  factory $LinkGroupShoppingListItemCopyWith(LinkGroupShoppingListItem value,
          $Res Function(LinkGroupShoppingListItem) _then) =
      _$LinkGroupShoppingListItemCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String shoppingListID,
      String url,
      int order,
      String? metadataTitle,
      String? metadataDescription,
      String? metadataImageURL,
      GroupShoppingListItemStatus status,
      String? description,
      String? color,
      String? groupShoppingListItemCategoryID,
      @NullableTimestampConverter() DateTime? reminderDateTime,
      @ClientCreatedTimestamp() DateTime? createdDateTime,
      @ClientUpdatedTimestamp() DateTime? updatedDateTime,
      @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
      @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime});
}

/// @nodoc
class _$LinkGroupShoppingListItemCopyWithImpl<$Res>
    implements $LinkGroupShoppingListItemCopyWith<$Res> {
  _$LinkGroupShoppingListItemCopyWithImpl(this._self, this._then);

  final LinkGroupShoppingListItem _self;
  final $Res Function(LinkGroupShoppingListItem) _then;

  /// Create a copy of GroupShoppingListItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? shoppingListID = null,
    Object? url = null,
    Object? order = null,
    Object? metadataTitle = freezed,
    Object? metadataDescription = freezed,
    Object? metadataImageURL = freezed,
    Object? status = null,
    Object? description = freezed,
    Object? color = freezed,
    Object? groupShoppingListItemCategoryID = freezed,
    Object? reminderDateTime = freezed,
    Object? createdDateTime = freezed,
    Object? updatedDateTime = freezed,
    Object? serverCreatedDateTime = freezed,
    Object? serverUpdatedDateTime = freezed,
  }) {
    return _then(LinkGroupShoppingListItem(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      shoppingListID: null == shoppingListID
          ? _self.shoppingListID
          : shoppingListID // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _self.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      order: null == order
          ? _self.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      metadataTitle: freezed == metadataTitle
          ? _self.metadataTitle
          : metadataTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      metadataDescription: freezed == metadataDescription
          ? _self.metadataDescription
          : metadataDescription // ignore: cast_nullable_to_non_nullable
              as String?,
      metadataImageURL: freezed == metadataImageURL
          ? _self.metadataImageURL
          : metadataImageURL // ignore: cast_nullable_to_non_nullable
              as String?,
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
      groupShoppingListItemCategoryID: freezed ==
              groupShoppingListItemCategoryID
          ? _self.groupShoppingListItemCategoryID
          : groupShoppingListItemCategoryID // ignore: cast_nullable_to_non_nullable
              as String?,
      reminderDateTime: freezed == reminderDateTime
          ? _self.reminderDateTime
          : reminderDateTime // ignore: cast_nullable_to_non_nullable
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
