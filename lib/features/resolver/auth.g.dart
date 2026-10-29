// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(firebaseUserChanges)
final firebaseUserChangesProvider = FirebaseUserChangesProvider._();

final class FirebaseUserChangesProvider
    extends $FunctionalProvider<AsyncValue<User?>, User?, Stream<User?>>
    with $FutureModifier<User?>, $StreamProvider<User?> {
  FirebaseUserChangesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'firebaseUserChangesProvider',
        isAutoDispose: false,
        dependencies: <ProviderOrFamily>[],
        $allTransitiveDependencies: <ProviderOrFamily>[],
      );

  @override
  String debugGetCreateSourceHash() => _$firebaseUserChangesHash();

  @$internal
  @override
  $StreamProviderElement<User?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<User?> create(Ref ref) {
    return firebaseUserChanges(ref);
  }
}

String _$firebaseUserChangesHash() =>
    r'5bd1f286b92f4208602a0fabe059e643a85b22c3';
