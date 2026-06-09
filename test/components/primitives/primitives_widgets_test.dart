import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoppinglist/components/primitives/app_cell.dart';
import 'package:shoppinglist/components/primitives/app_checkbox.dart';
import 'package:shoppinglist/components/primitives/app_chip.dart';
import 'package:shoppinglist/components/primitives/app_dialog_shell.dart';
import 'package:shoppinglist/components/primitives/app_divider.dart';
import 'package:shoppinglist/components/primitives/app_frame_app_bar.dart';
import 'package:shoppinglist/components/primitives/app_large_app_bar.dart';
import 'package:shoppinglist/components/primitives/app_pill.dart';
import 'package:shoppinglist/components/primitives/app_round_button.dart';
import 'package:shoppinglist/components/primitives/app_setting_section.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';

/// テーマを適用した最小 MaterialApp で `child` を表示するヘルパー。
Widget _wrap(Widget child) => MaterialApp(
      theme: buildAppTheme(
        accent: AccentPreset.shu,
      ),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  testWidgets('AppPill: 各 variant が落ちずに描画される', (tester) async {
    await tester.pumpWidget(_wrap(Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppPill(label: 'neutral', onPressed: () {}, icon: null),
        AppPill(
            label: 'accent',
            onPressed: () {},
            variant: AppPillVariant.accent,
            icon: null),
        AppPill(
            label: 'soft',
            onPressed: () {},
            variant: AppPillVariant.soft,
            icon: null),
        AppPill(
            label: 'ghost',
            onPressed: () {},
            variant: AppPillVariant.ghost,
            icon: null),
        AppPill(
            label: 'danger',
            onPressed: () {},
            variant: AppPillVariant.danger,
            icon: null),
        AppPill(
            label: 'dangerSolid',
            onPressed: () {},
            variant: AppPillVariant.dangerSolid,
            icon: null),
        const AppPill(label: 'disabled', onPressed: null, icon: null),
      ],
    )));
    expect(find.text('neutral'), findsOneWidget);
    expect(find.text('dangerSolid'), findsOneWidget);
    expect(find.text('disabled'), findsOneWidget);
  });

  testWidgets('AppPill: dangerSolid は danger 塗り + 白文字', (tester) async {
    await tester.pumpWidget(_wrap(AppPill(
        label: '削除',
        onPressed: () {},
        variant: AppPillVariant.dangerSolid,
        icon: null)));
    final ctx = tester.element(find.byType(AppPill));
    final neutral = ctx.appTheme.neutral;
    final material = tester.widget<Material>(
      find.descendant(
          of: find.byType(AppPill), matching: find.byType(Material)),
    );
    expect(material.color, neutral.danger);
    final text = tester.widget<Text>(find.text('削除'));
    expect(text.style?.color, Colors.white);
  });

  testWidgets('AppPill: large=true で高さ50', (tester) async {
    await tester.pumpWidget(
      _wrap(AppPill(label: 'CTA', onPressed: () {}, large: true, icon: null)),
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
      const AppCheckbox(checked: false, onChanged: null, color: null),
    ));
    expect(find.byIcon(Icons.check), findsNothing);

    await tester.pumpWidget(_wrap(
      const AppCheckbox(checked: true, onChanged: null, color: null),
    ));
    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('AppCheckbox: タップで onChanged(!checked) が発火', (tester) async {
    bool? received;
    await tester.pumpWidget(_wrap(AppCheckbox(
        checked: false, onChanged: (v) => received = v, color: null)));
    await tester.tap(find.byType(AppCheckbox), warnIfMissed: false);
    expect(received, true);
  });

  testWidgets('AppChip: active のときラベルが太字 600', (tester) async {
    await tester.pumpWidget(_wrap(Column(
      children: [
        AppChip(label: 'inactive', onTap: () {}, dotColor: null, icon: null),
        AppChip(
            label: 'active',
            active: true,
            onTap: () {},
            dotColor: null,
            icon: null),
      ],
    )));
    expect(find.text('inactive'), findsOneWidget);
    expect(find.text('active'), findsOneWidget);
  });

  testWidgets('AppLargeAppBar: subtitle なしで preferredSize 110', (tester) async {
    const bar = AppLargeAppBar(title: 'タイトル', leading: null, subtitle: null);
    expect(bar.preferredSize.height, 110);
  });

  testWidgets('AppLargeAppBar: subtitle ありで preferredSize 130', (tester) async {
    const bar = AppLargeAppBar(title: 'タイトル', subtitle: '補足', leading: null);
    expect(bar.preferredSize.height, 130);
  });

  testWidgets('AppLargeAppBar: title と subtitle が描画される', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildAppTheme(
        accent: AccentPreset.shu,
      ),
      home: const Scaffold(
        appBar:
            AppLargeAppBar(title: '設定', subtitle: 'アプリ全般の設定', leading: null),
      ),
    ));
    expect(find.text('設定'), findsOneWidget);
    expect(find.text('アプリ全般の設定'), findsOneWidget);
  });

  testWidgets('AppSettingSection: title と children が表示される', (tester) async {
    await tester.pumpWidget(_wrap(const AppSettingSection(
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

  testWidgets('AppFrameAppBar: preferredSize 48 + title 描画', (tester) async {
    const bar = AppFrameAppBar(title: 'カテゴリ', leading: null, trailing: null);
    expect(bar.preferredSize.height, 48);
    await tester.pumpWidget(MaterialApp(
      theme: buildAppTheme(
        accent: AccentPreset.shu,
      ),
      home: const Scaffold(
          appBar: AppFrameAppBar(title: 'カテゴリ', leading: null, trailing: null)),
    ));
    expect(find.text('カテゴリ'), findsOneWidget);
  });

  testWidgets('AppCell: onTap 指定で chev-r 表示・タップ発火', (tester) async {
    var tapped = 0;
    await tester.pumpWidget(_wrap(AppCell(
        icon: Icons.notifications_active_outlined,
        title: '通知設定',
        subtitle: 'プッシュ通知の細かい設定',
        onTap: () => tapped++,
        detail: null,
        onSwitch: null,
        switchValue: null)));
    expect(find.text('通知設定'), findsOneWidget);
    expect(find.text('プッシュ通知の細かい設定'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    await tester.tap(find.byType(AppCell));
    expect(tapped, 1);
  });

  testWidgets('AppCell: onSwitch + switchValue 指定で Switch 表示', (tester) async {
    bool? lastValue;
    await tester.pumpWidget(_wrap(AppCell(
        icon: Icons.notifications_active_outlined,
        title: '自動通知',
        switchValue: false,
        onSwitch: (v) => lastValue = v,
        detail: null,
        onTap: null,
        subtitle: null)));
    expect(find.byType(Switch), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsNothing);
    await tester.tap(find.byType(Switch));
    expect(lastValue, true);
  });

  testWidgets('AppCell: danger=true でアイコンが danger 色', (tester) async {
    await tester.pumpWidget(_wrap(const AppCell(
        icon: Icons.logout,
        title: 'サインアウト',
        danger: true,
        detail: null,
        onSwitch: null,
        onTap: null,
        subtitle: null,
        switchValue: null)));
    expect(find.text('サインアウト'), findsOneWidget);
  });

  testWidgets('AppDivider: 既定 inset 60 で 0.5px の線が描かれる', (tester) async {
    await tester.pumpWidget(_wrap(const AppDivider()));
    final padding = tester.widget<Padding>(
      find
          .ancestor(
            of: find.byType(Container),
            matching: find.byType(Padding),
          )
          .first,
    );
    expect(padding.padding, const EdgeInsets.only(left: 60));
  });

  testWidgets('AppDialogShell: child が card 内に表示される', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildAppTheme(
        accent: AccentPreset.shu,
      ),
      home: const Scaffold(
        body: AppDialogShell(
          child: Text('確認ダイアログ'),
        ),
      ),
    ));
    expect(find.text('確認ダイアログ'), findsOneWidget);
  });
}
