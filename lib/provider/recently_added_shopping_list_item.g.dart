// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recently_added_shopping_list_item.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 最後に手入力した買い物リストアイテムの ID を、一時的に保持する。
///
/// Firestore への追加完了前に次の入力が確定することがあるため、入力開始順を連番で管理する。
/// 書き込み完了順が前後しても、最後に確定した入力だけを強調表示する。

@ProviderFor(RecentlyAddedShoppingListItem)
final recentlyAddedShoppingListItemProvider =
    RecentlyAddedShoppingListItemFamily._();

/// 最後に手入力した買い物リストアイテムの ID を、一時的に保持する。
///
/// Firestore への追加完了前に次の入力が確定することがあるため、入力開始順を連番で管理する。
/// 書き込み完了順が前後しても、最後に確定した入力だけを強調表示する。
final class RecentlyAddedShoppingListItemProvider
    extends $NotifierProvider<RecentlyAddedShoppingListItem, String?> {
  /// 最後に手入力した買い物リストアイテムの ID を、一時的に保持する。
  ///
  /// Firestore への追加完了前に次の入力が確定することがあるため、入力開始順を連番で管理する。
  /// 書き込み完了順が前後しても、最後に確定した入力だけを強調表示する。
  RecentlyAddedShoppingListItemProvider._({
    required RecentlyAddedShoppingListItemFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'recentlyAddedShoppingListItemProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$recentlyAddedShoppingListItemHash();

  @override
  String toString() {
    return r'recentlyAddedShoppingListItemProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  RecentlyAddedShoppingListItem create() => RecentlyAddedShoppingListItem();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RecentlyAddedShoppingListItemProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recentlyAddedShoppingListItemHash() =>
    r'94bc9bb531dd9e0161fb2020523afca871ad81fc';

/// 最後に手入力した買い物リストアイテムの ID を、一時的に保持する。
///
/// Firestore への追加完了前に次の入力が確定することがあるため、入力開始順を連番で管理する。
/// 書き込み完了順が前後しても、最後に確定した入力だけを強調表示する。

final class RecentlyAddedShoppingListItemFamily extends $Family
    with
        $ClassFamilyOverride<
          RecentlyAddedShoppingListItem,
          String?,
          String?,
          String?,
          String
        > {
  RecentlyAddedShoppingListItemFamily._()
    : super(
        retry: null,
        name: r'recentlyAddedShoppingListItemProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 最後に手入力した買い物リストアイテムの ID を、一時的に保持する。
  ///
  /// Firestore への追加完了前に次の入力が確定することがあるため、入力開始順を連番で管理する。
  /// 書き込み完了順が前後しても、最後に確定した入力だけを強調表示する。

  RecentlyAddedShoppingListItemProvider call(String shoppingListID) =>
      RecentlyAddedShoppingListItemProvider._(
        argument: shoppingListID,
        from: this,
      );

  @override
  String toString() => r'recentlyAddedShoppingListItemProvider';
}

/// 最後に手入力した買い物リストアイテムの ID を、一時的に保持する。
///
/// Firestore への追加完了前に次の入力が確定することがあるため、入力開始順を連番で管理する。
/// 書き込み完了順が前後しても、最後に確定した入力だけを強調表示する。

abstract class _$RecentlyAddedShoppingListItem extends $Notifier<String?> {
  late final _$args = ref.$arg as String;
  String get shoppingListID => _$args;

  String? build(String shoppingListID);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
