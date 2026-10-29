// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_groups.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(userGroups)
final userGroupsProvider = UserGroupsProvider._();

final class UserGroupsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Group>>,
          List<Group>,
          Stream<List<Group>>
        >
    with $FutureModifier<List<Group>>, $StreamProvider<List<Group>> {
  UserGroupsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userGroupsProvider',
        isAutoDispose: true,
        dependencies: <ProviderOrFamily>[currentUserIDProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          UserGroupsProvider.$allTransitiveDependencies0,
          UserGroupsProvider.$allTransitiveDependencies1,
        ],
      );

  static final $allTransitiveDependencies0 = currentUserIDProvider;
  static final $allTransitiveDependencies1 =
      CurrentUserIDProvider.$allTransitiveDependencies0;

  @override
  String debugGetCreateSourceHash() => _$userGroupsHash();

  @$internal
  @override
  $StreamProviderElement<List<Group>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Group>> create(Ref ref) {
    return userGroups(ref);
  }
}

String _$userGroupsHash() => r'5edeab93d709e10c0aebb43ec9a31f3780e5c4ec';
