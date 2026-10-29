// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'source_image.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 買い物リストに紐づく「写真から追加」の元画像一覧を、保存日時の新しい順で購読する。
/// ドキュメントの作成・削除は generateShoppingListItemsFromImage Function
/// （Admin SDK）が行うため、クライアント側は読み取りのみで書き込み用の class は持たない。

@ProviderFor(sourceImages)
final sourceImagesProvider = SourceImagesFamily._();

/// 買い物リストに紐づく「写真から追加」の元画像一覧を、保存日時の新しい順で購読する。
/// ドキュメントの作成・削除は generateShoppingListItemsFromImage Function
/// （Admin SDK）が行うため、クライアント側は読み取りのみで書き込み用の class は持たない。

final class SourceImagesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GroupShoppingListSourceImage>>,
          List<GroupShoppingListSourceImage>,
          Stream<List<GroupShoppingListSourceImage>>
        >
    with
        $FutureModifier<List<GroupShoppingListSourceImage>>,
        $StreamProvider<List<GroupShoppingListSourceImage>> {
  /// 買い物リストに紐づく「写真から追加」の元画像一覧を、保存日時の新しい順で購読する。
  /// ドキュメントの作成・削除は generateShoppingListItemsFromImage Function
  /// （Admin SDK）が行うため、クライアント側は読み取りのみで書き込み用の class は持たない。
  SourceImagesProvider._({
    required SourceImagesFamily super.from,
    required ({String groupID, String shoppingListID}) super.argument,
  }) : super(
         retry: null,
         name: r'sourceImagesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  static final $allTransitiveDependencies0 = groupDatabaseProvider;

  @override
  String debugGetCreateSourceHash() => _$sourceImagesHash();

  @override
  String toString() {
    return r'sourceImagesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<GroupShoppingListSourceImage>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<GroupShoppingListSourceImage>> create(Ref ref) {
    final argument = this.argument as ({String groupID, String shoppingListID});
    return sourceImages(
      ref,
      groupID: argument.groupID,
      shoppingListID: argument.shoppingListID,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SourceImagesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sourceImagesHash() => r'66e5a69b1ee3f74ec9d94ca5b923efb8e1d6d07f';

/// 買い物リストに紐づく「写真から追加」の元画像一覧を、保存日時の新しい順で購読する。
/// ドキュメントの作成・削除は generateShoppingListItemsFromImage Function
/// （Admin SDK）が行うため、クライアント側は読み取りのみで書き込み用の class は持たない。

final class SourceImagesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<GroupShoppingListSourceImage>>,
          ({String groupID, String shoppingListID})
        > {
  SourceImagesFamily._()
    : super(
        retry: null,
        name: r'sourceImagesProvider',
        dependencies: <ProviderOrFamily>[groupDatabaseProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          SourceImagesProvider.$allTransitiveDependencies0,
        ],
        isAutoDispose: true,
      );

  /// 買い物リストに紐づく「写真から追加」の元画像一覧を、保存日時の新しい順で購読する。
  /// ドキュメントの作成・削除は generateShoppingListItemsFromImage Function
  /// （Admin SDK）が行うため、クライアント側は読み取りのみで書き込み用の class は持たない。

  SourceImagesProvider call({
    required String groupID,
    required String shoppingListID,
  }) => SourceImagesProvider._(
    argument: (groupID: groupID, shoppingListID: shoppingListID),
    from: this,
  );

  @override
  String toString() => r'sourceImagesProvider';
}
