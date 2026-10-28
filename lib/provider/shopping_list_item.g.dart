// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_list_item.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 買い物リストのアイテム一覧(チェック済み含む全件)を order 昇順で購読する。

@ProviderFor(textShoppingListItems)
final textShoppingListItemsProvider = TextShoppingListItemsFamily._();

/// 買い物リストのアイテム一覧(チェック済み含む全件)を order 昇順で購読する。

final class TextShoppingListItemsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GroupShoppingListItem>>,
          List<GroupShoppingListItem>,
          Stream<List<GroupShoppingListItem>>
        >
    with
        $FutureModifier<List<GroupShoppingListItem>>,
        $StreamProvider<List<GroupShoppingListItem>> {
  /// 買い物リストのアイテム一覧(チェック済み含む全件)を order 昇順で購読する。
  TextShoppingListItemsProvider._({
    required TextShoppingListItemsFamily super.from,
    required ({String groupID, String shoppingListID}) super.argument,
  }) : super(
         retry: null,
         name: r'textShoppingListItemsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  static final $allTransitiveDependencies0 = groupDatabaseProvider;

  @override
  String debugGetCreateSourceHash() => _$textShoppingListItemsHash();

  @override
  String toString() {
    return r'textShoppingListItemsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<GroupShoppingListItem>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<GroupShoppingListItem>> create(Ref ref) {
    final argument = this.argument as ({String groupID, String shoppingListID});
    return textShoppingListItems(
      ref,
      groupID: argument.groupID,
      shoppingListID: argument.shoppingListID,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TextShoppingListItemsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$textShoppingListItemsHash() =>
    r'41d5a6447fdffdbea87bfd829b907e20465a5e22';

/// 買い物リストのアイテム一覧(チェック済み含む全件)を order 昇順で購読する。

final class TextShoppingListItemsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<GroupShoppingListItem>>,
          ({String groupID, String shoppingListID})
        > {
  TextShoppingListItemsFamily._()
    : super(
        retry: null,
        name: r'textShoppingListItemsProvider',
        dependencies: <ProviderOrFamily>[groupDatabaseProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          TextShoppingListItemsProvider.$allTransitiveDependencies0,
        ],
        isAutoDispose: true,
      );

  /// 買い物リストのアイテム一覧(チェック済み含む全件)を order 昇順で購読する。

  TextShoppingListItemsProvider call({
    required String groupID,
    required String shoppingListID,
  }) => TextShoppingListItemsProvider._(
    argument: (groupID: groupID, shoppingListID: shoppingListID),
    from: this,
  );

  @override
  String toString() => r'textShoppingListItemsProvider';
}

@ProviderFor(addShoppingListItem)
final addShoppingListItemProvider = AddShoppingListItemFamily._();

final class AddShoppingListItemProvider
    extends
        $FunctionalProvider<
          AddShoppingListItem,
          AddShoppingListItem,
          AddShoppingListItem
        >
    with $Provider<AddShoppingListItem> {
  AddShoppingListItemProvider._({
    required AddShoppingListItemFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'addShoppingListItemProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  static final $allTransitiveDependencies0 = groupDatabaseProvider;

  @override
  String debugGetCreateSourceHash() => _$addShoppingListItemHash();

  @override
  String toString() {
    return r'addShoppingListItemProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<AddShoppingListItem> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AddShoppingListItem create(Ref ref) {
    final argument = this.argument as String;
    return addShoppingListItem(ref, groupID: argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AddShoppingListItem value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AddShoppingListItem>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AddShoppingListItemProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$addShoppingListItemHash() =>
    r'7d38d2babe2ea031c73cd31707eedf63d6163a2a';

final class AddShoppingListItemFamily extends $Family
    with $FunctionalFamilyOverride<AddShoppingListItem, String> {
  AddShoppingListItemFamily._()
    : super(
        retry: null,
        name: r'addShoppingListItemProvider',
        dependencies: <ProviderOrFamily>[groupDatabaseProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          AddShoppingListItemProvider.$allTransitiveDependencies0,
        ],
        isAutoDispose: true,
      );

  AddShoppingListItemProvider call({required String groupID}) =>
      AddShoppingListItemProvider._(argument: groupID, from: this);

  @override
  String toString() => r'addShoppingListItemProvider';
}

@ProviderFor(deleteShoppingListItem)
final deleteShoppingListItemProvider = DeleteShoppingListItemFamily._();

final class DeleteShoppingListItemProvider
    extends
        $FunctionalProvider<
          DeleteShoppingListItem,
          DeleteShoppingListItem,
          DeleteShoppingListItem
        >
    with $Provider<DeleteShoppingListItem> {
  DeleteShoppingListItemProvider._({
    required DeleteShoppingListItemFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'deleteShoppingListItemProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  static final $allTransitiveDependencies0 = groupDatabaseProvider;

  @override
  String debugGetCreateSourceHash() => _$deleteShoppingListItemHash();

  @override
  String toString() {
    return r'deleteShoppingListItemProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<DeleteShoppingListItem> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DeleteShoppingListItem create(Ref ref) {
    final argument = this.argument as String;
    return deleteShoppingListItem(ref, groupID: argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeleteShoppingListItem value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeleteShoppingListItem>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DeleteShoppingListItemProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$deleteShoppingListItemHash() =>
    r'890587e2bea3f3f8a6af5917889d5a740a84fdbe';

final class DeleteShoppingListItemFamily extends $Family
    with $FunctionalFamilyOverride<DeleteShoppingListItem, String> {
  DeleteShoppingListItemFamily._()
    : super(
        retry: null,
        name: r'deleteShoppingListItemProvider',
        dependencies: <ProviderOrFamily>[groupDatabaseProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          DeleteShoppingListItemProvider.$allTransitiveDependencies0,
        ],
        isAutoDispose: true,
      );

  DeleteShoppingListItemProvider call({required String groupID}) =>
      DeleteShoppingListItemProvider._(argument: groupID, from: this);

  @override
  String toString() => r'deleteShoppingListItemProvider';
}

@ProviderFor(restoreShoppingListItem)
final restoreShoppingListItemProvider = RestoreShoppingListItemFamily._();

final class RestoreShoppingListItemProvider
    extends
        $FunctionalProvider<
          RestoreShoppingListItem,
          RestoreShoppingListItem,
          RestoreShoppingListItem
        >
    with $Provider<RestoreShoppingListItem> {
  RestoreShoppingListItemProvider._({
    required RestoreShoppingListItemFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'restoreShoppingListItemProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  static final $allTransitiveDependencies0 = groupDatabaseProvider;

  @override
  String debugGetCreateSourceHash() => _$restoreShoppingListItemHash();

  @override
  String toString() {
    return r'restoreShoppingListItemProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<RestoreShoppingListItem> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RestoreShoppingListItem create(Ref ref) {
    final argument = this.argument as String;
    return restoreShoppingListItem(ref, groupID: argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RestoreShoppingListItem value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RestoreShoppingListItem>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RestoreShoppingListItemProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$restoreShoppingListItemHash() =>
    r'4a7a9f510c179c853560b4506d2b6c0c96024fdf';

final class RestoreShoppingListItemFamily extends $Family
    with $FunctionalFamilyOverride<RestoreShoppingListItem, String> {
  RestoreShoppingListItemFamily._()
    : super(
        retry: null,
        name: r'restoreShoppingListItemProvider',
        dependencies: <ProviderOrFamily>[groupDatabaseProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          RestoreShoppingListItemProvider.$allTransitiveDependencies0,
        ],
        isAutoDispose: true,
      );

  RestoreShoppingListItemProvider call({required String groupID}) =>
      RestoreShoppingListItemProvider._(argument: groupID, from: this);

  @override
  String toString() => r'restoreShoppingListItemProvider';
}

@ProviderFor(toggleShoppingListItemCheck)
final toggleShoppingListItemCheckProvider =
    ToggleShoppingListItemCheckFamily._();

final class ToggleShoppingListItemCheckProvider
    extends
        $FunctionalProvider<
          ToggleShoppingListItemCheck,
          ToggleShoppingListItemCheck,
          ToggleShoppingListItemCheck
        >
    with $Provider<ToggleShoppingListItemCheck> {
  ToggleShoppingListItemCheckProvider._({
    required ToggleShoppingListItemCheckFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'toggleShoppingListItemCheckProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  static final $allTransitiveDependencies0 = groupDatabaseProvider;
  static final $allTransitiveDependencies1 =
      requestStoreReviewOnPurchasedItemCheckProvider;
  static final $allTransitiveDependencies2 =
      RequestStoreReviewOnPurchasedItemCheckProvider
          .$allTransitiveDependencies0;

  @override
  String debugGetCreateSourceHash() => _$toggleShoppingListItemCheckHash();

  @override
  String toString() {
    return r'toggleShoppingListItemCheckProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<ToggleShoppingListItemCheck> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ToggleShoppingListItemCheck create(Ref ref) {
    final argument = this.argument as String;
    return toggleShoppingListItemCheck(ref, groupID: argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ToggleShoppingListItemCheck value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ToggleShoppingListItemCheck>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ToggleShoppingListItemCheckProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$toggleShoppingListItemCheckHash() =>
    r'94d50b13acc9f88d1100ab2e9fff81f49b96bddb';

final class ToggleShoppingListItemCheckFamily extends $Family
    with $FunctionalFamilyOverride<ToggleShoppingListItemCheck, String> {
  ToggleShoppingListItemCheckFamily._()
    : super(
        retry: null,
        name: r'toggleShoppingListItemCheckProvider',
        dependencies: <ProviderOrFamily>[
          groupDatabaseProvider,
          requestStoreReviewOnPurchasedItemCheckProvider,
        ],
        $allTransitiveDependencies: <ProviderOrFamily>[
          ToggleShoppingListItemCheckProvider.$allTransitiveDependencies0,
          ToggleShoppingListItemCheckProvider.$allTransitiveDependencies1,
          ToggleShoppingListItemCheckProvider.$allTransitiveDependencies2,
        ],
        isAutoDispose: true,
      );

  ToggleShoppingListItemCheckProvider call({required String groupID}) =>
      ToggleShoppingListItemCheckProvider._(argument: groupID, from: this);

  @override
  String toString() => r'toggleShoppingListItemCheckProvider';
}

@ProviderFor(updateShoppingListItem)
final updateShoppingListItemProvider = UpdateShoppingListItemFamily._();

final class UpdateShoppingListItemProvider
    extends
        $FunctionalProvider<
          UpdateShoppingListItem,
          UpdateShoppingListItem,
          UpdateShoppingListItem
        >
    with $Provider<UpdateShoppingListItem> {
  UpdateShoppingListItemProvider._({
    required UpdateShoppingListItemFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'updateShoppingListItemProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  static final $allTransitiveDependencies0 = groupDatabaseProvider;

  @override
  String debugGetCreateSourceHash() => _$updateShoppingListItemHash();

  @override
  String toString() {
    return r'updateShoppingListItemProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<UpdateShoppingListItem> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UpdateShoppingListItem create(Ref ref) {
    final argument = this.argument as String;
    return updateShoppingListItem(ref, groupID: argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateShoppingListItem value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateShoppingListItem>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UpdateShoppingListItemProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$updateShoppingListItemHash() =>
    r'e077a910ba5656f7ba0b1e5bc43a48a4908e63a1';

final class UpdateShoppingListItemFamily extends $Family
    with $FunctionalFamilyOverride<UpdateShoppingListItem, String> {
  UpdateShoppingListItemFamily._()
    : super(
        retry: null,
        name: r'updateShoppingListItemProvider',
        dependencies: <ProviderOrFamily>[groupDatabaseProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          UpdateShoppingListItemProvider.$allTransitiveDependencies0,
        ],
        isAutoDispose: true,
      );

  UpdateShoppingListItemProvider call({required String groupID}) =>
      UpdateShoppingListItemProvider._(argument: groupID, from: this);

  @override
  String toString() => r'updateShoppingListItemProvider';
}

@ProviderFor(shoppingListItemBatchUpdate)
final shoppingListItemBatchUpdateProvider =
    ShoppingListItemBatchUpdateFamily._();

final class ShoppingListItemBatchUpdateProvider
    extends
        $FunctionalProvider<
          ShoppingListItemBatchUpdate,
          ShoppingListItemBatchUpdate,
          ShoppingListItemBatchUpdate
        >
    with $Provider<ShoppingListItemBatchUpdate> {
  ShoppingListItemBatchUpdateProvider._({
    required ShoppingListItemBatchUpdateFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'shoppingListItemBatchUpdateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  static final $allTransitiveDependencies0 = groupDatabaseProvider;

  @override
  String debugGetCreateSourceHash() => _$shoppingListItemBatchUpdateHash();

  @override
  String toString() {
    return r'shoppingListItemBatchUpdateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<ShoppingListItemBatchUpdate> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ShoppingListItemBatchUpdate create(Ref ref) {
    final argument = this.argument as String;
    return shoppingListItemBatchUpdate(ref, groupID: argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ShoppingListItemBatchUpdate value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ShoppingListItemBatchUpdate>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ShoppingListItemBatchUpdateProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$shoppingListItemBatchUpdateHash() =>
    r'd1d20f2dc3ac6e9a43e79e02e7d3d6d2e4f2ca09';

final class ShoppingListItemBatchUpdateFamily extends $Family
    with $FunctionalFamilyOverride<ShoppingListItemBatchUpdate, String> {
  ShoppingListItemBatchUpdateFamily._()
    : super(
        retry: null,
        name: r'shoppingListItemBatchUpdateProvider',
        dependencies: <ProviderOrFamily>[groupDatabaseProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          ShoppingListItemBatchUpdateProvider.$allTransitiveDependencies0,
        ],
        isAutoDispose: true,
      );

  ShoppingListItemBatchUpdateProvider call({required String groupID}) =>
      ShoppingListItemBatchUpdateProvider._(argument: groupID, from: this);

  @override
  String toString() => r'shoppingListItemBatchUpdateProvider';
}
