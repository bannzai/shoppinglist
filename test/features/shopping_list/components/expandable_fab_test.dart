import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shoppinglist/entity/ai_usage.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:shoppinglist/features/shopping_list/components/expandable_fab.dart';
import 'package:shoppinglist/provider/ai_processing.dart';
import 'package:shoppinglist/provider/ai_usage.dart';
import 'package:shoppinglist/provider/current_user_id.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/purchase/purchase.dart';
import '../../../helpers/localized_test_app.dart';

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

/// AI 処理中状態を固定する `AIProcessing` の差し替え用。
class _ProcessingAIProcessing extends AIProcessing {
  final AIProcessingType type;
  _ProcessingAIProcessing(this.type);

  @override
  AIProcessingType? build() => type;
}

void main() {
  Future<_RecordingAddShoppingListItem> pumpFab(
    WidgetTester tester, {
    AIProcessingType? aiProcessingType,
    bool isKeyboardVisible = false,
    FocusNode? textFieldFocusNode,
  }) async {
    final recordingAdd = _RecordingAddShoppingListItem();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          customerInfoProvider.overrideWith(
            (ref) => const Stream<CustomerInfo>.empty(),
          ),
          currentMonthAIUsageProvider.overrideWith(
            (ref) => const Stream<UserAIUsage?>.empty(),
          ),
          currentUserIDProvider.overrideWithValue('u'),
          addShoppingListItemProvider(
            groupID: 'g',
          ).overrideWith((ref) => recordingAdd),
          if (aiProcessingType != null)
            aIProcessingProvider.overrideWith(
              () => _ProcessingAIProcessing(aiProcessingType),
            ),
        ],
        child: localizedTestApp(
          theme: buildAppTheme(accent: AccentPreset.shu),
          home: Scaffold(
            // キーボード表示中の unfocus 検証用にフォーカスを当てる先の TextField。
            body:
                textFieldFocusNode != null
                    ? TextField(focusNode: textFieldFocusNode)
                    : null,
            floatingActionButton: ExpandableFab(
              groupID: 'g',
              shoppingListID: 's',
              shoppingListItems: const [],
              isKeyboardVisible: isKeyboardVisible,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    return recordingAdd;
  }

  testWidgets('長押しで開いた「写真から追加」がタップ到達しダイアログが開く', (tester) async {
    await pumpFab(tester);

    // 長押しで FAB メニューを開く。
    await tester.longPress(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.photo_camera_outlined));
    await tester.pumpAndSettle();

    // タップが InkWell へ到達していれば _showImagePicker が走り、ダイアログが開く。
    // 修正前はメニューが Stack 境界外でヒットテスト対象外 → ダイアログが出ない。
    expect(find.text('カメラ'), findsOneWidget);
    expect(find.text('フォトライブラリ'), findsOneWidget);
  });

  testWidgets('ラベル文字をタップしても（行全体が反応し）ダイアログが開く', (tester) async {
    await pumpFab(tester);

    await tester.longPress(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // アイコンの 44px ではなくラベル文字側をタップ。行全体がタップ領域。
    await tester.tap(find.text('写真から追加'));
    await tester.pumpAndSettle();

    // 二重発火していれば 'カメラ' が 2 つになるため findsOneWidget で重複も検出する。
    expect(find.text('カメラ'), findsOneWidget);
  });

  testWidgets('x 状態で FAB をタップすると Row を追加せず閉じる', (tester) async {
    final recordingAdd = await pumpFab(tester);

    // 長押しでメニューを開く（× 状態）。
    await tester.longPress(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.close), findsOneWidget);

    // × 状態の FAB をタップ → 閉じるだけ。
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(recordingAdd.callCount, 0, reason: 'メニュー展開中（x 状態）のタップは Row 追加せず閉じる');
    expect(
      find.byIcon(Icons.add_task),
      findsOneWidget,
      reason: '閉じて add_task に戻る',
    );
  });

  testWidgets('通常状態の FAB タップは空行を 1 件追加しメニューは開かない', (tester) async {
    final recordingAdd = await pumpFab(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // タップは空行追加のみ。メニューは開かない（add_task のまま・× は出ない）。
    expect(recordingAdd.callCount, 1);
    expect(find.byIcon(Icons.add_task), findsOneWidget);
    expect(find.byIcon(Icons.close), findsNothing);
  });

  testWidgets('長押しでメニューが開き Row は追加しない', (tester) async {
    final recordingAdd = await pumpFab(tester);

    await tester.longPress(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // 長押しでメニューが開く（× 表示）。空行追加は走らない。
    expect(recordingAdd.callCount, 0);
    expect(find.byIcon(Icons.close), findsOneWidget);
    // タップで空行追加できるため、メニューに「1行追加」（Icons.add）は置かない。
    expect(find.byIcon(Icons.add), findsNothing);
  });

  testWidgets('x 状態で FAB を長押しすると Row を追加せず閉じる', (tester) async {
    final recordingAdd = await pumpFab(tester);

    await tester.longPress(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.close), findsOneWidget);

    // × 状態の FAB を再長押し → 閉じるだけ。
    await tester.longPress(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(recordingAdd.callCount, 0);
    expect(
      find.byIcon(Icons.add_task),
      findsOneWidget,
      reason: '閉じて add_task に戻る',
    );
  });

  testWidgets('キーボード表示中のタップは空行を追加せずフォーカスを外す', (tester) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    final recordingAdd = await pumpFab(
      tester,
      isKeyboardVisible: true,
      textFieldFocusNode: focusNode,
    );

    await tester.showKeyboard(find.byType(TextField));
    await tester.pump();
    expect(focusNode.hasFocus, isTrue);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // フォーカスが外れる = 実機ではソフトキーボードが閉じる(Issue #498)。
    // 空行を追加すると新規行の autofocus でキーボードが開き直るため、追加はしない。
    expect(focusNode.hasFocus, isFalse);
    expect(recordingAdd.callCount, 0);
    expect(find.byIcon(Icons.close), findsNothing, reason: 'メニューも開かない');
  });

  testWidgets('メニュー展開中かつキーボード表示中のタップはメニューを閉じフォーカスも外す', (tester) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    final recordingAdd = await pumpFab(
      tester,
      isKeyboardVisible: true,
      textFieldFocusNode: focusNode,
    );

    // 長押しでメニューを開き（× 状態）、その後 TextField をタップして
    // キーボードが開き直った状態を作る。
    await tester.longPress(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.close), findsOneWidget);
    await tester.showKeyboard(find.byType(TextField));
    await tester.pump();
    expect(focusNode.hasFocus, isTrue);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // メニューが閉じ(add_task に戻り)、フォーカスも外れる(Issue #498)。
    expect(find.byIcon(Icons.add_task), findsOneWidget);
    expect(focusNode.hasFocus, isFalse);
    expect(recordingAdd.callCount, 0);
  });

  testWidgets('キーボード表示中の長押しはフォーカスを外してメニューを開く', (tester) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    final recordingAdd = await pumpFab(
      tester,
      isKeyboardVisible: true,
      textFieldFocusNode: focusNode,
    );

    await tester.showKeyboard(find.byType(TextField));
    await tester.pump();
    expect(focusNode.hasFocus, isTrue);

    await tester.longPress(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // キーボードを閉じつつ(unfocus)、メニュー開閉は通常どおり行う(Issue #498)。
    expect(focusNode.hasFocus, isFalse);
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(recordingAdd.callCount, 0);
  });

  testWidgets('AI 処理中は「写真から追加」をタップしてもダイアログが開かない', (tester) async {
    await pumpFab(tester, aiProcessingType: AIProcessingType.categorize);

    await tester.longPress(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.photo_camera_outlined));
    await tester.pumpAndSettle();

    // onTap が null（無効）なので _showImagePicker は走らず、画像選択ダイアログは開かない。
    expect(find.text('カメラ'), findsNothing);
    expect(find.text('フォトライブラリ'), findsNothing);
  });

  testWidgets('AI 処理中は「URL から追加」をタップしてもダイアログが開かない', (tester) async {
    await pumpFab(tester, aiProcessingType: AIProcessingType.categorize);

    await tester.longPress(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.link));
    await tester.pumpAndSettle();

    // onTap が null（無効）なので _showURLInputDialog は走らず、URL 入力ダイアログは開かない。
    expect(find.text('URLから買い物リストを生成'), findsNothing);
  });
}
