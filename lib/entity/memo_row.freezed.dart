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
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String? id, String message) text,
    required TResult Function(String? id, String url) link,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String? id, String message)? text,
    TResult? Function(String? id, String url)? link,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? id, String message)? text,
    TResult Function(String? id, String url)? link,
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
  $Res call({String? id});
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
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TextMemoRowImplCopyWith<$Res> implements $MemoRowCopyWith<$Res> {
  factory _$$TextMemoRowImplCopyWith(_$TextMemoRowImpl value, $Res Function(_$TextMemoRowImpl) then) = __$$TextMemoRowImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? id, String message});
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
    Object? message = null,
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
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$TextMemoRowImpl implements TextMemoRow {
  const _$TextMemoRowImpl({this.id, required this.message, final String? $type}) : $type = $type ?? 'text';

  factory _$TextMemoRowImpl.fromJson(Map<String, dynamic> json) => _$$TextMemoRowImplFromJson(json);

  @override
  final String? id;
  @override
  final String message;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'MemoRow.text(id: $id, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TextMemoRowImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, message);

  /// Create a copy of MemoRow
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TextMemoRowImplCopyWith<_$TextMemoRowImpl> get copyWith => __$$TextMemoRowImplCopyWithImpl<_$TextMemoRowImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String? id, String message) text,
    required TResult Function(String? id, String url) link,
  }) {
    return text(id, message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String? id, String message)? text,
    TResult? Function(String? id, String url)? link,
  }) {
    return text?.call(id, message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? id, String message)? text,
    TResult Function(String? id, String url)? link,
    required TResult orElse(),
  }) {
    if (text != null) {
      return text(id, message);
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
  const factory TextMemoRow({final String? id, required final String message}) = _$TextMemoRowImpl;

  factory TextMemoRow.fromJson(Map<String, dynamic> json) = _$TextMemoRowImpl.fromJson;

  @override
  String? get id;
  String get message;

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
  $Res call({String? id, String url});
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
    Object? url = null,
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
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$LinkMemoRowImpl implements LinkMemoRow {
  const _$LinkMemoRowImpl({this.id, required this.url, final String? $type}) : $type = $type ?? 'link';

  factory _$LinkMemoRowImpl.fromJson(Map<String, dynamic> json) => _$$LinkMemoRowImplFromJson(json);

  @override
  final String? id;
  @override
  final String url;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'MemoRow.link(id: $id, url: $url)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LinkMemoRowImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.url, url) || other.url == url));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, url);

  /// Create a copy of MemoRow
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LinkMemoRowImplCopyWith<_$LinkMemoRowImpl> get copyWith => __$$LinkMemoRowImplCopyWithImpl<_$LinkMemoRowImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String? id, String message) text,
    required TResult Function(String? id, String url) link,
  }) {
    return link(id, url);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String? id, String message)? text,
    TResult? Function(String? id, String url)? link,
  }) {
    return link?.call(id, url);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? id, String message)? text,
    TResult Function(String? id, String url)? link,
    required TResult orElse(),
  }) {
    if (link != null) {
      return link(id, url);
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
  const factory LinkMemoRow({final String? id, required final String url}) = _$LinkMemoRowImpl;

  factory LinkMemoRow.fromJson(Map<String, dynamic> json) = _$LinkMemoRowImpl.fromJson;

  @override
  String? get id;
  String get url;

  /// Create a copy of MemoRow
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LinkMemoRowImplCopyWith<_$LinkMemoRowImpl> get copyWith => throw _privateConstructorUsedError;
}
