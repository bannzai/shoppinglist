import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoppinglist/components/frame/app_bottom_tab_bar.dart';
import 'package:shoppinglist/components/frame/app_checkbox.dart';
import 'package:shoppinglist/components/frame/app_chip.dart';
import 'package:shoppinglist/components/frame/app_large_app_bar.dart';
import 'package:shoppinglist/components/frame/app_pill.dart';
import 'package:shoppinglist/components/frame/app_round_button.dart';
import 'package:shoppinglist/components/frame/app_section_card.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';

/// テーマを適用した最小 MaterialApp で `child` を表示するヘルパー。
Widget _wrap(Widget child) => MaterialApp(
      theme: buildAppTheme(
        brightness: Brightness.light,
        accent: AccentPreset.shu,
      ),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  testWidgets('AppPill: 各 variant が落ちずに描画される', (tester) async {
    await tester.pumpWidget(_wrap(Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppPill(label: 'neutral', onPressed: () {}),
        AppPill(
            label: 'accent', onPressed: () {}, variant: AppPillVariant.accent),
        AppPill(label: 'soft', onPressed: () {}, variant: AppPillVariant.soft),
        AppPill(
            label: 'ghost', onPressed: () {}, variant: AppPillVariant.ghost),
        AppPill(
            label: 'danger', onPressed: () {}, variant: AppPillVariant.danger),
        const AppPill(label: 'disabled', onPressed: null),
      ],
    )));
    expect(find.text('neutral'), findsOneWidget);
    expect(find.text('disabled'), findsOneWidget);
  });

  testWidgets('AppPill: large=true で高さ50', (tester) async {
    await tester.pumpWidget(
      _wrap(AppPill(label: 'CTA', onPressed: () {}, large: true)),
    );
    final box = tester.getSize(find.text('CTA'));
    expect(box.height, lessThanOrEqualTo(50));
  });

  testWidgets('AppRoundButton: タップで onPressed が発火', (tester) async {
    var tapped = 0;
    await tester.pumpWidget(_wrap(AppRoundButton(
      icon: Icons.close,
      onPressed: () => tapped++,
    )));
    await tester.tap(find.byIcon(Icons.close));
    expect(tapped, 1);
  });

  testWidgets('AppCheckbox: checked=false でアイコン非表示、true で表示', (tester) async {
    await tester.pumpWidget(_wrap(
      const AppCheckbox(checked: false, onChanged: null),
    ));
    expect(find.byIcon(Icons.check), findsNothing);

    await tester.pumpWidget(_wrap(
      const AppCheckbox(checked: true, onChanged: null),
    ));
    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('AppCheckbox: タップで onChanged(!checked) が発火', (tester) async {
    bool? received;
    await tester.pumpWidget(_wrap(AppCheckbox(
      checked: false,
      onChanged: (v) => received = v,
    )));
    await tester.tap(find.byType(AppCheckbox), warnIfMissed: false);
    expect(received, true);
  });

  testWidgets('AppChip: active のときラベルが太字 600', (tester) async {
    await tester.pumpWidget(_wrap(Column(
      children: [
        AppChip(label: 'inactive', onTap: () {}),
        AppChip(label: 'active', active: true, onTap: () {}),
      ],
    )));
    expect(find.text('inactive'), findsOneWidget);
    expect(find.text('active'), findsOneWidget);
  });

  testWidgets('AppLargeAppBar: subtitle なしで preferredSize 110', (tester) async {
    const bar = AppLargeAppBar(title: 'タイトル');
    expect(bar.preferredSize.height, 110);
  });

  testWidgets('AppLargeAppBar: subtitle ありで preferredSize 130', (tester) async {
    const bar = AppLargeAppBar(title: 'タイトル', subtitle: '補足');
    expect(bar.preferredSize.height, 130);
  });

  testWidgets('AppLargeAppBar: title と subtitle が描画される', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildAppTheme(
        brightness: Brightness.light,
        accent: AccentPreset.shu,
      ),
      home: const Scaffold(
        appBar: AppLargeAppBar(title: '設定', subtitle: 'アプリ全般の設定'),
      ),
    ));
    expect(find.text('設定'), findsOneWidget);
    expect(find.text('アプリ全般の設定'), findsOneWidget);
  });

  testWidgets('AppBottomTabBar: 2 タブ表示・タップで onChanged 発火', (tester) async {
    AppTab? selected;
    await tester.pumpWidget(MaterialApp(
      theme: buildAppTheme(
        brightness: Brightness.light,
        accent: AccentPreset.shu,
      ),
      home: Scaffold(
        bottomNavigationBar: AppBottomTabBar(
          active: AppTab.list,
          onChanged: (t) => selected = t,
        ),
      ),
    ));
    expect(find.text('買い物リスト'), findsOneWidget);
    expect(find.text('設定'), findsOneWidget);
    await tester.tap(find.text('設定'));
    expect(selected, AppTab.settings);
  });

  testWidgets('AppSectionCard: title と children が表示される', (tester) async {
    await tester.pumpWidget(_wrap(const AppSectionCard(
      title: 'プロフィール',
      children: [
        ListTile(title: Text('表示名')),
        ListTile(title: Text('メール')),
      ],
    )));
    expect(find.text('プロフィール'), findsOneWidget);
    expect(find.text('表示名'), findsOneWidget);
    expect(find.text('メール'), findsOneWidget);
  });
}
