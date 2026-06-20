import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoppinglist/components/primitives/app_pill.dart';
import 'package:shoppinglist/features/group_create/page.dart';
import 'package:shoppinglist/features/previews/mock/mock_provider_overrides.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';

Future<void> _pumpPage(WidgetTester tester) async {
  // GroupCreatePage は Column 直置きで、デフォルトの 800x600 テスト画面では
  // 縦方向にわずかにオーバーフローするため、十分な高さの画面を設定する。
  tester.view.physicalSize = const Size(1080, 1920);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  // ignore: invalid_use_of_visible_for_testing_member
  SharedPreferences.setMockInitialValues({});
  final sharedPreferences = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: previewProviderOverrides(sharedPreferences: sharedPreferences),
      child: MaterialApp(
        theme: buildAppTheme(accent: AccentPreset.shu),
        home: const GroupCreatePage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// 「作成する」AppPill を取得する。作成中は label が「作成中...」に変わる。
AppPill _createButton(WidgetTester tester) => tester
    .widgetList<AppPill>(find.byType(AppPill))
    .firstWhere((p) => p.label == '作成する' || p.label == '作成中...');

void main() {
  testWidgets('グループ名が空のとき「作成する」ボタンは無効 (Issue #432)', (tester) async {
    await _pumpPage(tester);
    expect(_createButton(tester).onPressed, isNull);
  });

  testWidgets('グループ名を入力すると「作成する」ボタンが有効になる (Issue #432)', (tester) async {
    await _pumpPage(tester);
    await tester.enterText(find.byType(TextField), '家族');
    await tester.pump();
    expect(_createButton(tester).onPressed, isNotNull);
  });

  testWidgets('空白のみの入力では「作成する」ボタンは無効のまま (Issue #432)', (tester) async {
    await _pumpPage(tester);
    await tester.enterText(find.byType(TextField), '   ');
    await tester.pump();
    expect(_createButton(tester).onPressed, isNull);
  });
}
