import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/image/storage_image.dart';
import 'package:shoppinglist/entity/group_shopping_list_source_image.dart';
import 'package:shoppinglist/features/shopping_list/components/source_image_strip.dart';
import 'package:shoppinglist/provider/source_image.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';

const _testGroupID = 'test-group-001';
const _testListID = 'list-001';

GroupShoppingListSourceImage _sourceImage(
  int index,
) => GroupShoppingListSourceImage(
  id: 'source-image-$index',
  groupID: _testGroupID,
  shoppingListID: _testListID,
  userID: 'user-001',
  storagePath:
      'groups/$_testGroupID/shoppingLists/$_testListID/sourceImages/source-image-$index.jpeg',
);

Future<void> _pumpStrip(
  WidgetTester tester, {
  required List<GroupShoppingListSourceImage> sourceImages,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sourceImagesProvider(
          groupID: _testGroupID,
          shoppingListID: _testListID,
        ).overrideWith((ref) => Stream.value(sourceImages)),
      ],
      child: MaterialApp(
        theme: buildAppTheme(accent: AccentPreset.shu),
        home: const Scaffold(
          body: SourceImageStrip(
            groupID: _testGroupID,
            shoppingListID: _testListID,
          ),
        ),
      ),
    ),
  );
  // テスト環境では Firebase 未初期化のため StorageImage の getDownloadURL が
  // 失敗し broken_image 表示（エラー状態）で静止する。
  await tester.pumpAndSettle();
}

void main() {
  group('SourceImageStrip', () {
    testWidgets('元画像が0枚なら何も表示しない', (WidgetTester tester) async {
      await _pumpStrip(tester, sourceImages: const []);

      expect(find.byType(StorageImage), findsNothing);
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('保存済みの元画像の枚数分サムネイルを表示する', (WidgetTester tester) async {
      await _pumpStrip(
        tester,
        sourceImages: [for (var i = 0; i < 3; i++) _sourceImage(i)],
      );

      expect(find.byType(StorageImage), findsNWidgets(3));
    });

    testWidgets('上限の5枚まで表示できる', (WidgetTester tester) async {
      await _pumpStrip(
        tester,
        sourceImages: [
          for (var i = 0; i < maxShoppingListSourceImageCount; i++)
            _sourceImage(i),
        ],
      );

      expect(
        find.byType(StorageImage, skipOffstage: false),
        findsNWidgets(maxShoppingListSourceImageCount),
      );
    });

    testWidgets('サムネイルのタップで拡大表示ダイアログが開く', (WidgetTester tester) async {
      await _pumpStrip(tester, sourceImages: [_sourceImage(0)]);

      await tester.tap(find.byType(StorageImage).first);
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsOneWidget);
      expect(find.byType(InteractiveViewer), findsOneWidget);
      // ダイアログ内にも拡大表示用の StorageImage が1つ増える。
      expect(find.byType(StorageImage), findsNWidgets(2));
    });
  });
}
