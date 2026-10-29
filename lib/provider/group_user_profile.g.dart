// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_user_profile.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(groupUserProfiles)
final groupUserProfilesProvider = GroupUserProfilesFamily._();

final class GroupUserProfilesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GroupUserProfile>>,
          List<GroupUserProfile>,
          Stream<List<GroupUserProfile>>
        >
    with
        $FutureModifier<List<GroupUserProfile>>,
        $StreamProvider<List<GroupUserProfile>> {
  GroupUserProfilesProvider._({
    required GroupUserProfilesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'groupUserProfilesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  static final $allTransitiveDependencies0 = groupDatabaseProvider;

  @override
  String debugGetCreateSourceHash() => _$groupUserProfilesHash();

  @override
  String toString() {
    return r'groupUserProfilesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<GroupUserProfile>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<GroupUserProfile>> create(Ref ref) {
    final argument = this.argument as String;
    return groupUserProfiles(ref, groupID: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupUserProfilesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groupUserProfilesHash() => r'6634d3a9fe8eb366149721ac613ef119fb8b0a21';

final class GroupUserProfilesFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<GroupUserProfile>>, String> {
  GroupUserProfilesFamily._()
    : super(
        retry: null,
        name: r'groupUserProfilesProvider',
        dependencies: <ProviderOrFamily>[groupDatabaseProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          GroupUserProfilesProvider.$allTransitiveDependencies0,
        ],
        isAutoDispose: true,
      );

  GroupUserProfilesProvider call({required String groupID}) =>
      GroupUserProfilesProvider._(argument: groupID, from: this);

  @override
  String toString() => r'groupUserProfilesProvider';
}

@ProviderFor(groupUserProfileUpdate)
final groupUserProfileUpdateProvider = GroupUserProfileUpdateFamily._();

final class GroupUserProfileUpdateProvider
    extends
        $FunctionalProvider<
          GroupUserProfileUpdate,
          GroupUserProfileUpdate,
          GroupUserProfileUpdate
        >
    with $Provider<GroupUserProfileUpdate> {
  GroupUserProfileUpdateProvider._({
    required GroupUserProfileUpdateFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'groupUserProfileUpdateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  static final $allTransitiveDependencies0 = groupDatabaseProvider;

  @override
  String debugGetCreateSourceHash() => _$groupUserProfileUpdateHash();

  @override
  String toString() {
    return r'groupUserProfileUpdateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<GroupUserProfileUpdate> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GroupUserProfileUpdate create(Ref ref) {
    final argument = this.argument as String;
    return groupUserProfileUpdate(ref, groupID: argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GroupUserProfileUpdate value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GroupUserProfileUpdate>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GroupUserProfileUpdateProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groupUserProfileUpdateHash() =>
    r'4a25962065264675c61852baf08df2e575f0b37b';

final class GroupUserProfileUpdateFamily extends $Family
    with $FunctionalFamilyOverride<GroupUserProfileUpdate, String> {
  GroupUserProfileUpdateFamily._()
    : super(
        retry: null,
        name: r'groupUserProfileUpdateProvider',
        dependencies: <ProviderOrFamily>[groupDatabaseProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          GroupUserProfileUpdateProvider.$allTransitiveDependencies0,
        ],
        isAutoDispose: true,
      );

  GroupUserProfileUpdateProvider call({required String groupID}) =>
      GroupUserProfileUpdateProvider._(argument: groupID, from: this);

  @override
  String toString() => r'groupUserProfileUpdateProvider';
}
