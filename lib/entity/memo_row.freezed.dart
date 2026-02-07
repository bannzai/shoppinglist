// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'memo_row.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
MemoRow _$MemoRowFromJson(Map<String, dynamic> json) {
  switch (json['type']) {
    case 'text':
      return TextMemoRow.fromJson(json);
    case 'link':
      return LinkMemoRow.fromJson(json);

    default:
      throw CheckedFromJsonException(
          json, 'type', 'MemoRow', 'Invalid union type "${json['type']}"!');
  }
}

/// @nodoc
mixin _$MemoRow {
  String get id;
  String get memoID; // NOTE: 0,1,3と飛ぶことがある。削除時にorderを詰めることはしてない
// NOTE: 0,1,2,2 と同列になることも許容する。確認はされてないが、orderが同じであっても良い
  int get order;
  MemoRowStatus get status;
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

  /// Create a copy of MemoRow
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MemoRowCopyWith<MemoRow> get copyWith =>
      _$MemoRowCopyWithImpl<MemoRow>(this as MemoRow, _$identity);

  /// Serializes this MemoRow to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MemoRow &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.memoID, memoID) || other.memoID == memoID) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.status, status) || other.status == status) &&
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
      memoID,
      order,
      status,
      reminderDateTime,
      createdDateTime,
      updatedDateTime,
      serverCreatedDateTime,
      serverUpdatedDateTime);

  @override
  String toString() {
    return 'MemoRow(id: $id, memoID: $memoID, order: $order, status: $status, reminderDateTime: $reminderDateTime, createdDateTime: $createdDateTime, updatedDateTime: $updatedDateTime, serverCreatedDateTime: $serverCreatedDateTime, serverUpdatedDateTime: $serverUpdatedDateTime)';
  }
}

/// @nodoc
abstract mixin class $MemoRowCopyWith<$Res> {
  factory $MemoRowCopyWith(MemoRow value, $Res Function(MemoRow) _then) =
      _$MemoRowCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String memoID,
      int order,
      MemoRowStatus status,
      @NullableTimestampConverter() DateTime? reminderDateTime,
      @ClientCreatedTimestamp() DateTime? createdDateTime,
      @ClientUpdatedTimestamp() DateTime? updatedDateTime,
      @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
      @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime});
}

/// @nodoc
class _$MemoRowCopyWithImpl<$Res> implements $MemoRowCopyWith<$Res> {
  _$MemoRowCopyWithImpl(this._self, this._then);

  final MemoRow _self;
  final $Res Function(MemoRow) _then;

  /// Create a copy of MemoRow
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? memoID = null,
    Object? order = null,
    Object? status = null,
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
      memoID: null == memoID
          ? _self.memoID
          : memoID // ignore: cast_nullable_to_non_nullable
              as String,
      order: null == order
          ? _self.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as MemoRowStatus,
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

/// Adds pattern-matching-related methods to [MemoRow].
extension MemoRowPatterns on MemoRow {
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
    TResult Function(TextMemoRow value)? text,
    TResult Function(LinkMemoRow value)? link,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case TextMemoRow() when text != null:
        return text(_that);
      case LinkMemoRow() when link != null:
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
    required TResult Function(TextMemoRow value) text,
    required TResult Function(LinkMemoRow value) link,
  }) {
    final _that = this;
    switch (_that) {
      case TextMemoRow():
        return text(_that);
      case LinkMemoRow():
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
    TResult? Function(TextMemoRow value)? text,
    TResult? Function(LinkMemoRow value)? link,
  }) {
    final _that = this;
    switch (_that) {
      case TextMemoRow() when text != null:
        return text(_that);
      case LinkMemoRow() when link != null:
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
            String memoID,
            String message,
            int order,
            MemoRowStatus status,
            @NullableTimestampConverter() DateTime? reminderDateTime,
            @ClientCreatedTimestamp() DateTime? createdDateTime,
            @ClientUpdatedTimestamp() DateTime? updatedDateTime,
            @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
            @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime)?
        text,
    TResult Function(
            String id,
            String memoID,
            String url,
            int order,
            String? metadataTitle,
            String? metadataDescription,
            String? metadataImageURL,
            MemoRowStatus status,
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
      case TextMemoRow() when text != null:
        return text(
            _that.id,
            _that.memoID,
            _that.message,
            _that.order,
            _that.status,
            _that.reminderDateTime,
            _that.createdDateTime,
            _that.updatedDateTime,
            _that.serverCreatedDateTime,
            _that.serverUpdatedDateTime);
      case LinkMemoRow() when link != null:
        return link(
            _that.id,
            _that.memoID,
            _that.url,
            _that.order,
            _that.metadataTitle,
            _that.metadataDescription,
            _that.metadataImageURL,
            _that.status,
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
            String memoID,
            String message,
            int order,
            MemoRowStatus status,
            @NullableTimestampConverter() DateTime? reminderDateTime,
            @ClientCreatedTimestamp() DateTime? createdDateTime,
            @ClientUpdatedTimestamp() DateTime? updatedDateTime,
            @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
            @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime)
        text,
    required TResult Function(
            String id,
            String memoID,
            String url,
            int order,
            String? metadataTitle,
            String? metadataDescription,
            String? metadataImageURL,
            MemoRowStatus status,
            @NullableTimestampConverter() DateTime? reminderDateTime,
            @ClientCreatedTimestamp() DateTime? createdDateTime,
            @ClientUpdatedTimestamp() DateTime? updatedDateTime,
            @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
            @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime)
        link,
  }) {
    final _that = this;
    switch (_that) {
      case TextMemoRow():
        return text(
            _that.id,
            _that.memoID,
            _that.message,
            _that.order,
            _that.status,
            _that.reminderDateTime,
            _that.createdDateTime,
            _that.updatedDateTime,
            _that.serverCreatedDateTime,
            _that.serverUpdatedDateTime);
      case LinkMemoRow():
        return link(
            _that.id,
            _that.memoID,
            _that.url,
            _that.order,
            _that.metadataTitle,
            _that.metadataDescription,
            _that.metadataImageURL,
            _that.status,
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
            String memoID,
            String message,
            int order,
            MemoRowStatus status,
            @NullableTimestampConverter() DateTime? reminderDateTime,
            @ClientCreatedTimestamp() DateTime? createdDateTime,
            @ClientUpdatedTimestamp() DateTime? updatedDateTime,
            @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
            @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime)?
        text,
    TResult? Function(
            String id,
            String memoID,
            String url,
            int order,
            String? metadataTitle,
            String? metadataDescription,
            String? metadataImageURL,
            MemoRowStatus status,
            @NullableTimestampConverter() DateTime? reminderDateTime,
            @ClientCreatedTimestamp() DateTime? createdDateTime,
            @ClientUpdatedTimestamp() DateTime? updatedDateTime,
            @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
            @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime)?
        link,
  }) {
    final _that = this;
    switch (_that) {
      case TextMemoRow() when text != null:
        return text(
            _that.id,
            _that.memoID,
            _that.message,
            _that.order,
            _that.status,
            _that.reminderDateTime,
            _that.createdDateTime,
            _that.updatedDateTime,
            _that.serverCreatedDateTime,
            _that.serverUpdatedDateTime);
      case LinkMemoRow() when link != null:
        return link(
            _that.id,
            _that.memoID,
            _that.url,
            _that.order,
            _that.metadataTitle,
            _that.metadataDescription,
            _that.metadataImageURL,
            _that.status,
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
class TextMemoRow implements MemoRow {
  const TextMemoRow(
      {required this.id,
      required this.memoID,
      required this.message,
      required this.order,
      this.status = MemoRowStatus.unchecked,
      @NullableTimestampConverter() this.reminderDateTime,
      @ClientCreatedTimestamp() this.createdDateTime,
      @ClientUpdatedTimestamp() this.updatedDateTime,
      @ServerCreatedTimestamp() this.serverCreatedDateTime,
      @ServerUpdatedTimestamp() this.serverUpdatedDateTime,
      final String? $type})
      : $type = $type ?? 'text';
  factory TextMemoRow.fromJson(Map<String, dynamic> json) =>
      _$TextMemoRowFromJson(json);

  @override
  final String id;
  @override
  final String memoID;
  final String message;
// NOTE: 0,1,3と飛ぶことがある。削除時にorderを詰めることはしてない
// NOTE: 0,1,2,2 と同列になることも許容する。確認はされてないが、orderが同じであっても良い
  @override
  final int order;
  @override
  @JsonKey()
  final MemoRowStatus status;
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

  /// Create a copy of MemoRow
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TextMemoRowCopyWith<TextMemoRow> get copyWith =>
      _$TextMemoRowCopyWithImpl<TextMemoRow>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$TextMemoRowToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TextMemoRow &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.memoID, memoID) || other.memoID == memoID) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.status, status) || other.status == status) &&
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
      memoID,
      message,
      order,
      status,
      reminderDateTime,
      createdDateTime,
      updatedDateTime,
      serverCreatedDateTime,
      serverUpdatedDateTime);

  @override
  String toString() {
    return 'MemoRow.text(id: $id, memoID: $memoID, message: $message, order: $order, status: $status, reminderDateTime: $reminderDateTime, createdDateTime: $createdDateTime, updatedDateTime: $updatedDateTime, serverCreatedDateTime: $serverCreatedDateTime, serverUpdatedDateTime: $serverUpdatedDateTime)';
  }
}

/// @nodoc
abstract mixin class $TextMemoRowCopyWith<$Res>
    implements $MemoRowCopyWith<$Res> {
  factory $TextMemoRowCopyWith(
          TextMemoRow value, $Res Function(TextMemoRow) _then) =
      _$TextMemoRowCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String memoID,
      String message,
      int order,
      MemoRowStatus status,
      @NullableTimestampConverter() DateTime? reminderDateTime,
      @ClientCreatedTimestamp() DateTime? createdDateTime,
      @ClientUpdatedTimestamp() DateTime? updatedDateTime,
      @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
      @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime});
}

/// @nodoc
class _$TextMemoRowCopyWithImpl<$Res> implements $TextMemoRowCopyWith<$Res> {
  _$TextMemoRowCopyWithImpl(this._self, this._then);

  final TextMemoRow _self;
  final $Res Function(TextMemoRow) _then;

  /// Create a copy of MemoRow
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? memoID = null,
    Object? message = null,
    Object? order = null,
    Object? status = null,
    Object? reminderDateTime = freezed,
    Object? createdDateTime = freezed,
    Object? updatedDateTime = freezed,
    Object? serverCreatedDateTime = freezed,
    Object? serverUpdatedDateTime = freezed,
  }) {
    return _then(TextMemoRow(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      memoID: null == memoID
          ? _self.memoID
          : memoID // ignore: cast_nullable_to_non_nullable
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
              as MemoRowStatus,
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
class LinkMemoRow implements MemoRow {
  const LinkMemoRow(
      {required this.id,
      required this.memoID,
      required this.url,
      required this.order,
      this.metadataTitle,
      this.metadataDescription,
      this.metadataImageURL,
      this.status = MemoRowStatus.unchecked,
      @NullableTimestampConverter() this.reminderDateTime,
      @ClientCreatedTimestamp() this.createdDateTime,
      @ClientUpdatedTimestamp() this.updatedDateTime,
      @ServerCreatedTimestamp() this.serverCreatedDateTime,
      @ServerUpdatedTimestamp() this.serverUpdatedDateTime,
      final String? $type})
      : $type = $type ?? 'link';
  factory LinkMemoRow.fromJson(Map<String, dynamic> json) =>
      _$LinkMemoRowFromJson(json);

  @override
  final String id;
  @override
  final String memoID;
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
  final MemoRowStatus status;
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

  /// Create a copy of MemoRow
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $LinkMemoRowCopyWith<LinkMemoRow> get copyWith =>
      _$LinkMemoRowCopyWithImpl<LinkMemoRow>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$LinkMemoRowToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is LinkMemoRow &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.memoID, memoID) || other.memoID == memoID) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.metadataTitle, metadataTitle) ||
                other.metadataTitle == metadataTitle) &&
            (identical(other.metadataDescription, metadataDescription) ||
                other.metadataDescription == metadataDescription) &&
            (identical(other.metadataImageURL, metadataImageURL) ||
                other.metadataImageURL == metadataImageURL) &&
            (identical(other.status, status) || other.status == status) &&
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
      memoID,
      url,
      order,
      metadataTitle,
      metadataDescription,
      metadataImageURL,
      status,
      reminderDateTime,
      createdDateTime,
      updatedDateTime,
      serverCreatedDateTime,
      serverUpdatedDateTime);

  @override
  String toString() {
    return 'MemoRow.link(id: $id, memoID: $memoID, url: $url, order: $order, metadataTitle: $metadataTitle, metadataDescription: $metadataDescription, metadataImageURL: $metadataImageURL, status: $status, reminderDateTime: $reminderDateTime, createdDateTime: $createdDateTime, updatedDateTime: $updatedDateTime, serverCreatedDateTime: $serverCreatedDateTime, serverUpdatedDateTime: $serverUpdatedDateTime)';
  }
}

/// @nodoc
abstract mixin class $LinkMemoRowCopyWith<$Res>
    implements $MemoRowCopyWith<$Res> {
  factory $LinkMemoRowCopyWith(
          LinkMemoRow value, $Res Function(LinkMemoRow) _then) =
      _$LinkMemoRowCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String memoID,
      String url,
      int order,
      String? metadataTitle,
      String? metadataDescription,
      String? metadataImageURL,
      MemoRowStatus status,
      @NullableTimestampConverter() DateTime? reminderDateTime,
      @ClientCreatedTimestamp() DateTime? createdDateTime,
      @ClientUpdatedTimestamp() DateTime? updatedDateTime,
      @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
      @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime});
}

/// @nodoc
class _$LinkMemoRowCopyWithImpl<$Res> implements $LinkMemoRowCopyWith<$Res> {
  _$LinkMemoRowCopyWithImpl(this._self, this._then);

  final LinkMemoRow _self;
  final $Res Function(LinkMemoRow) _then;

  /// Create a copy of MemoRow
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? memoID = null,
    Object? url = null,
    Object? order = null,
    Object? metadataTitle = freezed,
    Object? metadataDescription = freezed,
    Object? metadataImageURL = freezed,
    Object? status = null,
    Object? reminderDateTime = freezed,
    Object? createdDateTime = freezed,
    Object? updatedDateTime = freezed,
    Object? serverCreatedDateTime = freezed,
    Object? serverUpdatedDateTime = freezed,
  }) {
    return _then(LinkMemoRow(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      memoID: null == memoID
          ? _self.memoID
          : memoID // ignore: cast_nullable_to_non_nullable
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
              as MemoRowStatus,
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
