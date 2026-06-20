// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$receiptsHash() => r'1b6eb44246552c7632a77c679912a3c1bb4848ba';

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

/// 買い物リストに紐づくレシート一覧を、登録日時の新しい順で購読する。
///
/// Copied from [receipts].
@ProviderFor(receipts)
const receiptsProvider = ReceiptsFamily();

/// 買い物リストに紐づくレシート一覧を、登録日時の新しい順で購読する。
///
/// Copied from [receipts].
class ReceiptsFamily
    extends Family<AsyncValue<List<GroupShoppingListReceipt>>> {
  /// 買い物リストに紐づくレシート一覧を、登録日時の新しい順で購読する。
  ///
  /// Copied from [receipts].
  const ReceiptsFamily();

  /// 買い物リストに紐づくレシート一覧を、登録日時の新しい順で購読する。
  ///
  /// Copied from [receipts].
  ReceiptsProvider call({
    required String groupID,
    required String shoppingListID,
  }) {
    return ReceiptsProvider(groupID: groupID, shoppingListID: shoppingListID);
  }

  @override
  ReceiptsProvider getProviderOverride(covariant ReceiptsProvider provider) {
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
  String? get name => r'receiptsProvider';
}

/// 買い物リストに紐づくレシート一覧を、登録日時の新しい順で購読する。
///
/// Copied from [receipts].
class ReceiptsProvider
    extends AutoDisposeStreamProvider<List<GroupShoppingListReceipt>> {
  /// 買い物リストに紐づくレシート一覧を、登録日時の新しい順で購読する。
  ///
  /// Copied from [receipts].
  ReceiptsProvider({required String groupID, required String shoppingListID})
    : this._internal(
        (ref) => receipts(
          ref as ReceiptsRef,
          groupID: groupID,
          shoppingListID: shoppingListID,
        ),
        from: receiptsProvider,
        name: r'receiptsProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$receiptsHash,
        dependencies: ReceiptsFamily._dependencies,
        allTransitiveDependencies: ReceiptsFamily._allTransitiveDependencies,
        groupID: groupID,
        shoppingListID: shoppingListID,
      );

  ReceiptsProvider._internal(
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
    Stream<List<GroupShoppingListReceipt>> Function(ReceiptsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ReceiptsProvider._internal(
        (ref) => create(ref as ReceiptsRef),
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
  AutoDisposeStreamProviderElement<List<GroupShoppingListReceipt>>
  createElement() {
    return _ReceiptsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ReceiptsProvider &&
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
mixin ReceiptsRef
    on AutoDisposeStreamProviderRef<List<GroupShoppingListReceipt>> {
  /// The parameter `groupID` of this provider.
  String get groupID;

  /// The parameter `shoppingListID` of this provider.
  String get shoppingListID;
}

class _ReceiptsProviderElement
    extends AutoDisposeStreamProviderElement<List<GroupShoppingListReceipt>>
    with ReceiptsRef {
  _ReceiptsProviderElement(super.provider);

  @override
  String get groupID => (origin as ReceiptsProvider).groupID;
  @override
  String get shoppingListID => (origin as ReceiptsProvider).shoppingListID;
}

String _$addReceiptHash() => r'e2fe03abbde67a94a479f7d6e4e61e4a006803f8';

/// See also [addReceipt].
@ProviderFor(addReceipt)
const addReceiptProvider = AddReceiptFamily();

/// See also [addReceipt].
class AddReceiptFamily extends Family<AddReceipt> {
  /// See also [addReceipt].
  const AddReceiptFamily();

  /// See also [addReceipt].
  AddReceiptProvider call({required String groupID}) {
    return AddReceiptProvider(groupID: groupID);
  }

  @override
  AddReceiptProvider getProviderOverride(
    covariant AddReceiptProvider provider,
  ) {
    return call(groupID: provider.groupID);
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
  String? get name => r'addReceiptProvider';
}

/// See also [addReceipt].
class AddReceiptProvider extends AutoDisposeProvider<AddReceipt> {
  /// See also [addReceipt].
  AddReceiptProvider({required String groupID})
    : this._internal(
        (ref) => addReceipt(ref as AddReceiptRef, groupID: groupID),
        from: addReceiptProvider,
        name: r'addReceiptProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$addReceiptHash,
        dependencies: AddReceiptFamily._dependencies,
        allTransitiveDependencies: AddReceiptFamily._allTransitiveDependencies,
        groupID: groupID,
      );

  AddReceiptProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.groupID,
  }) : super.internal();

  final String groupID;

  @override
  Override overrideWith(AddReceipt Function(AddReceiptRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: AddReceiptProvider._internal(
        (ref) => create(ref as AddReceiptRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        groupID: groupID,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<AddReceipt> createElement() {
    return _AddReceiptProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AddReceiptProvider && other.groupID == groupID;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, groupID.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AddReceiptRef on AutoDisposeProviderRef<AddReceipt> {
  /// The parameter `groupID` of this provider.
  String get groupID;
}

class _AddReceiptProviderElement extends AutoDisposeProviderElement<AddReceipt>
    with AddReceiptRef {
  _AddReceiptProviderElement(super.provider);

  @override
  String get groupID => (origin as AddReceiptProvider).groupID;
}

String _$updateReceiptHash() => r'5ff1ababcc023e3c4e641a57cabafd018caa58c5';

/// See also [updateReceipt].
@ProviderFor(updateReceipt)
const updateReceiptProvider = UpdateReceiptFamily();

/// See also [updateReceipt].
class UpdateReceiptFamily extends Family<UpdateReceipt> {
  /// See also [updateReceipt].
  const UpdateReceiptFamily();

  /// See also [updateReceipt].
  UpdateReceiptProvider call({required String groupID}) {
    return UpdateReceiptProvider(groupID: groupID);
  }

  @override
  UpdateReceiptProvider getProviderOverride(
    covariant UpdateReceiptProvider provider,
  ) {
    return call(groupID: provider.groupID);
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
  String? get name => r'updateReceiptProvider';
}

/// See also [updateReceipt].
class UpdateReceiptProvider extends AutoDisposeProvider<UpdateReceipt> {
  /// See also [updateReceipt].
  UpdateReceiptProvider({required String groupID})
    : this._internal(
        (ref) => updateReceipt(ref as UpdateReceiptRef, groupID: groupID),
        from: updateReceiptProvider,
        name: r'updateReceiptProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$updateReceiptHash,
        dependencies: UpdateReceiptFamily._dependencies,
        allTransitiveDependencies:
            UpdateReceiptFamily._allTransitiveDependencies,
        groupID: groupID,
      );

  UpdateReceiptProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.groupID,
  }) : super.internal();

  final String groupID;

  @override
  Override overrideWith(
    UpdateReceipt Function(UpdateReceiptRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UpdateReceiptProvider._internal(
        (ref) => create(ref as UpdateReceiptRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        groupID: groupID,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<UpdateReceipt> createElement() {
    return _UpdateReceiptProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UpdateReceiptProvider && other.groupID == groupID;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, groupID.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UpdateReceiptRef on AutoDisposeProviderRef<UpdateReceipt> {
  /// The parameter `groupID` of this provider.
  String get groupID;
}

class _UpdateReceiptProviderElement
    extends AutoDisposeProviderElement<UpdateReceipt>
    with UpdateReceiptRef {
  _UpdateReceiptProviderElement(super.provider);

  @override
  String get groupID => (origin as UpdateReceiptProvider).groupID;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
