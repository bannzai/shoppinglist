import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/previews/mock/mock_data.dart';
import 'package:shoppinglist/features/previews/mock/mock_provider_overrides.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/text_shopping_list_item.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/style/color.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';

/// 検証用アイテム。message / status / color / description / imageURL 以外は固定。
GroupShoppingListItem _item({
  required String id,
  required String message,
  GroupShoppingListItemStatus status = GroupShoppingListItemStatus.unchecked,
  String? color,
  String? description,
  String? imageURL,
}) {
  return GroupShoppingListItem(
    id: id,
    groupID: mockGroupID,
    shoppingListID: mockShoppingListID,
    userID: mockUserID,
    message: message,
    order: 0,
    status: status,
    checkedByUserID: null,
    color: color,
    description: description,
    imageURL: imageURL,
    lastEditedByUserID: null,
  );
}

/// [AddShoppingListItem] の呼び出し引数 (message, order) を記録するフェイク。
class _RecordingAddShoppingListItem extends AddShoppingListItem {
  /// 呼び出しごとの message と order。
  final List<({String message, int order})> calls = [];

  _RecordingAddShoppingListItem()
      : super(database: GroupDatabase(groupID: mockGroupID));

  @override
  Future<GroupShoppingListItem> call({
    required String shoppingListID,
    required String userID,
    required String message,
    required int order,
    required String? description,
    required String? color,
  }) async {
    calls.add((message: message, order: order));
    return _item(id: 'added-${calls.length}', message: message);
  }
}

/// [ShoppingListItemBatchUpdate] の呼び出しごとの更新アイテム一覧を記録するフェイク。
class _RecordingShoppingListItemBatchUpdate
    extends ShoppingListItemBatchUpdate {
  /// 呼び出しごとの shoppingListItems。
  final List<List<GroupShoppingListItem>> calls = [];

  _RecordingShoppingListItemBatchUpdate()
      : super(database: GroupDatabase(groupID: mockGroupID));

  @override
  Future<void> call({
    required String shoppingListID,
    required List<GroupShoppingListItem> shoppingListItems,
  }) async {
    calls.add(shoppingListItems);
  }
}

/// [UpdateShoppingListItem] の呼び出しごとの item を記録するフェイク。
class _RecordingUpdateShoppingListItem extends UpdateShoppingListItem {
  /// 呼び出しごとの item。
  final List<GroupShoppingListItem> calls = [];

  _RecordingUpdateShoppingListItem()
      : super(database: GroupDatabase(groupID: mockGroupID));

  @override
  Future<void> call({
    required String shoppingListID,
    required GroupShoppingListItem item,
    required String editedByUserID,
  }) async {
    calls.add(item);
  }
}

/// フォーカス喪失時の空行削除 (`doc(id).delete()`) を記録する [GroupDatabase] のフェイク。
/// 本物は FirebaseFirestore.instance に触れて未初期化の test 環境で落ちるため差し替える。
class _RecordingGroupDatabase extends GroupDatabase {
  /// delete() されたアイテムの id。
  final List<String> deletedItemIDs = [];

  _RecordingGroupDatabase() : super(groupID: mockGroupID);

  @override
  CollectionReference<GroupShoppingListItem> shoppingListItemsReference(
          {required String shoppingListID}) =>
      _RecordingShoppingListItemsReference(deletedItemIDs: deletedItemIDs);
}

// ignore: subtype_of_sealed_class
/// doc() だけを実装した [CollectionReference] のフェイク。
class _RecordingShoppingListItemsReference extends Fake
    implements CollectionReference<GroupShoppingListItem> {
  /// delete() されたアイテムの id の記録先 ([_RecordingGroupDatabase] と共有)。
  final List<String> deletedItemIDs;

  _RecordingShoppingListItemsReference({required this.deletedItemIDs});

  @override
  DocumentReference<GroupShoppingListItem> doc([String? path]) =>
      _RecordingShoppingListItemReference(
          itemID: path!, deletedItemIDs: deletedItemIDs);
}

// ignore: subtype_of_sealed_class
/// delete() だけを実装した [DocumentReference] のフェイク。
class _RecordingShoppingListItemReference extends Fake
    implements DocumentReference<GroupShoppingListItem> {
  /// この参照が指すアイテムの id。
  final String itemID;

  /// delete() されたアイテムの id の記録先 ([_RecordingGroupDatabase] と共有)。
  final List<String> deletedItemIDs;

  _RecordingShoppingListItemReference(
      {required this.itemID, required this.deletedItemIDs});

  @override
  Future<void> delete() async => deletedItemIDs.add(itemID);
}

Future<void> _pump(
  WidgetTester tester,
  GroupShoppingListItem item, {
  int? reorderIndex,
  bool showAddCategoryButton = false,
  List<Override> extraOverrides = const [],
}) async {
  // ignore: invalid_use_of_visible_for_testing_member
  SharedPreferences.setMockInitialValues({});
  final sharedPreferences = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...previewProviderOverrides(sharedPreferences: sharedPreferences),
        // 同じ Provider の override は後勝ちなので、テスト用の記録フェイクで上書きできる。
        ...extraOverrides,
      ],
      child: MaterialApp(
        theme: buildAppTheme(
          accent: AccentPreset.shu,
        ),
        home: Scaffold(
          body: TextShoppingListItemWidget(
            groupID: mockGroupID,
            textShoppingListItem: item,
            shoppingListItems: [item],
            reorderIndex: reorderIndex,
            showAddCategoryButton: showAddCategoryButton,
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

/// `_CircleCheckbox` の GestureDetector を特定する。
/// チェックボックスは唯一 ScaleTransition でラップされているため、その子孫の
/// GestureDetector を読み取れば private 型を参照せずに onTap の有無を検証できる。
GestureDetector _checkboxGesture(WidgetTester tester) {
  return tester.widget<GestureDetector>(
    find.descendant(
      of: find.byType(ScaleTransition),
      matching: find.byType(GestureDetector),
    ),
  );
}

/// 行の背景を塗る [Material] を特定する。
/// 行本体の Material は Dismissible 直下の最外殻なので、深さ優先探索で最初に
/// 見つかるものを読む（IconButton 等が内側に持つ Material より先に列挙される）。
Material _rowMaterial(WidgetTester tester) {
  return tester.widget<Material>(
    find
        .descendant(
          of: find.byType(Dismissible),
          matching: find.byType(Material),
        )
        .first,
  );
}

void main() {
  group('行背景（Issue #374: チェック済み行がカテゴリヘッダーと同化しない）', () {
    testWidgets('チェック済み行の背景は transparent（divider2 半透過を塗らない）', (tester) async {
      // divider2 半透過を塗るとカテゴリヘッダーの surface とほぼ同色になり、
      // セクションの境界が見分けられなくなる回帰を防ぐ。
      await _pump(
        tester,
        _item(
          id: 'checked',
          message: '牛乳',
          status: GroupShoppingListItemStatus.checked,
        ),
      );
      expect(_rowMaterial(tester).color, Colors.transparent);
    });

    testWidgets('未チェック行の背景も transparent', (tester) async {
      await _pump(tester, _item(id: 'unchecked', message: '牛乳'));
      expect(_rowMaterial(tester).color, Colors.transparent);
    });

    testWidgets('アイテムカラー指定時はチェック状態に関わらずカラー 10% を塗る', (tester) async {
      await _pump(
        tester,
        _item(
          id: 'colored',
          message: '牛乳',
          status: GroupShoppingListItemStatus.checked,
          color: '#1F6B4E',
        ),
      );
      expect(
        _rowMaterial(tester).color,
        colorFromHex('#1F6B4E').withValues(alpha: 0.1),
      );
    });
  });

  group('説明 (description) と商品写真サムネイルの一覧表示', () {
    testWidgets('description 設定時は説明テキストを表示する', (tester) async {
      await _pump(
        tester,
        _item(id: 'desc', message: '牛乳', description: '低脂肪 1L'),
      );
      expect(find.byType(ShoppingListItemDescriptionText), findsOneWidget);
    });

    testWidgets('description 未設定時は説明テキストを表示しない', (tester) async {
      await _pump(tester, _item(id: 'no-desc', message: '牛乳'));
      expect(find.byType(ShoppingListItemDescriptionText), findsNothing);
    });

    testWidgets('imageURL 設定時はサムネイルを詳細アイコン (3点リーダー) の左に表示する', (tester) async {
      await _pump(
        tester,
        _item(
          id: 'img',
          message: '牛乳',
          imageURL: 'https://example.com/item.jpg',
        ),
      );
      expect(find.byType(ShoppingListItemThumbnail), findsOneWidget);
      // 行末の more_horiz (3点リーダー) より左に位置すること。
      expect(
        tester.getCenter(find.byType(ShoppingListItemThumbnail)).dx,
        lessThan(tester.getCenter(find.byIcon(Icons.more_horiz)).dx),
      );
    });

    testWidgets('imageURL 未設定時はサムネイルを表示しない', (tester) async {
      await _pump(tester, _item(id: 'no-img', message: '牛乳'));
      expect(find.byType(ShoppingListItemThumbnail), findsNothing);
    });
  });

  group('TextShoppingListItemWidget の空行チェック禁止', () {
    testWidgets('空行: チェックボックスのタップが無効 (onTap == null)', (tester) async {
      await _pump(tester, _item(id: 'empty', message: ''));
      expect(_checkboxGesture(tester).onTap, isNull);
    });

    testWidgets('空白のみの行も空行扱いでタップ無効', (tester) async {
      await _pump(tester, _item(id: 'blank', message: '   '));
      expect(_checkboxGesture(tester).onTap, isNull);
    });

    testWidgets('テキストありの行: チェックボックスのタップが有効 (onTap != null)', (tester) async {
      await _pump(tester, _item(id: 'filled', message: '牛乳'));
      expect(_checkboxGesture(tester).onTap, isNotNull);
    });

    testWidgets('空行: 右スワイプチェックを禁止し左スワイプ削除のみ許可 (endToStart)', (tester) async {
      await _pump(tester, _item(id: 'empty', message: ''));
      expect(
        tester.widget<Dismissible>(find.byType(Dismissible)).direction,
        DismissDirection.endToStart,
      );
    });

    testWidgets('テキストありの行: 左右両方のスワイプを許可 (horizontal)', (tester) async {
      await _pump(tester, _item(id: 'filled', message: '牛乳'));
      expect(
        tester.widget<Dismissible>(find.byType(Dismissible)).direction,
        DismissDirection.horizontal,
      );
    });
  });

  group('TextShoppingListItemWidget の長押し挙動（複製メニュー廃止・並び替えドラッグ）', () {
    testWidgets('長押ししても複製/メモを追加/削除の context menu を出さない', (tester) async {
      await _pump(tester, _item(id: 'filled', message: '牛乳'));
      await tester.longPress(find.text('牛乳'));
      await tester.pumpAndSettle();
      // 旧長押しメニューの項目が一切表示されないこと（メニュー廃止）。
      expect(find.text('複製'), findsNothing);
      expect(find.text('メモを追加'), findsNothing);
      expect(find.text('削除'), findsNothing);
    });

    testWidgets(
        'reorderIndex 指定時は長押しドラッグ用の ReorderableDelayedDragStartListener でラップする',
        (tester) async {
      await _pump(tester, _item(id: 'filled', message: '牛乳'), reorderIndex: 0);
      expect(find.byType(ReorderableDelayedDragStartListener), findsOneWidget);
    });

    testWidgets('reorderIndex が null（入力行）のときは長押しドラッグ対象にしない', (tester) async {
      await _pump(tester, _item(id: 'empty', message: ''));
      expect(find.byType(ReorderableDelayedDragStartListener), findsNothing);
    });
  });

  group('TextShoppingListItemWidget の入力フィールド（Enter でキーボードを閉じない）', () {
    testWidgets(
        'TextField は textInputAction.newline と onChanged を持ち、next/onSubmitted は使わない',
        (tester) async {
      await _pump(tester, _item(id: 'filled', message: '牛乳'));
      final textField = tester.widget<TextField>(find.byType(TextField));
      // actionable な action（next/done 等）は performAction で入力接続を close→reopen
      // （flutter#84240）してソフトキーボードを一瞬閉じるため使わない。改行(Enter)は
      // newline で受け、確定は onChanged の改行検知で行う。この設定が外れると
      // 「Enter のたびにキーボードが開閉する」回帰が再発する（fix-350 で実機計測して確定）。
      expect(textField.textInputAction, TextInputAction.newline);
      expect(textField.onChanged, isNotNull);
      expect(textField.onSubmitted, isNull);
      expect(textField.onEditingComplete, isNull);
    });

    testWidgets('非編集(未フォーカス)の行はテキスト選択を無効化して長押しを並び替えドラッグに渡す', (tester) async {
      // filled な行は自動フォーカスされない(空行のみ自動フォーカス)ため isEditing=false。
      await _pump(tester, _item(id: 'filled', message: '牛乳'));
      expect(
        tester
            .widget<TextField>(find.byType(TextField))
            .enableInteractiveSelection,
        isFalse,
      );
    });
  });

  group('入力行の Enter 確定（連続入力）', () {
    testWidgets('Enter で確定テキストが入力行の位置に追加され、入力行は末尾 (nextOrder) へ繰り下がる',
        (tester) async {
      final add = _RecordingAddShoppingListItem();
      final batchUpdate = _RecordingShoppingListItemBatchUpdate();
      await _pump(tester, _item(id: 'input', message: ''), extraOverrides: [
        addShoppingListItemProvider(groupID: mockGroupID)
            .overrideWith((ref) => add),
        shoppingListItemBatchUpdateProvider(groupID: mockGroupID)
            .overrideWith((ref) => batchUpdate),
      ]);
      // 改行 (Enter) を含むテキストを入力すると onChanged の改行検知で確定する。
      await tester.enterText(find.byType(TextField), '牛乳\n');
      await tester.pump();
      // 確定テキストは入力行の order (=0) 位置に別アイテムとして追加される。
      expect(add.calls.single.message, '牛乳');
      expect(add.calls.single.order, 0);
      // 入力行は nextOrder (=1) へ繰り下がり、リスト末尾の入力欄として残る。
      expect(batchUpdate.calls.single.single.id, 'input');
      expect(batchUpdate.calls.single.single.order, 1);
    });

    testWidgets('確定後も入力行は空のままフォーカスを保ち、連続で Enter 入力できる', (tester) async {
      final add = _RecordingAddShoppingListItem();
      await _pump(tester, _item(id: 'input', message: ''), extraOverrides: [
        addShoppingListItemProvider(groupID: mockGroupID)
            .overrideWith((ref) => add),
        shoppingListItemBatchUpdateProvider(groupID: mockGroupID)
            .overrideWith((ref) => _RecordingShoppingListItemBatchUpdate()),
      ]);
      await tester.enterText(find.byType(TextField), '牛乳\n');
      await tester.pump();
      final textField = tester.widget<TextField>(find.byType(TextField));
      // 確定後に入力欄が空に戻り、フォーカスが維持される = キーボードを閉じず連続入力できる。
      expect(textField.controller!.text, isEmpty);
      expect(textField.focusNode!.hasFocus, isTrue);
      // 再タップせずそのまま 2 件目を確定できる。
      await tester.enterText(find.byType(TextField), '卵\n');
      await tester.pump();
      expect(add.calls.map((c) => c.message).toList(), ['牛乳', '卵']);
    });

    testWidgets('既存行の Enter 確定は update し、入力行が無ければ末尾 (nextOrder) に空の入力行を追加する',
        (tester) async {
      final add = _RecordingAddShoppingListItem();
      final update = _RecordingUpdateShoppingListItem();
      await _pump(tester, _item(id: 'filled', message: '牛乳'), extraOverrides: [
        addShoppingListItemProvider(groupID: mockGroupID)
            .overrideWith((ref) => add),
        updateShoppingListItemProvider(groupID: mockGroupID)
            .overrideWith((ref) => update),
      ]);
      await tester.enterText(find.byType(TextField), '牛乳 2本\n');
      await tester.pump();
      expect(update.calls.single.message, '牛乳 2本');
      // shoppingListItems に空行が無いので、末尾に空の入力行が新規作成される。
      expect(add.calls.single.message, isEmpty);
      expect(add.calls.single.order, 1);
    });
  });

  group('「カテゴリ +」ボタン (AddCategoryChip)', () {
    testWidgets('showAddCategoryButton: true でカテゴリ追加チップを表示する', (tester) async {
      await _pump(
        tester,
        _item(id: 'uncategorized', message: '牛乳'),
        showAddCategoryButton: true,
      );
      expect(find.byType(AddCategoryChip), findsOneWidget);
    });

    testWidgets('showAddCategoryButton: false ではチップを表示しない', (tester) async {
      await _pump(tester, _item(id: 'categorized', message: '牛乳'));
      expect(find.byType(AddCategoryChip), findsNothing);
    });

    testWidgets('チップは行末の詳細アイコン (more_horiz) より左に置く', (tester) async {
      await _pump(
        tester,
        _item(id: 'uncategorized', message: '牛乳'),
        showAddCategoryButton: true,
      );
      expect(
        tester.getCenter(find.byType(AddCategoryChip)).dx,
        lessThan(tester.getCenter(find.byIcon(Icons.more_horiz)).dx),
      );
    });
  });

  group('フォーカス喪失時の空行削除', () {
    testWidgets('空のままフォーカスが外れた行は物理削除される', (tester) async {
      final database = _RecordingGroupDatabase();
      await _pump(tester, _item(id: 'input', message: ''), extraOverrides: [
        groupDatabaseProvider(groupID: mockGroupID)
            .overrideWith((ref) => database),
      ]);
      // 空行 (入力行) は postFrame で自動フォーカスされる。
      final focusNode =
          tester.widget<TextField>(find.byType(TextField)).focusNode!;
      expect(focusNode.hasFocus, isTrue);
      focusNode.unfocus();
      await tester.pump();
      expect(database.deletedItemIDs, ['input']);
    });

    testWidgets('入力途中テキストはフォーカス喪失で確定保存され、行は削除されない', (tester) async {
      final database = _RecordingGroupDatabase();
      final update = _RecordingUpdateShoppingListItem();
      await _pump(tester, _item(id: 'input', message: ''), extraOverrides: [
        groupDatabaseProvider(groupID: mockGroupID)
            .overrideWith((ref) => database),
        updateShoppingListItemProvider(groupID: mockGroupID)
            .overrideWith((ref) => update),
      ]);
      // 改行を含めない = Enter 未確定の入力途中テキスト。
      await tester.enterText(find.byType(TextField), '牛乳');
      tester.widget<TextField>(find.byType(TextField)).focusNode!.unfocus();
      await tester.pump();
      expect(update.calls.single.message, '牛乳');
      expect(database.deletedItemIDs, isEmpty);
    });

    testWidgets('内容が変わっていない非空行のフォーカス喪失では削除も更新もしない', (tester) async {
      final database = _RecordingGroupDatabase();
      final update = _RecordingUpdateShoppingListItem();
      await _pump(tester, _item(id: 'filled', message: '牛乳'), extraOverrides: [
        groupDatabaseProvider(groupID: mockGroupID)
            .overrideWith((ref) => database),
        updateShoppingListItemProvider(groupID: mockGroupID)
            .overrideWith((ref) => update),
      ]);
      await tester.showKeyboard(find.byType(TextField));
      await tester.pump();
      tester.widget<TextField>(find.byType(TextField)).focusNode!.unfocus();
      await tester.pump();
      expect(update.calls, isEmpty);
      expect(database.deletedItemIDs, isEmpty);
    });
  });
}
