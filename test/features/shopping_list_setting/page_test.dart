import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoppinglist/components/primitives/app_cell.dart';
import 'package:shoppinglist/components/primitives/app_pill.dart';
import 'package:shoppinglist/components/primitives/app_section_label.dart';
import 'package:shoppinglist/features/group_category/page.dart';
import 'package:shoppinglist/features/previews/mock/mock_data.dart';
import 'package:shoppinglist/features/previews/mock/mock_provider_overrides.dart';
import 'package:shoppinglist/features/shopping_list_setting/invitation_code_dialog.dart';
import 'package:shoppinglist/features/shopping_list_setting/page.dart';
import 'package:shoppinglist/provider/app_provider_container.dart';
import 'package:shoppinglist/provider/group.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';

Future<void> _pumpPage(
  WidgetTester tester, {
  List<Override> extraOverrides = const [],
}) async {
  // ignore: invalid_use_of_visible_for_testing_member
  SharedPreferences.setMockInitialValues({});
  final sharedPreferences = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...previewProviderOverrides(sharedPreferences: sharedPreferences),
        ...extraOverrides,
      ],
      child: MaterialApp(
        theme: buildAppTheme(
          accent: AccentPreset.shu,
        ),
        home: ShoppingListSettingPage(
          groupID: mockGroupID,
          shoppingListID: mockShoppingListID,
          shoppingList: mockShoppingLists().first,
          onDelete: () {},
        ),
      ),
    ),
  );
  // 非同期 provider 解決待ち
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('design v2 セクション label が UPPERCASE で表示される', (tester) async {
    await _pumpPage(tester);

    // AppSectionLabel は `toUpperCase()` で大文字化されるため、検証側も大文字で照合する。
    final labels = tester
        .widgetList<AppSectionLabel>(find.byType(AppSectionLabel))
        .map((w) => w.text)
        .toList();
    expect(
        labels,
        containsAll(<String>[
          'リスト名',
          '買い物する場所',
          'カテゴリ',
          '保存期間',
          '通知',
          '共有',
          'リストの操作',
        ]));

    expect(find.text('リスト名'.toUpperCase()), findsOneWidget);
    expect(find.text('共有'.toUpperCase()), findsOneWidget);
    expect(find.text('リストの操作'.toUpperCase()), findsOneWidget);
  });

  testWidgets('買い物する場所 AppCell に detail「変更」が表示される', (tester) async {
    await _pumpPage(tester);
    final placeCell = tester
        .widgetList<AppCell>(find.byType(AppCell))
        .where((c) => c.icon == Icons.place_outlined)
        .firstOrNull;
    expect(placeCell, isNotNull, reason: '買い物する場所 Cell が AppCell として描画されているべき');
    expect(placeCell!.detail, '変更');
    expect(find.text('変更'), findsOneWidget);
  });

  testWidgets('保存期間に「アップグレード」AppPill が表示される (非プレミアム時)', (tester) async {
    await _pumpPage(tester);
    final upgradePill = tester
        .widgetList<AppPill>(find.byType(AppPill))
        .where((p) => p.label == 'アップグレード')
        .firstOrNull;
    expect(upgradePill, isNotNull);
    expect(upgradePill!.variant, AppPillVariant.soft);
  });

  testWidgets('共有セクションに 2 AppCell (招待 / グループ設定) が表示される', (tester) async {
    await _pumpPage(tester);
    expect(find.text('グループに招待コードを送る'), findsOneWidget);
    expect(find.text('グループ設定'), findsOneWidget);
  });

  testWidgets('削除ボタンに「このリストを削除」と trash アイコンが表示される', (tester) async {
    await _pumpPage(tester);
    // 削除ボタンは AppPill ではなく Material+InkWell の inline 実装 (radius 14)。
    // SSOT: screens-list-settings.jsx L55-61 (dangerSoft 背景 + danger 文字)
    expect(find.text('このリストを削除'), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
  });

  testWidgets('カテゴリ Cell タップで GroupCategoryPage に遷移する', (tester) async {
    await _pumpPage(tester);
    final categoryCell = tester
        .widgetList<AppCell>(find.byType(AppCell))
        .where((c) => c.icon == Icons.category_outlined)
        .firstOrNull;
    expect(categoryCell, isNotNull, reason: 'カテゴリ Cell が AppCell として描画されているべき');

    await tester.tap(find.byWidget(categoryCell!));
    await tester.pumpAndSettle();

    expect(find.byType(GroupCategoryPage), findsOneWidget);
  });

  testWidgets('グループ名あり: 招待で招待コードダイアログが表示される (Issue #432)', (tester) async {
    await _pumpPage(tester);
    final inviteCell = tester
        .widgetList<AppCell>(find.byType(AppCell))
        .firstWhere((c) => c.icon == Icons.person_add_outlined);
    await tester.ensureVisible(find.byWidget(inviteCell));
    await tester.pumpAndSettle();
    await tester.tap(find.byWidget(inviteCell));
    // _NoOpCreateGroupInvitation の解決 → showGeneralDialog (transition 160ms)。
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(InvitationCodeDialog), findsOneWidget);
    // InvitationCodeDialog は Timer.periodic を持つため、閉じて dispose させ
    // pending timer を残さない。
    Navigator.of(tester.element(find.byType(InvitationCodeDialog))).pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
  });

  testWidgets('グループ名なし: 招待でダイアログが表示されない（ガード, Issue #432）', (tester) async {
    // 招待ガード時の showGlobalActionToast が参照する appProviderContainer を初期化する。
    final toastContainer = ProviderContainer();
    addTearDown(toastContainer.dispose);
    appProviderContainer = toastContainer;
    await _pumpPage(tester, extraOverrides: [
      groupProvider(groupID: mockGroupID).overrideWith(
          (ref) => Stream.value(mockGroup().copyWith(name: null))),
    ]);
    final inviteCell = tester
        .widgetList<AppCell>(find.byType(AppCell))
        .firstWhere((c) => c.icon == Icons.person_add_outlined);
    await tester.ensureVisible(find.byWidget(inviteCell));
    await tester.pumpAndSettle();
    await tester.tap(find.byWidget(inviteCell));
    await tester.pumpAndSettle();
    expect(find.byType(InvitationCodeDialog), findsNothing);
    // showGlobalActionToast の自動消滅タイマー (5秒) を消化し、pending timer を残さない。
    await tester.pump(const Duration(seconds: 5));
  });
}
