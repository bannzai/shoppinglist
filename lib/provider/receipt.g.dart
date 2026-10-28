// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 買い物リストに紐づくレシート一覧を、登録日時の新しい順で購読する。

@ProviderFor(receipts)
final receiptsProvider = ReceiptsFamily._();

/// 買い物リストに紐づくレシート一覧を、登録日時の新しい順で購読する。

final class ReceiptsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GroupShoppingListReceipt>>,
          List<GroupShoppingListReceipt>,
          Stream<List<GroupShoppingListReceipt>>
        >
    with
        $FutureModifier<List<GroupShoppingListReceipt>>,
        $StreamProvider<List<GroupShoppingListReceipt>> {
  /// 買い物リストに紐づくレシート一覧を、登録日時の新しい順で購読する。
  ReceiptsProvider._({
    required ReceiptsFamily super.from,
    required ({String groupID, String shoppingListID}) super.argument,
  }) : super(
         retry: null,
         name: r'receiptsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  static final $allTransitiveDependencies0 = groupDatabaseProvider;

  @override
  String debugGetCreateSourceHash() => _$receiptsHash();

  @override
  String toString() {
    return r'receiptsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<GroupShoppingListReceipt>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<GroupShoppingListReceipt>> create(Ref ref) {
    final argument = this.argument as ({String groupID, String shoppingListID});
    return receipts(
      ref,
      groupID: argument.groupID,
      shoppingListID: argument.shoppingListID,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ReceiptsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$receiptsHash() => r'1b6eb44246552c7632a77c679912a3c1bb4848ba';

/// 買い物リストに紐づくレシート一覧を、登録日時の新しい順で購読する。

final class ReceiptsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<GroupShoppingListReceipt>>,
          ({String groupID, String shoppingListID})
        > {
  ReceiptsFamily._()
    : super(
        retry: null,
        name: r'receiptsProvider',
        dependencies: <ProviderOrFamily>[groupDatabaseProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          ReceiptsProvider.$allTransitiveDependencies0,
        ],
        isAutoDispose: true,
      );

  /// 買い物リストに紐づくレシート一覧を、登録日時の新しい順で購読する。

  ReceiptsProvider call({
    required String groupID,
    required String shoppingListID,
  }) => ReceiptsProvider._(
    argument: (groupID: groupID, shoppingListID: shoppingListID),
    from: this,
  );

  @override
  String toString() => r'receiptsProvider';
}

@ProviderFor(addReceipt)
final addReceiptProvider = AddReceiptFamily._();

final class AddReceiptProvider
    extends $FunctionalProvider<AddReceipt, AddReceipt, AddReceipt>
    with $Provider<AddReceipt> {
  AddReceiptProvider._({
    required AddReceiptFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'addReceiptProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  static final $allTransitiveDependencies0 = groupDatabaseProvider;

  @override
  String debugGetCreateSourceHash() => _$addReceiptHash();

  @override
  String toString() {
    return r'addReceiptProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<AddReceipt> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AddReceipt create(Ref ref) {
    final argument = this.argument as String;
    return addReceipt(ref, groupID: argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AddReceipt value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AddReceipt>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AddReceiptProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$addReceiptHash() => r'e2fe03abbde67a94a479f7d6e4e61e4a006803f8';

final class AddReceiptFamily extends $Family
    with $FunctionalFamilyOverride<AddReceipt, String> {
  AddReceiptFamily._()
    : super(
        retry: null,
        name: r'addReceiptProvider',
        dependencies: <ProviderOrFamily>[groupDatabaseProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          AddReceiptProvider.$allTransitiveDependencies0,
        ],
        isAutoDispose: true,
      );

  AddReceiptProvider call({required String groupID}) =>
      AddReceiptProvider._(argument: groupID, from: this);

  @override
  String toString() => r'addReceiptProvider';
}

@ProviderFor(updateReceipt)
final updateReceiptProvider = UpdateReceiptFamily._();

final class UpdateReceiptProvider
    extends $FunctionalProvider<UpdateReceipt, UpdateReceipt, UpdateReceipt>
    with $Provider<UpdateReceipt> {
  UpdateReceiptProvider._({
    required UpdateReceiptFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'updateReceiptProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  static final $allTransitiveDependencies0 = groupDatabaseProvider;

  @override
  String debugGetCreateSourceHash() => _$updateReceiptHash();

  @override
  String toString() {
    return r'updateReceiptProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<UpdateReceipt> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UpdateReceipt create(Ref ref) {
    final argument = this.argument as String;
    return updateReceipt(ref, groupID: argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateReceipt value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateReceipt>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UpdateReceiptProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$updateReceiptHash() => r'5ff1ababcc023e3c4e641a57cabafd018caa58c5';

final class UpdateReceiptFamily extends $Family
    with $FunctionalFamilyOverride<UpdateReceipt, String> {
  UpdateReceiptFamily._()
    : super(
        retry: null,
        name: r'updateReceiptProvider',
        dependencies: <ProviderOrFamily>[groupDatabaseProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          UpdateReceiptProvider.$allTransitiveDependencies0,
        ],
        isAutoDispose: true,
      );

  UpdateReceiptProvider call({required String groupID}) =>
      UpdateReceiptProvider._(argument: groupID, from: this);

  @override
  String toString() => r'updateReceiptProvider';
}
