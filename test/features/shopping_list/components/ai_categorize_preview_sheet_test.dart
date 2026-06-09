import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoppinglist/features/shopping_list/components/ai_categorize_preview_sheet.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';

void main() {
  // showAICategorizePreviewSheet を開くためのテスト用ホストを pump する。
  // 戻り値（登録対象の候補）を captured に保持する。
  Future<List<AICategorizeCandidate>?> pumpSheet(
    WidgetTester tester, {
    required List<({String name, String categoryName})> categorized,
    required List<String> existingCategoryNames,
  }) async {
    List<AICategorizeCandidate>? captured;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(accent: AccentPreset.shu),
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () async {
                  captured = await showAICategorizePreviewSheet(
                    context: context,
                    categorized: categorized,
                    existingCategoryNames: existingCategoryNames,
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return captured;
  }

  testWidgets('候補をカテゴリ別に表示しデフォルト全選択する', (tester) async {
    await pumpSheet(
      tester,
      categorized: const [
        (name: 'にんじん', categoryName: '野菜'),
        (name: '玉ねぎ', categoryName: '野菜'),
        (name: '鶏もも肉', categoryName: '肉'),
      ],
      existingCategoryNames: const ['野菜'],
    );

    // アイテムが全件表示される
    expect(find.text('にんじん'), findsOneWidget);
    expect(find.text('玉ねぎ'), findsOneWidget);
    expect(find.text('鶏もも肉', skipOffstage: false), findsWidgets);
    // チェックボックス3件、デフォルト全選択で "3 件を登録"
    expect(find.byType(Checkbox), findsNWidgets(3));
    expect(find.text('3 件を登録'), findsOneWidget);
  });

  testWidgets('除外トグルで登録件数が減る', (tester) async {
    await pumpSheet(
      tester,
      categorized: const [
        (name: 'にんじん', categoryName: '野菜'),
        (name: '牛乳', categoryName: '乳製品'),
      ],
      existingCategoryNames: const [],
    );

    expect(find.text('2 件を登録'), findsOneWidget);
    // 先頭のチェックボックスを外す
    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();
    expect(find.text('1 件を登録'), findsOneWidget);
  });

  testWidgets('「N 件を登録」で included な候補が返る', (tester) async {
    List<AICategorizeCandidate>? captured;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(accent: AccentPreset.shu),
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () async {
                  captured = await showAICategorizePreviewSheet(
                    context: context,
                    categorized: const [
                      (name: 'にんじん', categoryName: '野菜'),
                    ],
                    existingCategoryNames: const [],
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('1 件を登録'));
    await tester.pumpAndSettle();

    expect(captured, isNotNull);
    final included = captured!.where((c) => c.included).toList();
    expect(included.length, 1);
    expect(included.first.itemName, 'にんじん');
    expect(included.first.categoryName, '野菜');
  });

  testWidgets('キャンセルでシートが閉じる', (tester) async {
    await pumpSheet(
      tester,
      categorized: const [
        (name: 'にんじん', categoryName: '野菜'),
      ],
      existingCategoryNames: const [],
    );
    expect(find.text('1 件を登録'), findsOneWidget);

    await tester.tap(find.text('キャンセル'));
    await tester.pumpAndSettle();
    // シートが閉じている
    expect(find.text('1 件を登録'), findsNothing);
  });
}
