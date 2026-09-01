// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recently_added_shopping_list_item.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$recentlyAddedShoppingListItemHash() =>
    r'94bc9bb531dd9e0161fb2020523afca871ad81fc';

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

abstract class _$RecentlyAddedShoppingListItem
    extends BuildlessAutoDisposeNotifier<String?> {
  late final String shoppingListID;

  String? build(String shoppingListID);
}

/// 最後に手入力した買い物リストアイテムの ID を、一時的に保持する。
///
/// Firestore への追加完了前に次の入力が確定することがあるため、入力開始順を連番で管理する。
/// 書き込み完了順が前後しても、最後に確定した入力だけを強調表示する。
///
/// Copied from [RecentlyAddedShoppingListItem].
@ProviderFor(RecentlyAddedShoppingListItem)
const recentlyAddedShoppingListItemProvider =
    RecentlyAddedShoppingListItemFamily();

/// 最後に手入力した買い物リストアイテムの ID を、一時的に保持する。
///
/// Firestore への追加完了前に次の入力が確定することがあるため、入力開始順を連番で管理する。
/// 書き込み完了順が前後しても、最後に確定した入力だけを強調表示する。
///
/// Copied from [RecentlyAddedShoppingListItem].
class RecentlyAddedShoppingListItemFamily extends Family<String?> {
  /// 最後に手入力した買い物リストアイテムの ID を、一時的に保持する。
  ///
  /// Firestore への追加完了前に次の入力が確定することがあるため、入力開始順を連番で管理する。
  /// 書き込み完了順が前後しても、最後に確定した入力だけを強調表示する。
  ///
  /// Copied from [RecentlyAddedShoppingListItem].
  const RecentlyAddedShoppingListItemFamily();

  /// 最後に手入力した買い物リストアイテムの ID を、一時的に保持する。
  ///
  /// Firestore への追加完了前に次の入力が確定することがあるため、入力開始順を連番で管理する。
  /// 書き込み完了順が前後しても、最後に確定した入力だけを強調表示する。
  ///
  /// Copied from [RecentlyAddedShoppingListItem].
  RecentlyAddedShoppingListItemProvider call(String shoppingListID) {
    return RecentlyAddedShoppingListItemProvider(shoppingListID);
  }

  @override
  RecentlyAddedShoppingListItemProvider getProviderOverride(
    covariant RecentlyAddedShoppingListItemProvider provider,
  ) {
    return call(provider.shoppingListID);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'recentlyAddedShoppingListItemProvider';
}

/// 最後に手入力した買い物リストアイテムの ID を、一時的に保持する。
///
/// Firestore への追加完了前に次の入力が確定することがあるため、入力開始順を連番で管理する。
/// 書き込み完了順が前後しても、最後に確定した入力だけを強調表示する。
///
/// Copied from [RecentlyAddedShoppingListItem].
class RecentlyAddedShoppingListItemProvider
    extends
        AutoDisposeNotifierProviderImpl<
          RecentlyAddedShoppingListItem,
          String?
        > {
  /// 最後に手入力した買い物リストアイテムの ID を、一時的に保持する。
  ///
  /// Firestore への追加完了前に次の入力が確定することがあるため、入力開始順を連番で管理する。
  /// 書き込み完了順が前後しても、最後に確定した入力だけを強調表示する。
  ///
  /// Copied from [RecentlyAddedShoppingListItem].
  RecentlyAddedShoppingListItemProvider(String shoppingListID)
    : this._internal(
        () => RecentlyAddedShoppingListItem()..shoppingListID = shoppingListID,
        from: recentlyAddedShoppingListItemProvider,
        name: r'recentlyAddedShoppingListItemProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$recentlyAddedShoppingListItemHash,
        dependencies: RecentlyAddedShoppingListItemFamily._dependencies,
        allTransitiveDependencies:
            RecentlyAddedShoppingListItemFamily._allTransitiveDependencies,
        shoppingListID: shoppingListID,
      );

  RecentlyAddedShoppingListItemProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.shoppingListID,
  }) : super.internal();

  final String shoppingListID;

  @override
  String? runNotifierBuild(covariant RecentlyAddedShoppingListItem notifier) {
    return notifier.build(shoppingListID);
  }

  @override
  Override overrideWith(RecentlyAddedShoppingListItem Function() create) {
    return ProviderOverride(
      origin: this,
      override: RecentlyAddedShoppingListItemProvider._internal(
        () => create()..shoppingListID = shoppingListID,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        shoppingListID: shoppingListID,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<RecentlyAddedShoppingListItem, String?>
  createElement() {
    return _RecentlyAddedShoppingListItemProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RecentlyAddedShoppingListItemProvider &&
        other.shoppingListID == shoppingListID;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, shoppingListID.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RecentlyAddedShoppingListItemRef
    on AutoDisposeNotifierProviderRef<String?> {
  /// The parameter `shoppingListID` of this provider.
  String get shoppingListID;
}

class _RecentlyAddedShoppingListItemProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          RecentlyAddedShoppingListItem,
          String?
        >
    with RecentlyAddedShoppingListItemRef {
  _RecentlyAddedShoppingListItemProviderElement(super.provider);

  @override
  String get shoppingListID =>
      (origin as RecentlyAddedShoppingListItemProvider).shoppingListID;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
