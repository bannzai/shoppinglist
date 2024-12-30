// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'memo_row.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MemoRow _$MemoRowFromJson(Map<String, dynamic> json) {
  switch (json['type']) {
    case 'text':
      return TextMemoRow.fromJson(json);
    case 'link':
      return LinkMemoRow.fromJson(json);

    default:
      throw CheckedFromJsonException(json, 'type', 'MemoRow', 'Invalid union type "${json['type']}"!');
  }
}

/// @nodoc
mixin _$MemoRow {
  String? get id => throw _privateConstructorUsedError;
  String get memoID => throw _privateConstructorUsedError;
  int get order => throw _privateConstructorUsedError;
  MemoRowStatus get status => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get reminderDateTime => throw _privateConstructorUsedError;
  @ClientCreatedTimestamp()
  DateTime? get createdDateTime => throw _privateConstructorUsedError;
  @ClientUpdatedTimestamp()
  DateTime? get updatedDateTime => throw _privateConstructorUsedError;
  @ServerCreatedTimestamp()
  DateTime? get serverCreatedDateTime => throw _privateConstructorUsedError;
  @ServerUpdatedTimestamp()
  DateTime? get serverUpdatedDateTime => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String? id,
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
            String? id,
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
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String? id,
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
            String? id,
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
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String? id,
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
            String? id,
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
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TextMemoRow value) text,
    required TResult Function(LinkMemoRow value) link,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TextMemoRow value)? text,
    TResult? Function(LinkMemoRow value)? link,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TextMemoRow value)? text,
    TResult Function(LinkMemoRow value)? link,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  /// Serializes this MemoRow to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MemoRow
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MemoRowCopyWith<MemoRow> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MemoRowCopyWith<$Res> {
  factory $MemoRowCopyWith(MemoRow value, $Res Function(MemoRow) then) = _$MemoRowCopyWithImpl<$Res, MemoRow>;
  @useResult
  $Res call(
      {String? id,
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
class _$MemoRowCopyWithImpl<$Res, $Val extends MemoRow> implements $MemoRowCopyWith<$Res> {
  _$MemoRowCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MemoRow
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? memoID = null,
    Object? order = null,
    Object? status = null,
    Object? reminderDateTime = freezed,
    Object? createdDateTime = freezed,
    Object? updatedDateTime = freezed,
    Object? serverCreatedDateTime = freezed,
    Object? serverUpdatedDateTime = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      memoID: null == memoID
          ? _value.memoID
          : memoID // ignore: cast_nullable_to_non_nullable
              as String,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as MemoRowStatus,
      reminderDateTime: freezed == reminderDateTime
          ? _value.reminderDateTime
          : reminderDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdDateTime: freezed == createdDateTime
          ? _value.createdDateTime
          : createdDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedDateTime: freezed == updatedDateTime
          ? _value.updatedDateTime
          : updatedDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      serverCreatedDateTime: freezed == serverCreatedDateTime
          ? _value.serverCreatedDateTime
          : serverCreatedDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      serverUpdatedDateTime: freezed == serverUpdatedDateTime
          ? _value.serverUpdatedDateTime
          : serverUpdatedDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TextMemoRowImplCopyWith<$Res> implements $MemoRowCopyWith<$Res> {
  factory _$$TextMemoRowImplCopyWith(_$TextMemoRowImpl value, $Res Function(_$TextMemoRowImpl) then) = __$$TextMemoRowImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
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
class __$$TextMemoRowImplCopyWithImpl<$Res> extends _$MemoRowCopyWithImpl<$Res, _$TextMemoRowImpl> implements _$$TextMemoRowImplCopyWith<$Res> {
  __$$TextMemoRowImplCopyWithImpl(_$TextMemoRowImpl _value, $Res Function(_$TextMemoRowImpl) _then) : super(_value, _then);

  /// Create a copy of MemoRow
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
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
    return _then(_$TextMemoRowImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      memoID: null == memoID
          ? _value.memoID
          : memoID // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as MemoRowStatus,
      reminderDateTime: freezed == reminderDateTime
          ? _value.reminderDateTime
          : reminderDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdDateTime: freezed == createdDateTime
          ? _value.createdDateTime
          : createdDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedDateTime: freezed == updatedDateTime
          ? _value.updatedDateTime
          : updatedDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      serverCreatedDateTime: freezed == serverCreatedDateTime
          ? _value.serverCreatedDateTime
          : serverCreatedDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      serverUpdatedDateTime: freezed == serverUpdatedDateTime
          ? _value.serverUpdatedDateTime
          : serverUpdatedDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$TextMemoRowImpl implements TextMemoRow {
  const _$TextMemoRowImpl(
      {this.id,
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

  factory _$TextMemoRowImpl.fromJson(Map<String, dynamic> json) => _$$TextMemoRowImplFromJson(json);

  @override
  final String? id;
  @override
  final String memoID;
  @override
  final String message;
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

  @override
  String toString() {
    return 'MemoRow.text(id: $id, memoID: $memoID, message: $message, order: $order, status: $status, reminderDateTime: $reminderDateTime, createdDateTime: $createdDateTime, updatedDateTime: $updatedDateTime, serverCreatedDateTime: $serverCreatedDateTime, serverUpdatedDateTime: $serverUpdatedDateTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TextMemoRowImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.memoID, memoID) || other.memoID == memoID) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.reminderDateTime, reminderDateTime) || other.reminderDateTime == reminderDateTime) &&
            (identical(other.createdDateTime, createdDateTime) || other.createdDateTime == createdDateTime) &&
            (identical(other.updatedDateTime, updatedDateTime) || other.updatedDateTime == updatedDateTime) &&
            (identical(other.serverCreatedDateTime, serverCreatedDateTime) || other.serverCreatedDateTime == serverCreatedDateTime) &&
            (identical(other.serverUpdatedDateTime, serverUpdatedDateTime) || other.serverUpdatedDateTime == serverUpdatedDateTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, memoID, message, order, status, reminderDateTime, createdDateTime, updatedDateTime,
      serverCreatedDateTime, serverUpdatedDateTime);

  /// Create a copy of MemoRow
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TextMemoRowImplCopyWith<_$TextMemoRowImpl> get copyWith => __$$TextMemoRowImplCopyWithImpl<_$TextMemoRowImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String? id,
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
            String? id,
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
    return text(id, memoID, message, order, status, reminderDateTime, createdDateTime, updatedDateTime, serverCreatedDateTime, serverUpdatedDateTime);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String? id,
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
            String? id,
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
    return text?.call(
        id, memoID, message, order, status, reminderDateTime, createdDateTime, updatedDateTime, serverCreatedDateTime, serverUpdatedDateTime);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String? id,
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
            String? id,
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
    if (text != null) {
      return text(
          id, memoID, message, order, status, reminderDateTime, createdDateTime, updatedDateTime, serverCreatedDateTime, serverUpdatedDateTime);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TextMemoRow value) text,
    required TResult Function(LinkMemoRow value) link,
  }) {
    return text(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TextMemoRow value)? text,
    TResult? Function(LinkMemoRow value)? link,
  }) {
    return text?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TextMemoRow value)? text,
    TResult Function(LinkMemoRow value)? link,
    required TResult orElse(),
  }) {
    if (text != null) {
      return text(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$TextMemoRowImplToJson(
      this,
    );
  }
}

abstract class TextMemoRow implements MemoRow {
  const factory TextMemoRow(
      {final String? id,
      required final String memoID,
      required final String message,
      required final int order,
      final MemoRowStatus status,
      @NullableTimestampConverter() final DateTime? reminderDateTime,
      @ClientCreatedTimestamp() final DateTime? createdDateTime,
      @ClientUpdatedTimestamp() final DateTime? updatedDateTime,
      @ServerCreatedTimestamp() final DateTime? serverCreatedDateTime,
      @ServerUpdatedTimestamp() final DateTime? serverUpdatedDateTime}) = _$TextMemoRowImpl;

  factory TextMemoRow.fromJson(Map<String, dynamic> json) = _$TextMemoRowImpl.fromJson;

  @override
  String? get id;
  @override
  String get memoID;
  String get message;
  @override
  int get order;
  @override
  MemoRowStatus get status;
  @override
  @NullableTimestampConverter()
  DateTime? get reminderDateTime;
  @override
  @ClientCreatedTimestamp()
  DateTime? get createdDateTime;
  @override
  @ClientUpdatedTimestamp()
  DateTime? get updatedDateTime;
  @override
  @ServerCreatedTimestamp()
  DateTime? get serverCreatedDateTime;
  @override
  @ServerUpdatedTimestamp()
  DateTime? get serverUpdatedDateTime;

  /// Create a copy of MemoRow
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TextMemoRowImplCopyWith<_$TextMemoRowImpl> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$LinkMemoRowImplCopyWith<$Res> implements $MemoRowCopyWith<$Res> {
  factory _$$LinkMemoRowImplCopyWith(_$LinkMemoRowImpl value, $Res Function(_$LinkMemoRowImpl) then) = __$$LinkMemoRowImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
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
class __$$LinkMemoRowImplCopyWithImpl<$Res> extends _$MemoRowCopyWithImpl<$Res, _$LinkMemoRowImpl> implements _$$LinkMemoRowImplCopyWith<$Res> {
  __$$LinkMemoRowImplCopyWithImpl(_$LinkMemoRowImpl _value, $Res Function(_$LinkMemoRowImpl) _then) : super(_value, _then);

  /// Create a copy of MemoRow
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
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
    return _then(_$LinkMemoRowImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      memoID: null == memoID
          ? _value.memoID
          : memoID // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      metadataTitle: freezed == metadataTitle
          ? _value.metadataTitle
          : metadataTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      metadataDescription: freezed == metadataDescription
          ? _value.metadataDescription
          : metadataDescription // ignore: cast_nullable_to_non_nullable
              as String?,
      metadataImageURL: freezed == metadataImageURL
          ? _value.metadataImageURL
          : metadataImageURL // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as MemoRowStatus,
      reminderDateTime: freezed == reminderDateTime
          ? _value.reminderDateTime
          : reminderDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdDateTime: freezed == createdDateTime
          ? _value.createdDateTime
          : createdDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedDateTime: freezed == updatedDateTime
          ? _value.updatedDateTime
          : updatedDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      serverCreatedDateTime: freezed == serverCreatedDateTime
          ? _value.serverCreatedDateTime
          : serverCreatedDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      serverUpdatedDateTime: freezed == serverUpdatedDateTime
          ? _value.serverUpdatedDateTime
          : serverUpdatedDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$LinkMemoRowImpl implements LinkMemoRow {
  const _$LinkMemoRowImpl(
      {this.id,
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

  factory _$LinkMemoRowImpl.fromJson(Map<String, dynamic> json) => _$$LinkMemoRowImplFromJson(json);

  @override
  final String? id;
  @override
  final String memoID;
  @override
  final String url;
  @override
  final int order;
  @override
  final String? metadataTitle;
  @override
  final String? metadataDescription;
  @override
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

  @override
  String toString() {
    return 'MemoRow.link(id: $id, memoID: $memoID, url: $url, order: $order, metadataTitle: $metadataTitle, metadataDescription: $metadataDescription, metadataImageURL: $metadataImageURL, status: $status, reminderDateTime: $reminderDateTime, createdDateTime: $createdDateTime, updatedDateTime: $updatedDateTime, serverCreatedDateTime: $serverCreatedDateTime, serverUpdatedDateTime: $serverUpdatedDateTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LinkMemoRowImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.memoID, memoID) || other.memoID == memoID) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.metadataTitle, metadataTitle) || other.metadataTitle == metadataTitle) &&
            (identical(other.metadataDescription, metadataDescription) || other.metadataDescription == metadataDescription) &&
            (identical(other.metadataImageURL, metadataImageURL) || other.metadataImageURL == metadataImageURL) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.reminderDateTime, reminderDateTime) || other.reminderDateTime == reminderDateTime) &&
            (identical(other.createdDateTime, createdDateTime) || other.createdDateTime == createdDateTime) &&
            (identical(other.updatedDateTime, updatedDateTime) || other.updatedDateTime == updatedDateTime) &&
            (identical(other.serverCreatedDateTime, serverCreatedDateTime) || other.serverCreatedDateTime == serverCreatedDateTime) &&
            (identical(other.serverUpdatedDateTime, serverUpdatedDateTime) || other.serverUpdatedDateTime == serverUpdatedDateTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, memoID, url, order, metadataTitle, metadataDescription, metadataImageURL, status, reminderDateTime,
      createdDateTime, updatedDateTime, serverCreatedDateTime, serverUpdatedDateTime);

  /// Create a copy of MemoRow
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LinkMemoRowImplCopyWith<_$LinkMemoRowImpl> get copyWith => __$$LinkMemoRowImplCopyWithImpl<_$LinkMemoRowImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String? id,
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
            String? id,
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
    return link(id, memoID, url, order, metadataTitle, metadataDescription, metadataImageURL, status, reminderDateTime, createdDateTime,
        updatedDateTime, serverCreatedDateTime, serverUpdatedDateTime);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String? id,
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
            String? id,
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
    return link?.call(id, memoID, url, order, metadataTitle, metadataDescription, metadataImageURL, status, reminderDateTime, createdDateTime,
        updatedDateTime, serverCreatedDateTime, serverUpdatedDateTime);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String? id,
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
            String? id,
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
    if (link != null) {
      return link(id, memoID, url, order, metadataTitle, metadataDescription, metadataImageURL, status, reminderDateTime, createdDateTime,
          updatedDateTime, serverCreatedDateTime, serverUpdatedDateTime);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TextMemoRow value) text,
    required TResult Function(LinkMemoRow value) link,
  }) {
    return link(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TextMemoRow value)? text,
    TResult? Function(LinkMemoRow value)? link,
  }) {
    return link?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TextMemoRow value)? text,
    TResult Function(LinkMemoRow value)? link,
    required TResult orElse(),
  }) {
    if (link != null) {
      return link(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$LinkMemoRowImplToJson(
      this,
    );
  }
}

abstract class LinkMemoRow implements MemoRow {
  const factory LinkMemoRow(
      {final String? id,
      required final String memoID,
      required final String url,
      required final int order,
      final String? metadataTitle,
      final String? metadataDescription,
      final String? metadataImageURL,
      final MemoRowStatus status,
      @NullableTimestampConverter() final DateTime? reminderDateTime,
      @ClientCreatedTimestamp() final DateTime? createdDateTime,
      @ClientUpdatedTimestamp() final DateTime? updatedDateTime,
      @ServerCreatedTimestamp() final DateTime? serverCreatedDateTime,
      @ServerUpdatedTimestamp() final DateTime? serverUpdatedDateTime}) = _$LinkMemoRowImpl;

  factory LinkMemoRow.fromJson(Map<String, dynamic> json) = _$LinkMemoRowImpl.fromJson;

  @override
  String? get id;
  @override
  String get memoID;
  String get url;
  @override
  int get order;
  String? get metadataTitle;
  String? get metadataDescription;
  String? get metadataImageURL;
  @override
  MemoRowStatus get status;
  @override
  @NullableTimestampConverter()
  DateTime? get reminderDateTime;
  @override
  @ClientCreatedTimestamp()
  DateTime? get createdDateTime;
  @override
  @ClientUpdatedTimestamp()
  DateTime? get updatedDateTime;
  @override
  @ServerCreatedTimestamp()
  DateTime? get serverCreatedDateTime;
  @override
  @ServerUpdatedTimestamp()
  DateTime? get serverUpdatedDateTime;

  /// Create a copy of MemoRow
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LinkMemoRowImplCopyWith<_$LinkMemoRowImpl> get copyWith => throw _privateConstructorUsedError;
}
