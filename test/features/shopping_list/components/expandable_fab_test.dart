import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shoppinglist/entity/ai_usage.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:shoppinglist/features/shopping_list/components/expandable_fab.dart';
import 'package:shoppinglist/provider/ai_usage.dart';
import 'package:shoppinglist/provider/current_user_id.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/purchase/purchase.dart';

/// 追加処理の呼び出し回数を記録するモック（Firestore を叩かない）。
class _RecordingAddShoppingListItem extends AddShoppingListItem {
  int callCount = 0;

  _RecordingAddShoppingListItem()
      : super(database: GroupDatabase(groupID: 'g'));

  @override
  Future<GroupShoppingListItem> call({
    required String shoppingListID,
    required String userID,
    required String message,
    required int order,
    required String? description,
    required String? color,
  }) async {
    callCount++;
    return GroupShoppingListItem(
      id: 'id',
      groupID: 'g',
      shoppingListID: shoppingListID,
      userID: userID,
      message: message,
      order: order,
      description: description,
      color: color,
      checkedByUserID: null,
      imageURL: null,
      lastEditedByUserID: null,
    );
  }
}

void main() {
  Future<_RecordingAddShoppingListItem> pumpFab(WidgetTester tester) async {
    final recordingAdd = _RecordingAddShoppingListItem();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          customerInfoProvider
              .overrideWith((ref) => const Stream<CustomerInfo>.empty()),
          currentMonthAIUsageProvider
              .overrideWith((ref) => const Stream<UserAIUsage?>.empty()),
          currentUserIDProvider.overrideWithValue('u'),
          addShoppingListItemProvider(groupID: 'g')
              .overrideWith((ref) => recordingAdd),
        ],
        child: MaterialApp(
          theme: buildAppTheme(
            accent: AccentPreset.shu,
          ),
          home: const Scaffold(
            floatingActionButton: ExpandableFab(
              groupID: 'g',
              shoppingListID: 's',
              shoppingListItems: [],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    return recordingAdd;
  }

  testWidgets('③ 長押しで開いた「写真から追加」がタップ到達しダイアログが開く', (tester) async {
    await pumpFab(tester);

    await tester.longPress(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.photo_camera_outlined));
    await tester.pumpAndSettle();

    // タップが InkWell へ到達していれば _showImagePicker が走り、ダイアログが開く。
    // 修正前はメニューが Stack 境界外でヒットテスト対象外 → ダイアログが出ない。
    expect(find.text('カメラ'), findsOneWidget);
    expect(find.text('フォトライブラリ'), findsOneWidget);
  });

  testWidgets('③ ラベル文字をタップしても（行全体が反応し）ダイアログが開く', (tester) async {
    await pumpFab(tester);

    await tester.longPress(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // アイコンの 44px ではなくラベル文字側をタップ。行全体がタップ領域。
    await tester.tap(find.text('写真から追加'));
    await tester.pumpAndSettle();

    // 二重発火していれば 'カメラ' が 2 つになるため findsOneWidget で重複も検出する。
    expect(find.text('カメラ'), findsOneWidget);
  });

  testWidgets('② x 状態で FAB をタップしても Row を追加しない', (tester) async {
    final recordingAdd = await pumpFab(tester);

    await tester.longPress(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(recordingAdd.callCount, 0,
        reason: 'メニュー展開中（x 状態）のタップは Row 追加せず閉じる');
  });

  testWidgets('② 通常状態の FAB タップは空行を 1 件追加する', (tester) async {
    final recordingAdd = await pumpFab(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();

    expect(recordingAdd.callCount, 1);
  });
}
