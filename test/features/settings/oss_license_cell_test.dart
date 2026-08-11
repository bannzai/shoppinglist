import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoppinglist/features/settings/components/oss_license_cell.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';

/// テーマ付きで OssLicenseCell を表示するヘルパー。
/// showLicensePage の遷移先を検証するため MaterialApp（Navigator）配下に置く。
Widget _wrap() => MaterialApp(
  theme: buildAppTheme(accent: AccentPreset.shu),
  home: const Scaffold(body: OssLicenseCell()),
);

void main() {
  testWidgets('タップすると Flutter 標準のライセンス一覧画面へ遷移する', (tester) async {
    await tester.pumpWidget(_wrap());

    expect(find.byType(LicensePage), findsNothing);

    await tester.tap(find.byType(OssLicenseCell));
    await tester.pumpAndSettle();

    expect(find.byType(LicensePage), findsOneWidget);
  });
}
