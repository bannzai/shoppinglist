// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(userDatabase)
final userDatabaseProvider = UserDatabaseProvider._();

final class UserDatabaseProvider
    extends $FunctionalProvider<UserDatabase, UserDatabase, UserDatabase>
    with $Provider<UserDatabase> {
  UserDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userDatabaseProvider',
        isAutoDispose: false,
        dependencies: <ProviderOrFamily>[firebaseUserChangesProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          UserDatabaseProvider.$allTransitiveDependencies0,
        ],
      );

  static final $allTransitiveDependencies0 = firebaseUserChangesProvider;

  @override
  String debugGetCreateSourceHash() => _$userDatabaseHash();

  @$internal
  @override
  $ProviderElement<UserDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UserDatabase create(Ref ref) {
    return userDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserDatabase>(value),
    );
  }
}

String _$userDatabaseHash() => r'b0a5f6e848882e5ba28ac94f07b4414f5b9abeaf';

@ProviderFor(groupDatabase)
final groupDatabaseProvider = GroupDatabaseFamily._();

final class GroupDatabaseProvider
    extends $FunctionalProvider<GroupDatabase, GroupDatabase, GroupDatabase>
    with $Provider<GroupDatabase> {
  GroupDatabaseProvider._({
    required GroupDatabaseFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'groupDatabaseProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$groupDatabaseHash();

  @override
  String toString() {
    return r'groupDatabaseProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<GroupDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GroupDatabase create(Ref ref) {
    final argument = this.argument as String;
    return groupDatabase(ref, groupID: argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GroupDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GroupDatabase>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GroupDatabaseProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groupDatabaseHash() => r'2197743e24dc6e9d93ea3b2eb6a01b7db0bc425a';

final class GroupDatabaseFamily extends $Family
    with $FunctionalFamilyOverride<GroupDatabase, String> {
  GroupDatabaseFamily._()
    : super(
        retry: null,
        name: r'groupDatabaseProvider',
        dependencies: <ProviderOrFamily>[],
        $allTransitiveDependencies: <ProviderOrFamily>[],
        isAutoDispose: false,
      );

  GroupDatabaseProvider call({required String groupID}) =>
      GroupDatabaseProvider._(argument: groupID, from: this);

  @override
  String toString() => r'groupDatabaseProvider';
}
