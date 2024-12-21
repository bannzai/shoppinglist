// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'remote_config_parameter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RemoteConfigParameter _$RemoteConfigParameterFromJson(Map<String, dynamic> json) {
  return _RemoteConfigParameter.fromJson(json);
}

/// @nodoc
mixin _$RemoteConfigParameter {
  String get releasedVersion => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RemoteConfigParameterCopyWith<RemoteConfigParameter> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RemoteConfigParameterCopyWith<$Res> {
  factory $RemoteConfigParameterCopyWith(RemoteConfigParameter value, $Res Function(RemoteConfigParameter) then) =
      _$RemoteConfigParameterCopyWithImpl<$Res, RemoteConfigParameter>;
  @useResult
  $Res call({String releasedVersion});
}

/// @nodoc
class _$RemoteConfigParameterCopyWithImpl<$Res, $Val extends RemoteConfigParameter> implements $RemoteConfigParameterCopyWith<$Res> {
  _$RemoteConfigParameterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? releasedVersion = null,
  }) {
    return _then(_value.copyWith(
      releasedVersion: null == releasedVersion
          ? _value.releasedVersion
          : releasedVersion // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RemoteConfigParameterImplCopyWith<$Res> implements $RemoteConfigParameterCopyWith<$Res> {
  factory _$$RemoteConfigParameterImplCopyWith(_$RemoteConfigParameterImpl value, $Res Function(_$RemoteConfigParameterImpl) then) =
      __$$RemoteConfigParameterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String releasedVersion});
}

/// @nodoc
class __$$RemoteConfigParameterImplCopyWithImpl<$Res> extends _$RemoteConfigParameterCopyWithImpl<$Res, _$RemoteConfigParameterImpl>
    implements _$$RemoteConfigParameterImplCopyWith<$Res> {
  __$$RemoteConfigParameterImplCopyWithImpl(_$RemoteConfigParameterImpl _value, $Res Function(_$RemoteConfigParameterImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? releasedVersion = null,
  }) {
    return _then(_$RemoteConfigParameterImpl(
      releasedVersion: null == releasedVersion
          ? _value.releasedVersion
          : releasedVersion // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RemoteConfigParameterImpl extends _RemoteConfigParameter {
  _$RemoteConfigParameterImpl({this.releasedVersion = RemoteConfigParameterDefaultValues.releasedVersion}) : super._();

  factory _$RemoteConfigParameterImpl.fromJson(Map<String, dynamic> json) => _$$RemoteConfigParameterImplFromJson(json);

  @override
  @JsonKey()
  final String releasedVersion;

  @override
  String toString() {
    return 'RemoteConfigParameter(releasedVersion: $releasedVersion)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RemoteConfigParameterImpl &&
            (identical(other.releasedVersion, releasedVersion) || other.releasedVersion == releasedVersion));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, releasedVersion);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RemoteConfigParameterImplCopyWith<_$RemoteConfigParameterImpl> get copyWith =>
      __$$RemoteConfigParameterImplCopyWithImpl<_$RemoteConfigParameterImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RemoteConfigParameterImplToJson(
      this,
    );
  }
}

abstract class _RemoteConfigParameter extends RemoteConfigParameter {
  factory _RemoteConfigParameter({final String releasedVersion}) = _$RemoteConfigParameterImpl;
  _RemoteConfigParameter._() : super._();

  factory _RemoteConfigParameter.fromJson(Map<String, dynamic> json) = _$RemoteConfigParameterImpl.fromJson;

  @override
  String get releasedVersion;
  @override
  @JsonKey(ignore: true)
  _$$RemoteConfigParameterImplCopyWith<_$RemoteConfigParameterImpl> get copyWith => throw _privateConstructorUsedError;
}
