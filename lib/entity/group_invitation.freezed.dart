// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group_invitation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GroupInvitation {
  String get id;
  String get groupID;
  String get inviterUserID;
  String get invitationCode;
  GroupInvitationStatus get status;
  @NullableTimestampConverter()
  DateTime? get expiresDateTime;
  @ClientCreatedTimestamp()
  DateTime? get createdDateTime;
  @ClientUpdatedTimestamp()
  DateTime? get updatedDateTime;
  @ServerCreatedTimestamp()
  DateTime? get serverCreatedDateTime;
  @ServerUpdatedTimestamp()
  DateTime? get serverUpdatedDateTime;

  /// Create a copy of GroupInvitation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $GroupInvitationCopyWith<GroupInvitation> get copyWith =>
      _$GroupInvitationCopyWithImpl<GroupInvitation>(
          this as GroupInvitation, _$identity);

  /// Serializes this GroupInvitation to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is GroupInvitation &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.groupID, groupID) || other.groupID == groupID) &&
            (identical(other.inviterUserID, inviterUserID) ||
                other.inviterUserID == inviterUserID) &&
            (identical(other.invitationCode, invitationCode) ||
                other.invitationCode == invitationCode) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.expiresDateTime, expiresDateTime) ||
                other.expiresDateTime == expiresDateTime) &&
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
      inviterUserID,
      invitationCode,
      status,
      expiresDateTime,
      createdDateTime,
      updatedDateTime,
      serverCreatedDateTime,
      serverUpdatedDateTime);

  @override
  String toString() {
    return 'GroupInvitation(id: $id, groupID: $groupID, inviterUserID: $inviterUserID, invitationCode: $invitationCode, status: $status, expiresDateTime: $expiresDateTime, createdDateTime: $createdDateTime, updatedDateTime: $updatedDateTime, serverCreatedDateTime: $serverCreatedDateTime, serverUpdatedDateTime: $serverUpdatedDateTime)';
  }
}

/// @nodoc
abstract mixin class $GroupInvitationCopyWith<$Res> {
  factory $GroupInvitationCopyWith(
          GroupInvitation value, $Res Function(GroupInvitation) _then) =
      _$GroupInvitationCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String groupID,
      String inviterUserID,
      String invitationCode,
      GroupInvitationStatus status,
      @NullableTimestampConverter() DateTime? expiresDateTime,
      @ClientCreatedTimestamp() DateTime? createdDateTime,
      @ClientUpdatedTimestamp() DateTime? updatedDateTime,
      @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
      @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime});
}

/// @nodoc
class _$GroupInvitationCopyWithImpl<$Res>
    implements $GroupInvitationCopyWith<$Res> {
  _$GroupInvitationCopyWithImpl(this._self, this._then);

  final GroupInvitation _self;
  final $Res Function(GroupInvitation) _then;

  /// Create a copy of GroupInvitation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? groupID = null,
    Object? inviterUserID = null,
    Object? invitationCode = null,
    Object? status = null,
    Object? expiresDateTime = freezed,
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
      inviterUserID: null == inviterUserID
          ? _self.inviterUserID
          : inviterUserID // ignore: cast_nullable_to_non_nullable
              as String,
      invitationCode: null == invitationCode
          ? _self.invitationCode
          : invitationCode // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as GroupInvitationStatus,
      expiresDateTime: freezed == expiresDateTime
          ? _self.expiresDateTime
          : expiresDateTime // ignore: cast_nullable_to_non_nullable
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

/// Adds pattern-matching-related methods to [GroupInvitation].
extension GroupInvitationPatterns on GroupInvitation {
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
    TResult Function(_GroupInvitation value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GroupInvitation() when $default != null:
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
    TResult Function(_GroupInvitation value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GroupInvitation():
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
    TResult? Function(_GroupInvitation value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GroupInvitation() when $default != null:
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
            String inviterUserID,
            String invitationCode,
            GroupInvitationStatus status,
            @NullableTimestampConverter() DateTime? expiresDateTime,
            @ClientCreatedTimestamp() DateTime? createdDateTime,
            @ClientUpdatedTimestamp() DateTime? updatedDateTime,
            @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
            @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GroupInvitation() when $default != null:
        return $default(
            _that.id,
            _that.groupID,
            _that.inviterUserID,
            _that.invitationCode,
            _that.status,
            _that.expiresDateTime,
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
            String inviterUserID,
            String invitationCode,
            GroupInvitationStatus status,
            @NullableTimestampConverter() DateTime? expiresDateTime,
            @ClientCreatedTimestamp() DateTime? createdDateTime,
            @ClientUpdatedTimestamp() DateTime? updatedDateTime,
            @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
            @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GroupInvitation():
        return $default(
            _that.id,
            _that.groupID,
            _that.inviterUserID,
            _that.invitationCode,
            _that.status,
            _that.expiresDateTime,
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
            String inviterUserID,
            String invitationCode,
            GroupInvitationStatus status,
            @NullableTimestampConverter() DateTime? expiresDateTime,
            @ClientCreatedTimestamp() DateTime? createdDateTime,
            @ClientUpdatedTimestamp() DateTime? updatedDateTime,
            @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
            @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GroupInvitation() when $default != null:
        return $default(
            _that.id,
            _that.groupID,
            _that.inviterUserID,
            _that.invitationCode,
            _that.status,
            _that.expiresDateTime,
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
class _GroupInvitation extends GroupInvitation {
  const _GroupInvitation(
      {required this.id,
      required this.groupID,
      required this.inviterUserID,
      required this.invitationCode,
      required this.status,
      @NullableTimestampConverter() this.expiresDateTime,
      @ClientCreatedTimestamp() this.createdDateTime,
      @ClientUpdatedTimestamp() this.updatedDateTime,
      @ServerCreatedTimestamp() this.serverCreatedDateTime,
      @ServerUpdatedTimestamp() this.serverUpdatedDateTime})
      : super._();
  factory _GroupInvitation.fromJson(Map<String, dynamic> json) =>
      _$GroupInvitationFromJson(json);

  @override
  final String id;
  @override
  final String groupID;
  @override
  final String inviterUserID;
  @override
  final String invitationCode;
  @override
  final GroupInvitationStatus status;
  @override
  @NullableTimestampConverter()
  final DateTime? expiresDateTime;
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

  /// Create a copy of GroupInvitation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$GroupInvitationCopyWith<_GroupInvitation> get copyWith =>
      __$GroupInvitationCopyWithImpl<_GroupInvitation>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$GroupInvitationToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _GroupInvitation &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.groupID, groupID) || other.groupID == groupID) &&
            (identical(other.inviterUserID, inviterUserID) ||
                other.inviterUserID == inviterUserID) &&
            (identical(other.invitationCode, invitationCode) ||
                other.invitationCode == invitationCode) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.expiresDateTime, expiresDateTime) ||
                other.expiresDateTime == expiresDateTime) &&
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
      inviterUserID,
      invitationCode,
      status,
      expiresDateTime,
      createdDateTime,
      updatedDateTime,
      serverCreatedDateTime,
      serverUpdatedDateTime);

  @override
  String toString() {
    return 'GroupInvitation(id: $id, groupID: $groupID, inviterUserID: $inviterUserID, invitationCode: $invitationCode, status: $status, expiresDateTime: $expiresDateTime, createdDateTime: $createdDateTime, updatedDateTime: $updatedDateTime, serverCreatedDateTime: $serverCreatedDateTime, serverUpdatedDateTime: $serverUpdatedDateTime)';
  }
}

/// @nodoc
abstract mixin class _$GroupInvitationCopyWith<$Res>
    implements $GroupInvitationCopyWith<$Res> {
  factory _$GroupInvitationCopyWith(
          _GroupInvitation value, $Res Function(_GroupInvitation) _then) =
      __$GroupInvitationCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String groupID,
      String inviterUserID,
      String invitationCode,
      GroupInvitationStatus status,
      @NullableTimestampConverter() DateTime? expiresDateTime,
      @ClientCreatedTimestamp() DateTime? createdDateTime,
      @ClientUpdatedTimestamp() DateTime? updatedDateTime,
      @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
      @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime});
}

/// @nodoc
class __$GroupInvitationCopyWithImpl<$Res>
    implements _$GroupInvitationCopyWith<$Res> {
  __$GroupInvitationCopyWithImpl(this._self, this._then);

  final _GroupInvitation _self;
  final $Res Function(_GroupInvitation) _then;

  /// Create a copy of GroupInvitation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? groupID = null,
    Object? inviterUserID = null,
    Object? invitationCode = null,
    Object? status = null,
    Object? expiresDateTime = freezed,
    Object? createdDateTime = freezed,
    Object? updatedDateTime = freezed,
    Object? serverCreatedDateTime = freezed,
    Object? serverUpdatedDateTime = freezed,
  }) {
    return _then(_GroupInvitation(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      groupID: null == groupID
          ? _self.groupID
          : groupID // ignore: cast_nullable_to_non_nullable
              as String,
      inviterUserID: null == inviterUserID
          ? _self.inviterUserID
          : inviterUserID // ignore: cast_nullable_to_non_nullable
              as String,
      invitationCode: null == invitationCode
          ? _self.invitationCode
          : invitationCode // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as GroupInvitationStatus,
      expiresDateTime: freezed == expiresDateTime
          ? _self.expiresDateTime
          : expiresDateTime // ignore: cast_nullable_to_non_nullable
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
