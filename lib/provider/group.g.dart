// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(group)
final groupProvider = GroupFamily._();

final class GroupProvider
    extends $FunctionalProvider<AsyncValue<Group>, Group, Stream<Group>>
    with $FutureModifier<Group>, $StreamProvider<Group> {
  GroupProvider._({
    required GroupFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'groupProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  static final $allTransitiveDependencies0 = groupDatabaseProvider;

  @override
  String debugGetCreateSourceHash() => _$groupHash();

  @override
  String toString() {
    return r'groupProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Group> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Group> create(Ref ref) {
    final argument = this.argument as String;
    return group(ref, groupID: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groupHash() => r'00db553ddde7bb5b274e9eb9932fa26c9f18296a';

final class GroupFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Group>, String> {
  GroupFamily._()
    : super(
        retry: null,
        name: r'groupProvider',
        dependencies: <ProviderOrFamily>[groupDatabaseProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          GroupProvider.$allTransitiveDependencies0,
        ],
        isAutoDispose: true,
      );

  GroupProvider call({required String groupID}) =>
      GroupProvider._(argument: groupID, from: this);

  @override
  String toString() => r'groupProvider';
}
