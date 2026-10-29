// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_list.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 1時間ごとに自身を無効化して現在時刻を更新するプロバイダー。
/// 無料ユーザーの30日間表示制限でアプリ長時間起動時のDateTime.now()の古さを防ぐ。

@ProviderFor(hourlyTrigger)
final hourlyTriggerProvider = HourlyTriggerProvider._();

/// 1時間ごとに自身を無効化して現在時刻を更新するプロバイダー。
/// 無料ユーザーの30日間表示制限でアプリ長時間起動時のDateTime.now()の古さを防ぐ。

final class HourlyTriggerProvider
    extends $FunctionalProvider<DateTime, DateTime, DateTime>
    with $Provider<DateTime> {
  /// 1時間ごとに自身を無効化して現在時刻を更新するプロバイダー。
  /// 無料ユーザーの30日間表示制限でアプリ長時間起動時のDateTime.now()の古さを防ぐ。
  HourlyTriggerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hourlyTriggerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hourlyTriggerHash();

  @$internal
  @override
  $ProviderElement<DateTime> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DateTime create(Ref ref) {
    return hourlyTrigger(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$hourlyTriggerHash() => r'c683fce521c33003f53f9a37eec905706d1627ac';

/// 買い物リスト一覧を取得するプロバイダー。
/// isPremium が false の場合は createdDateTime が30日以内のリストのみ返す。
/// このフィルタはUX最適化であり、認可は firestore.rules で担保する。

@ProviderFor(shoppingLists)
final shoppingListsProvider = ShoppingListsFamily._();

/// 買い物リスト一覧を取得するプロバイダー。
/// isPremium が false の場合は createdDateTime が30日以内のリストのみ返す。
/// このフィルタはUX最適化であり、認可は firestore.rules で担保する。

final class ShoppingListsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GroupShoppingList>>,
          List<GroupShoppingList>,
          Stream<List<GroupShoppingList>>
        >
    with
        $FutureModifier<List<GroupShoppingList>>,
        $StreamProvider<List<GroupShoppingList>> {
  /// 買い物リスト一覧を取得するプロバイダー。
  /// isPremium が false の場合は createdDateTime が30日以内のリストのみ返す。
  /// このフィルタはUX最適化であり、認可は firestore.rules で担保する。
  ShoppingListsProvider._({
    required ShoppingListsFamily super.from,
    required ({String groupID, bool isPremium}) super.argument,
  }) : super(
         retry: null,
         name: r'shoppingListsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  static final $allTransitiveDependencies0 = groupDatabaseProvider;

  @override
  String debugGetCreateSourceHash() => _$shoppingListsHash();

  @override
  String toString() {
    return r'shoppingListsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<GroupShoppingList>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<GroupShoppingList>> create(Ref ref) {
    final argument = this.argument as ({String groupID, bool isPremium});
    return shoppingLists(
      ref,
      groupID: argument.groupID,
      isPremium: argument.isPremium,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ShoppingListsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$shoppingListsHash() => r'0f5a6cd35ff5e30fcae92e7582ecf1f0de3784fb';

/// 買い物リスト一覧を取得するプロバイダー。
/// isPremium が false の場合は createdDateTime が30日以内のリストのみ返す。
/// このフィルタはUX最適化であり、認可は firestore.rules で担保する。

final class ShoppingListsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<GroupShoppingList>>,
          ({String groupID, bool isPremium})
        > {
  ShoppingListsFamily._()
    : super(
        retry: null,
        name: r'shoppingListsProvider',
        dependencies: <ProviderOrFamily>[groupDatabaseProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          ShoppingListsProvider.$allTransitiveDependencies0,
        ],
        isAutoDispose: true,
      );

  /// 買い物リスト一覧を取得するプロバイダー。
  /// isPremium が false の場合は createdDateTime が30日以内のリストのみ返す。
  /// このフィルタはUX最適化であり、認可は firestore.rules で担保する。

  ShoppingListsProvider call({
    required String groupID,
    required bool isPremium,
  }) => ShoppingListsProvider._(
    argument: (groupID: groupID, isPremium: isPremium),
    from: this,
  );

  @override
  String toString() => r'shoppingListsProvider';
}

@ProviderFor(shoppingListAdd)
final shoppingListAddProvider = ShoppingListAddFamily._();

final class ShoppingListAddProvider
    extends
        $FunctionalProvider<ShoppingListAdd, ShoppingListAdd, ShoppingListAdd>
    with $Provider<ShoppingListAdd> {
  ShoppingListAddProvider._({
    required ShoppingListAddFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'shoppingListAddProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  static final $allTransitiveDependencies0 = groupDatabaseProvider;

  @override
  String debugGetCreateSourceHash() => _$shoppingListAddHash();

  @override
  String toString() {
    return r'shoppingListAddProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<ShoppingListAdd> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ShoppingListAdd create(Ref ref) {
    final argument = this.argument as String;
    return shoppingListAdd(ref, groupID: argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ShoppingListAdd value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ShoppingListAdd>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ShoppingListAddProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$shoppingListAddHash() => r'cb07351e3c4fb3416281ba5c626b180dd6eeb5cd';

final class ShoppingListAddFamily extends $Family
    with $FunctionalFamilyOverride<ShoppingListAdd, String> {
  ShoppingListAddFamily._()
    : super(
        retry: null,
        name: r'shoppingListAddProvider',
        dependencies: <ProviderOrFamily>[groupDatabaseProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          ShoppingListAddProvider.$allTransitiveDependencies0,
        ],
        isAutoDispose: true,
      );

  ShoppingListAddProvider call({required String groupID}) =>
      ShoppingListAddProvider._(argument: groupID, from: this);

  @override
  String toString() => r'shoppingListAddProvider';
}

@ProviderFor(shoppingListUpdate)
final shoppingListUpdateProvider = ShoppingListUpdateFamily._();

final class ShoppingListUpdateProvider
    extends
        $FunctionalProvider<
          ShoppingListUpdate,
          ShoppingListUpdate,
          ShoppingListUpdate
        >
    with $Provider<ShoppingListUpdate> {
  ShoppingListUpdateProvider._({
    required ShoppingListUpdateFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'shoppingListUpdateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  static final $allTransitiveDependencies0 = groupDatabaseProvider;

  @override
  String debugGetCreateSourceHash() => _$shoppingListUpdateHash();

  @override
  String toString() {
    return r'shoppingListUpdateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<ShoppingListUpdate> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ShoppingListUpdate create(Ref ref) {
    final argument = this.argument as String;
    return shoppingListUpdate(ref, groupID: argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ShoppingListUpdate value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ShoppingListUpdate>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ShoppingListUpdateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$shoppingListUpdateHash() =>
    r'78b4ec8d0e4956e2998fd8c202915a274aae7bc5';

final class ShoppingListUpdateFamily extends $Family
    with $FunctionalFamilyOverride<ShoppingListUpdate, String> {
  ShoppingListUpdateFamily._()
    : super(
        retry: null,
        name: r'shoppingListUpdateProvider',
        dependencies: <ProviderOrFamily>[groupDatabaseProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          ShoppingListUpdateProvider.$allTransitiveDependencies0,
        ],
        isAutoDispose: true,
      );

  ShoppingListUpdateProvider call({required String groupID}) =>
      ShoppingListUpdateProvider._(argument: groupID, from: this);

  @override
  String toString() => r'shoppingListUpdateProvider';
}

@ProviderFor(shoppingListDuplicate)
final shoppingListDuplicateProvider = ShoppingListDuplicateFamily._();

final class ShoppingListDuplicateProvider
    extends
        $FunctionalProvider<
          ShoppingListDuplicate,
          ShoppingListDuplicate,
          ShoppingListDuplicate
        >
    with $Provider<ShoppingListDuplicate> {
  ShoppingListDuplicateProvider._({
    required ShoppingListDuplicateFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'shoppingListDuplicateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  static final $allTransitiveDependencies0 = shoppingListAddProvider;
  static final $allTransitiveDependencies1 =
      ShoppingListAddProvider.$allTransitiveDependencies0;
  static final $allTransitiveDependencies2 = addShoppingListItemProvider;

  @override
  String debugGetCreateSourceHash() => _$shoppingListDuplicateHash();

  @override
  String toString() {
    return r'shoppingListDuplicateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<ShoppingListDuplicate> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ShoppingListDuplicate create(Ref ref) {
    final argument = this.argument as String;
    return shoppingListDuplicate(ref, groupID: argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ShoppingListDuplicate value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ShoppingListDuplicate>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ShoppingListDuplicateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$shoppingListDuplicateHash() =>
    r'065006997da40e65a906ee85c0d2e54499386a33';

final class ShoppingListDuplicateFamily extends $Family
    with $FunctionalFamilyOverride<ShoppingListDuplicate, String> {
  ShoppingListDuplicateFamily._()
    : super(
        retry: null,
        name: r'shoppingListDuplicateProvider',
        dependencies: <ProviderOrFamily>[
          shoppingListAddProvider,
          addShoppingListItemProvider,
        ],
        $allTransitiveDependencies: <ProviderOrFamily>[
          ShoppingListDuplicateProvider.$allTransitiveDependencies0,
          ShoppingListDuplicateProvider.$allTransitiveDependencies1,
          ShoppingListDuplicateProvider.$allTransitiveDependencies2,
        ],
        isAutoDispose: true,
      );

  ShoppingListDuplicateProvider call({required String groupID}) =>
      ShoppingListDuplicateProvider._(argument: groupID, from: this);

  @override
  String toString() => r'shoppingListDuplicateProvider';
}
