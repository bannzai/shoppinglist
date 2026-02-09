// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shopping_list_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
ShoppingListItem _$ShoppingListItemFromJson(Map<String, dynamic> json) {
  switch (json['type']) {
    case 'text':
      return TextShoppingListItem.fromJson(json);
    case 'link':
      return LinkShoppingListItem.fromJson(json);

    default:
      throw CheckedFromJsonException(json, 'type', 'ShoppingListItem',
          'Invalid union type "${json['type']}"!');
  }
}

/// @nodoc
mixin _$ShoppingListItem {
  String get id;
  String get shoppingListID; // NOTE: 0,1,3と飛ぶことがある。削除時にorderを詰めることはしてない
// NOTE: 0,1,2,2 と同列になることも許容する。確認はされてないが、orderが同じであっても良い
  int get order;
  ShoppingListItemStatus get status;
  String? get description;
  String? get color;
  String? get categoryID;
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

  /// Create a copy of ShoppingListItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ShoppingListItemCopyWith<ShoppingListItem> get copyWith =>
      _$ShoppingListItemCopyWithImpl<ShoppingListItem>(
          this as ShoppingListItem, _$identity);

  /// Serializes this ShoppingListItem to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ShoppingListItem &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.shoppingListID, shoppingListID) ||
                other.shoppingListID == shoppingListID) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.categoryID, categoryID) ||
                other.categoryID == categoryID) &&
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
      categoryID,
      reminderDateTime,
      createdDateTime,
      updatedDateTime,
      serverCreatedDateTime,
      serverUpdatedDateTime);

  @override
  String toString() {
    return 'ShoppingListItem(id: $id, shoppingListID: $shoppingListID, order: $order, status: $status, description: $description, color: $color, categoryID: $categoryID, reminderDateTime: $reminderDateTime, createdDateTime: $createdDateTime, updatedDateTime: $updatedDateTime, serverCreatedDateTime: $serverCreatedDateTime, serverUpdatedDateTime: $serverUpdatedDateTime)';
  }
}

/// @nodoc
abstract mixin class $ShoppingListItemCopyWith<$Res> {
  factory $ShoppingListItemCopyWith(
          ShoppingListItem value, $Res Function(ShoppingListItem) _then) =
      _$ShoppingListItemCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String shoppingListID,
      int order,
      ShoppingListItemStatus status,
      String? description,
      String? color,
      String? categoryID,
      @NullableTimestampConverter() DateTime? reminderDateTime,
      @ClientCreatedTimestamp() DateTime? createdDateTime,
      @ClientUpdatedTimestamp() DateTime? updatedDateTime,
      @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
      @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime});
}

/// @nodoc
class _$ShoppingListItemCopyWithImpl<$Res>
    implements $ShoppingListItemCopyWith<$Res> {
  _$ShoppingListItemCopyWithImpl(this._self, this._then);

  final ShoppingListItem _self;
  final $Res Function(ShoppingListItem) _then;

  /// Create a copy of ShoppingListItem
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
    Object? categoryID = freezed,
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
              as ShoppingListItemStatus,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      color: freezed == color
          ? _self.color
          : color // ignore: cast_nullable_to_non_nullable
              as String?,
      categoryID: freezed == categoryID
          ? _self.categoryID
          : categoryID // ignore: cast_nullable_to_non_nullable
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

/// Adds pattern-matching-related methods to [ShoppingListItem].
extension ShoppingListItemPatterns on ShoppingListItem {
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
    TResult Function(TextShoppingListItem value)? text,
    TResult Function(LinkShoppingListItem value)? link,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case TextShoppingListItem() when text != null:
        return text(_that);
      case LinkShoppingListItem() when link != null:
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
    required TResult Function(TextShoppingListItem value) text,
    required TResult Function(LinkShoppingListItem value) link,
  }) {
    final _that = this;
    switch (_that) {
      case TextShoppingListItem():
        return text(_that);
      case LinkShoppingListItem():
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
    TResult? Function(TextShoppingListItem value)? text,
    TResult? Function(LinkShoppingListItem value)? link,
  }) {
    final _that = this;
    switch (_that) {
      case TextShoppingListItem() when text != null:
        return text(_that);
      case LinkShoppingListItem() when link != null:
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
            ShoppingListItemStatus status,
            String? description,
            String? color,
            String? categoryID,
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
            ShoppingListItemStatus status,
            String? description,
            String? color,
            String? categoryID,
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
      case TextShoppingListItem() when text != null:
        return text(
            _that.id,
            _that.shoppingListID,
            _that.message,
            _that.order,
            _that.status,
            _that.description,
            _that.color,
            _that.categoryID,
            _that.reminderDateTime,
            _that.createdDateTime,
            _that.updatedDateTime,
            _that.serverCreatedDateTime,
            _that.serverUpdatedDateTime);
      case LinkShoppingListItem() when link != null:
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
            _that.categoryID,
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
            ShoppingListItemStatus status,
            String? description,
            String? color,
            String? categoryID,
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
            ShoppingListItemStatus status,
            String? description,
            String? color,
            String? categoryID,
            @NullableTimestampConverter() DateTime? reminderDateTime,
            @ClientCreatedTimestamp() DateTime? createdDateTime,
            @ClientUpdatedTimestamp() DateTime? updatedDateTime,
            @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
            @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime)
        link,
  }) {
    final _that = this;
    switch (_that) {
      case TextShoppingListItem():
        return text(
            _that.id,
            _that.shoppingListID,
            _that.message,
            _that.order,
            _that.status,
            _that.description,
            _that.color,
            _that.categoryID,
            _that.reminderDateTime,
            _that.createdDateTime,
            _that.updatedDateTime,
            _that.serverCreatedDateTime,
            _that.serverUpdatedDateTime);
      case LinkShoppingListItem():
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
            _that.categoryID,
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
            ShoppingListItemStatus status,
            String? description,
            String? color,
            String? categoryID,
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
            ShoppingListItemStatus status,
            String? description,
            String? color,
            String? categoryID,
            @NullableTimestampConverter() DateTime? reminderDateTime,
            @ClientCreatedTimestamp() DateTime? createdDateTime,
            @ClientUpdatedTimestamp() DateTime? updatedDateTime,
            @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
            @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime)?
        link,
  }) {
    final _that = this;
    switch (_that) {
      case TextShoppingListItem() when text != null:
        return text(
            _that.id,
            _that.shoppingListID,
            _that.message,
            _that.order,
            _that.status,
            _that.description,
            _that.color,
            _that.categoryID,
            _that.reminderDateTime,
            _that.createdDateTime,
            _that.updatedDateTime,
            _that.serverCreatedDateTime,
            _that.serverUpdatedDateTime);
      case LinkShoppingListItem() when link != null:
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
            _that.categoryID,
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
class TextShoppingListItem implements ShoppingListItem {
  const TextShoppingListItem(
      {required this.id,
      required this.shoppingListID,
      required this.message,
      required this.order,
      this.status = ShoppingListItemStatus.unchecked,
      this.description,
      this.color,
      this.categoryID,
      @NullableTimestampConverter() this.reminderDateTime,
      @ClientCreatedTimestamp() this.createdDateTime,
      @ClientUpdatedTimestamp() this.updatedDateTime,
      @ServerCreatedTimestamp() this.serverCreatedDateTime,
      @ServerUpdatedTimestamp() this.serverUpdatedDateTime,
      final String? $type})
      : $type = $type ?? 'text';
  factory TextShoppingListItem.fromJson(Map<String, dynamic> json) =>
      _$TextShoppingListItemFromJson(json);

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
  final ShoppingListItemStatus status;
  @override
  final String? description;
  @override
  final String? color;
  @override
  final String? categoryID;
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

  /// Create a copy of ShoppingListItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TextShoppingListItemCopyWith<TextShoppingListItem> get copyWith =>
      _$TextShoppingListItemCopyWithImpl<TextShoppingListItem>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$TextShoppingListItemToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TextShoppingListItem &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.shoppingListID, shoppingListID) ||
                other.shoppingListID == shoppingListID) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.categoryID, categoryID) ||
                other.categoryID == categoryID) &&
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
      categoryID,
      reminderDateTime,
      createdDateTime,
      updatedDateTime,
      serverCreatedDateTime,
      serverUpdatedDateTime);

  @override
  String toString() {
    return 'ShoppingListItem.text(id: $id, shoppingListID: $shoppingListID, message: $message, order: $order, status: $status, description: $description, color: $color, categoryID: $categoryID, reminderDateTime: $reminderDateTime, createdDateTime: $createdDateTime, updatedDateTime: $updatedDateTime, serverCreatedDateTime: $serverCreatedDateTime, serverUpdatedDateTime: $serverUpdatedDateTime)';
  }
}

/// @nodoc
abstract mixin class $TextShoppingListItemCopyWith<$Res>
    implements $ShoppingListItemCopyWith<$Res> {
  factory $TextShoppingListItemCopyWith(TextShoppingListItem value,
          $Res Function(TextShoppingListItem) _then) =
      _$TextShoppingListItemCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String shoppingListID,
      String message,
      int order,
      ShoppingListItemStatus status,
      String? description,
      String? color,
      String? categoryID,
      @NullableTimestampConverter() DateTime? reminderDateTime,
      @ClientCreatedTimestamp() DateTime? createdDateTime,
      @ClientUpdatedTimestamp() DateTime? updatedDateTime,
      @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
      @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime});
}

/// @nodoc
class _$TextShoppingListItemCopyWithImpl<$Res>
    implements $TextShoppingListItemCopyWith<$Res> {
  _$TextShoppingListItemCopyWithImpl(this._self, this._then);

  final TextShoppingListItem _self;
  final $Res Function(TextShoppingListItem) _then;

  /// Create a copy of ShoppingListItem
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
    Object? categoryID = freezed,
    Object? reminderDateTime = freezed,
    Object? createdDateTime = freezed,
    Object? updatedDateTime = freezed,
    Object? serverCreatedDateTime = freezed,
    Object? serverUpdatedDateTime = freezed,
  }) {
    return _then(TextShoppingListItem(
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
              as ShoppingListItemStatus,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      color: freezed == color
          ? _self.color
          : color // ignore: cast_nullable_to_non_nullable
              as String?,
      categoryID: freezed == categoryID
          ? _self.categoryID
          : categoryID // ignore: cast_nullable_to_non_nullable
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
class LinkShoppingListItem implements ShoppingListItem {
  const LinkShoppingListItem(
      {required this.id,
      required this.shoppingListID,
      required this.url,
      required this.order,
      this.metadataTitle,
      this.metadataDescription,
      this.metadataImageURL,
      this.status = ShoppingListItemStatus.unchecked,
      this.description,
      this.color,
      this.categoryID,
      @NullableTimestampConverter() this.reminderDateTime,
      @ClientCreatedTimestamp() this.createdDateTime,
      @ClientUpdatedTimestamp() this.updatedDateTime,
      @ServerCreatedTimestamp() this.serverCreatedDateTime,
      @ServerUpdatedTimestamp() this.serverUpdatedDateTime,
      final String? $type})
      : $type = $type ?? 'link';
  factory LinkShoppingListItem.fromJson(Map<String, dynamic> json) =>
      _$LinkShoppingListItemFromJson(json);

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
  final ShoppingListItemStatus status;
  @override
  final String? description;
  @override
  final String? color;
  @override
  final String? categoryID;
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

  /// Create a copy of ShoppingListItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $LinkShoppingListItemCopyWith<LinkShoppingListItem> get copyWith =>
      _$LinkShoppingListItemCopyWithImpl<LinkShoppingListItem>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$LinkShoppingListItemToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is LinkShoppingListItem &&
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
            (identical(other.categoryID, categoryID) ||
                other.categoryID == categoryID) &&
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
      categoryID,
      reminderDateTime,
      createdDateTime,
      updatedDateTime,
      serverCreatedDateTime,
      serverUpdatedDateTime);

  @override
  String toString() {
    return 'ShoppingListItem.link(id: $id, shoppingListID: $shoppingListID, url: $url, order: $order, metadataTitle: $metadataTitle, metadataDescription: $metadataDescription, metadataImageURL: $metadataImageURL, status: $status, description: $description, color: $color, categoryID: $categoryID, reminderDateTime: $reminderDateTime, createdDateTime: $createdDateTime, updatedDateTime: $updatedDateTime, serverCreatedDateTime: $serverCreatedDateTime, serverUpdatedDateTime: $serverUpdatedDateTime)';
  }
}

/// @nodoc
abstract mixin class $LinkShoppingListItemCopyWith<$Res>
    implements $ShoppingListItemCopyWith<$Res> {
  factory $LinkShoppingListItemCopyWith(LinkShoppingListItem value,
          $Res Function(LinkShoppingListItem) _then) =
      _$LinkShoppingListItemCopyWithImpl;
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
      ShoppingListItemStatus status,
      String? description,
      String? color,
      String? categoryID,
      @NullableTimestampConverter() DateTime? reminderDateTime,
      @ClientCreatedTimestamp() DateTime? createdDateTime,
      @ClientUpdatedTimestamp() DateTime? updatedDateTime,
      @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
      @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime});
}

/// @nodoc
class _$LinkShoppingListItemCopyWithImpl<$Res>
    implements $LinkShoppingListItemCopyWith<$Res> {
  _$LinkShoppingListItemCopyWithImpl(this._self, this._then);

  final LinkShoppingListItem _self;
  final $Res Function(LinkShoppingListItem) _then;

  /// Create a copy of ShoppingListItem
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
    Object? categoryID = freezed,
    Object? reminderDateTime = freezed,
    Object? createdDateTime = freezed,
    Object? updatedDateTime = freezed,
    Object? serverCreatedDateTime = freezed,
    Object? serverUpdatedDateTime = freezed,
  }) {
    return _then(LinkShoppingListItem(
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
              as ShoppingListItemStatus,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      color: freezed == color
          ? _self.color
          : color // ignore: cast_nullable_to_non_nullable
              as String?,
      categoryID: freezed == categoryID
          ? _self.categoryID
          : categoryID // ignore: cast_nullable_to_non_nullable
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
