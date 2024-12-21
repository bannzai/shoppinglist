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
  switch (json['runtimeType']) {
    case 'text':
      return TextMemoRow.fromJson(json);
    case 'link':
      return LinkMemoRow.fromJson(json);

    default:
      throw CheckedFromJsonException(json, 'runtimeType', 'MemoRow', 'Invalid union type "${json['runtimeType']}"!');
  }
}

/// @nodoc
mixin _$MemoRow {
  String? get id => throw _privateConstructorUsedError;
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
            String message,
            @NullableTimestampConverter() DateTime? reminderDateTime,
            @ClientCreatedTimestamp() DateTime? createdDateTime,
            @ClientUpdatedTimestamp() DateTime? updatedDateTime,
            @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
            @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime)
        text,
    required TResult Function(
            String? id,
            String url,
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
            String message,
            @NullableTimestampConverter() DateTime? reminderDateTime,
            @ClientCreatedTimestamp() DateTime? createdDateTime,
            @ClientUpdatedTimestamp() DateTime? updatedDateTime,
            @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
            @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime)?
        text,
    TResult? Function(
            String? id,
            String url,
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
            String message,
            @NullableTimestampConverter() DateTime? reminderDateTime,
            @ClientCreatedTimestamp() DateTime? createdDateTime,
            @ClientUpdatedTimestamp() DateTime? updatedDateTime,
            @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
            @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime)?
        text,
    TResult Function(
            String? id,
            String url,
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
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MemoRowCopyWith<MemoRow> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MemoRowCopyWith<$Res> {
  factory $MemoRowCopyWith(MemoRow value, $Res Function(MemoRow) then) = _$MemoRowCopyWithImpl<$Res, MemoRow>;
  @useResult
  $Res call(
      {String? id,
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

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
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
      String message,
      @NullableTimestampConverter() DateTime? reminderDateTime,
      @ClientCreatedTimestamp() DateTime? createdDateTime,
      @ClientUpdatedTimestamp() DateTime? updatedDateTime,
      @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
      @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime});
}

/// @nodoc
class __$$TextMemoRowImplCopyWithImpl<$Res> extends _$MemoRowCopyWithImpl<$Res, _$TextMemoRowImpl> implements _$$TextMemoRowImplCopyWith<$Res> {
  __$$TextMemoRowImplCopyWithImpl(_$TextMemoRowImpl _value, $Res Function(_$TextMemoRowImpl) _then) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? message = null,
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
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
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
      required this.message,
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
  final String message;
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

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'MemoRow.text(id: $id, message: $message, reminderDateTime: $reminderDateTime, createdDateTime: $createdDateTime, updatedDateTime: $updatedDateTime, serverCreatedDateTime: $serverCreatedDateTime, serverUpdatedDateTime: $serverUpdatedDateTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TextMemoRowImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.reminderDateTime, reminderDateTime) || other.reminderDateTime == reminderDateTime) &&
            (identical(other.createdDateTime, createdDateTime) || other.createdDateTime == createdDateTime) &&
            (identical(other.updatedDateTime, updatedDateTime) || other.updatedDateTime == updatedDateTime) &&
            (identical(other.serverCreatedDateTime, serverCreatedDateTime) || other.serverCreatedDateTime == serverCreatedDateTime) &&
            (identical(other.serverUpdatedDateTime, serverUpdatedDateTime) || other.serverUpdatedDateTime == serverUpdatedDateTime));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, message, reminderDateTime, createdDateTime, updatedDateTime, serverCreatedDateTime, serverUpdatedDateTime);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TextMemoRowImplCopyWith<_$TextMemoRowImpl> get copyWith => __$$TextMemoRowImplCopyWithImpl<_$TextMemoRowImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String? id,
            String message,
            @NullableTimestampConverter() DateTime? reminderDateTime,
            @ClientCreatedTimestamp() DateTime? createdDateTime,
            @ClientUpdatedTimestamp() DateTime? updatedDateTime,
            @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
            @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime)
        text,
    required TResult Function(
            String? id,
            String url,
            @NullableTimestampConverter() DateTime? reminderDateTime,
            @ClientCreatedTimestamp() DateTime? createdDateTime,
            @ClientUpdatedTimestamp() DateTime? updatedDateTime,
            @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
            @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime)
        link,
  }) {
    return text(id, message, reminderDateTime, createdDateTime, updatedDateTime, serverCreatedDateTime, serverUpdatedDateTime);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String? id,
            String message,
            @NullableTimestampConverter() DateTime? reminderDateTime,
            @ClientCreatedTimestamp() DateTime? createdDateTime,
            @ClientUpdatedTimestamp() DateTime? updatedDateTime,
            @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
            @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime)?
        text,
    TResult? Function(
            String? id,
            String url,
            @NullableTimestampConverter() DateTime? reminderDateTime,
            @ClientCreatedTimestamp() DateTime? createdDateTime,
            @ClientUpdatedTimestamp() DateTime? updatedDateTime,
            @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
            @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime)?
        link,
  }) {
    return text?.call(id, message, reminderDateTime, createdDateTime, updatedDateTime, serverCreatedDateTime, serverUpdatedDateTime);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String? id,
            String message,
            @NullableTimestampConverter() DateTime? reminderDateTime,
            @ClientCreatedTimestamp() DateTime? createdDateTime,
            @ClientUpdatedTimestamp() DateTime? updatedDateTime,
            @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
            @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime)?
        text,
    TResult Function(
            String? id,
            String url,
            @NullableTimestampConverter() DateTime? reminderDateTime,
            @ClientCreatedTimestamp() DateTime? createdDateTime,
            @ClientUpdatedTimestamp() DateTime? updatedDateTime,
            @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
            @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime)?
        link,
    required TResult orElse(),
  }) {
    if (text != null) {
      return text(id, message, reminderDateTime, createdDateTime, updatedDateTime, serverCreatedDateTime, serverUpdatedDateTime);
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
      required final String message,
      @NullableTimestampConverter() final DateTime? reminderDateTime,
      @ClientCreatedTimestamp() final DateTime? createdDateTime,
      @ClientUpdatedTimestamp() final DateTime? updatedDateTime,
      @ServerCreatedTimestamp() final DateTime? serverCreatedDateTime,
      @ServerUpdatedTimestamp() final DateTime? serverUpdatedDateTime}) = _$TextMemoRowImpl;

  factory TextMemoRow.fromJson(Map<String, dynamic> json) = _$TextMemoRowImpl.fromJson;

  @override
  String? get id;
  String get message;
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
  @override
  @JsonKey(ignore: true)
  _$$TextMemoRowImplCopyWith<_$TextMemoRowImpl> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$LinkMemoRowImplCopyWith<$Res> implements $MemoRowCopyWith<$Res> {
  factory _$$LinkMemoRowImplCopyWith(_$LinkMemoRowImpl value, $Res Function(_$LinkMemoRowImpl) then) = __$$LinkMemoRowImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      String url,
      @NullableTimestampConverter() DateTime? reminderDateTime,
      @ClientCreatedTimestamp() DateTime? createdDateTime,
      @ClientUpdatedTimestamp() DateTime? updatedDateTime,
      @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
      @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime});
}

/// @nodoc
class __$$LinkMemoRowImplCopyWithImpl<$Res> extends _$MemoRowCopyWithImpl<$Res, _$LinkMemoRowImpl> implements _$$LinkMemoRowImplCopyWith<$Res> {
  __$$LinkMemoRowImplCopyWithImpl(_$LinkMemoRowImpl _value, $Res Function(_$LinkMemoRowImpl) _then) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? url = null,
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
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
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
      required this.url,
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
  final String url;
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

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'MemoRow.link(id: $id, url: $url, reminderDateTime: $reminderDateTime, createdDateTime: $createdDateTime, updatedDateTime: $updatedDateTime, serverCreatedDateTime: $serverCreatedDateTime, serverUpdatedDateTime: $serverUpdatedDateTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LinkMemoRowImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.reminderDateTime, reminderDateTime) || other.reminderDateTime == reminderDateTime) &&
            (identical(other.createdDateTime, createdDateTime) || other.createdDateTime == createdDateTime) &&
            (identical(other.updatedDateTime, updatedDateTime) || other.updatedDateTime == updatedDateTime) &&
            (identical(other.serverCreatedDateTime, serverCreatedDateTime) || other.serverCreatedDateTime == serverCreatedDateTime) &&
            (identical(other.serverUpdatedDateTime, serverUpdatedDateTime) || other.serverUpdatedDateTime == serverUpdatedDateTime));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, url, reminderDateTime, createdDateTime, updatedDateTime, serverCreatedDateTime, serverUpdatedDateTime);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LinkMemoRowImplCopyWith<_$LinkMemoRowImpl> get copyWith => __$$LinkMemoRowImplCopyWithImpl<_$LinkMemoRowImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String? id,
            String message,
            @NullableTimestampConverter() DateTime? reminderDateTime,
            @ClientCreatedTimestamp() DateTime? createdDateTime,
            @ClientUpdatedTimestamp() DateTime? updatedDateTime,
            @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
            @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime)
        text,
    required TResult Function(
            String? id,
            String url,
            @NullableTimestampConverter() DateTime? reminderDateTime,
            @ClientCreatedTimestamp() DateTime? createdDateTime,
            @ClientUpdatedTimestamp() DateTime? updatedDateTime,
            @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
            @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime)
        link,
  }) {
    return link(id, url, reminderDateTime, createdDateTime, updatedDateTime, serverCreatedDateTime, serverUpdatedDateTime);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String? id,
            String message,
            @NullableTimestampConverter() DateTime? reminderDateTime,
            @ClientCreatedTimestamp() DateTime? createdDateTime,
            @ClientUpdatedTimestamp() DateTime? updatedDateTime,
            @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
            @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime)?
        text,
    TResult? Function(
            String? id,
            String url,
            @NullableTimestampConverter() DateTime? reminderDateTime,
            @ClientCreatedTimestamp() DateTime? createdDateTime,
            @ClientUpdatedTimestamp() DateTime? updatedDateTime,
            @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
            @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime)?
        link,
  }) {
    return link?.call(id, url, reminderDateTime, createdDateTime, updatedDateTime, serverCreatedDateTime, serverUpdatedDateTime);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String? id,
            String message,
            @NullableTimestampConverter() DateTime? reminderDateTime,
            @ClientCreatedTimestamp() DateTime? createdDateTime,
            @ClientUpdatedTimestamp() DateTime? updatedDateTime,
            @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
            @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime)?
        text,
    TResult Function(
            String? id,
            String url,
            @NullableTimestampConverter() DateTime? reminderDateTime,
            @ClientCreatedTimestamp() DateTime? createdDateTime,
            @ClientUpdatedTimestamp() DateTime? updatedDateTime,
            @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
            @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime)?
        link,
    required TResult orElse(),
  }) {
    if (link != null) {
      return link(id, url, reminderDateTime, createdDateTime, updatedDateTime, serverCreatedDateTime, serverUpdatedDateTime);
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
      required final String url,
      @NullableTimestampConverter() final DateTime? reminderDateTime,
      @ClientCreatedTimestamp() final DateTime? createdDateTime,
      @ClientUpdatedTimestamp() final DateTime? updatedDateTime,
      @ServerCreatedTimestamp() final DateTime? serverCreatedDateTime,
      @ServerUpdatedTimestamp() final DateTime? serverUpdatedDateTime}) = _$LinkMemoRowImpl;

  factory LinkMemoRow.fromJson(Map<String, dynamic> json) = _$LinkMemoRowImpl.fromJson;

  @override
  String? get id;
  String get url;
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
  @override
  @JsonKey(ignore: true)
  _$$LinkMemoRowImplCopyWith<_$LinkMemoRowImpl> get copyWith => throw _privateConstructorUsedError;
}
