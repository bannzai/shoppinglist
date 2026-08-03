// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'source_image.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sourceImagesHash() => r'66e5a69b1ee3f74ec9d94ca5b923efb8e1d6d07f';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// 買い物リストに紐づく「写真から追加」の元画像一覧を、保存日時の新しい順で購読する。
/// ドキュメントの作成・削除は generateShoppingListItemsFromImage Function
/// （Admin SDK）が行うため、クライアント側は読み取りのみで書き込み用の class は持たない。
///
/// Copied from [sourceImages].
@ProviderFor(sourceImages)
const sourceImagesProvider = SourceImagesFamily();

/// 買い物リストに紐づく「写真から追加」の元画像一覧を、保存日時の新しい順で購読する。
/// ドキュメントの作成・削除は generateShoppingListItemsFromImage Function
/// （Admin SDK）が行うため、クライアント側は読み取りのみで書き込み用の class は持たない。
///
/// Copied from [sourceImages].
class SourceImagesFamily
    extends Family<AsyncValue<List<GroupShoppingListSourceImage>>> {
  /// 買い物リストに紐づく「写真から追加」の元画像一覧を、保存日時の新しい順で購読する。
  /// ドキュメントの作成・削除は generateShoppingListItemsFromImage Function
  /// （Admin SDK）が行うため、クライアント側は読み取りのみで書き込み用の class は持たない。
  ///
  /// Copied from [sourceImages].
  const SourceImagesFamily();

  /// 買い物リストに紐づく「写真から追加」の元画像一覧を、保存日時の新しい順で購読する。
  /// ドキュメントの作成・削除は generateShoppingListItemsFromImage Function
  /// （Admin SDK）が行うため、クライアント側は読み取りのみで書き込み用の class は持たない。
  ///
  /// Copied from [sourceImages].
  SourceImagesProvider call({
    required String groupID,
    required String shoppingListID,
  }) {
    return SourceImagesProvider(
      groupID: groupID,
      shoppingListID: shoppingListID,
    );
  }

  @override
  SourceImagesProvider getProviderOverride(
    covariant SourceImagesProvider provider,
  ) {
    return call(
      groupID: provider.groupID,
      shoppingListID: provider.shoppingListID,
    );
  }

  static final Iterable<ProviderOrFamily> _dependencies = <ProviderOrFamily>[
    groupDatabaseProvider,
  ];

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static final Iterable<ProviderOrFamily> _allTransitiveDependencies =
      <ProviderOrFamily>{
        groupDatabaseProvider,
        ...?groupDatabaseProvider.allTransitiveDependencies,
      };

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'sourceImagesProvider';
}

/// 買い物リストに紐づく「写真から追加」の元画像一覧を、保存日時の新しい順で購読する。
/// ドキュメントの作成・削除は generateShoppingListItemsFromImage Function
/// （Admin SDK）が行うため、クライアント側は読み取りのみで書き込み用の class は持たない。
///
/// Copied from [sourceImages].
class SourceImagesProvider
    extends AutoDisposeStreamProvider<List<GroupShoppingListSourceImage>> {
  /// 買い物リストに紐づく「写真から追加」の元画像一覧を、保存日時の新しい順で購読する。
  /// ドキュメントの作成・削除は generateShoppingListItemsFromImage Function
  /// （Admin SDK）が行うため、クライアント側は読み取りのみで書き込み用の class は持たない。
  ///
  /// Copied from [sourceImages].
  SourceImagesProvider({
    required String groupID,
    required String shoppingListID,
  }) : this._internal(
         (ref) => sourceImages(
           ref as SourceImagesRef,
           groupID: groupID,
           shoppingListID: shoppingListID,
         ),
         from: sourceImagesProvider,
         name: r'sourceImagesProvider',
         debugGetCreateSourceHash:
             const bool.fromEnvironment('dart.vm.product')
                 ? null
                 : _$sourceImagesHash,
         dependencies: SourceImagesFamily._dependencies,
         allTransitiveDependencies:
             SourceImagesFamily._allTransitiveDependencies,
         groupID: groupID,
         shoppingListID: shoppingListID,
       );

  SourceImagesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.groupID,
    required this.shoppingListID,
  }) : super.internal();

  final String groupID;
  final String shoppingListID;

  @override
  Override overrideWith(
    Stream<List<GroupShoppingListSourceImage>> Function(
      SourceImagesRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SourceImagesProvider._internal(
        (ref) => create(ref as SourceImagesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        groupID: groupID,
        shoppingListID: shoppingListID,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<GroupShoppingListSourceImage>>
  createElement() {
    return _SourceImagesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SourceImagesProvider &&
        other.groupID == groupID &&
        other.shoppingListID == shoppingListID;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, groupID.hashCode);
    hash = _SystemHash.combine(hash, shoppingListID.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SourceImagesRef
    on AutoDisposeStreamProviderRef<List<GroupShoppingListSourceImage>> {
  /// The parameter `groupID` of this provider.
  String get groupID;

  /// The parameter `shoppingListID` of this provider.
  String get shoppingListID;
}

class _SourceImagesProviderElement
    extends AutoDisposeStreamProviderElement<List<GroupShoppingListSourceImage>>
    with SourceImagesRef {
  _SourceImagesProviderElement(super.provider);

  @override
  String get groupID => (origin as SourceImagesProvider).groupID;
  @override
  String get shoppingListID => (origin as SourceImagesProvider).shoppingListID;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
