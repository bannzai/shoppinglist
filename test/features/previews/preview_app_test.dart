import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/features/previews/preview_app.dart';
import 'package:shoppinglist/features/previews/previews_page.dart';
import 'package:shoppinglist/style/tokens.dart';

void main() {
  testWidgets('PreviewApp provides AppThemeExtension', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: PreviewApp(),
      ),
    );

    final context = tester.element(find.byType(PreviewsPage));
    final tokens = Theme.of(context).extension<AppThemeExtension>();

    expect(tokens, isNotNull);
    expect(tokens!.accentPreset, AccentPreset.shu);
  });

  testWidgets('PreviewsPage lists onboarding and auth previews',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: PreviewApp(),
      ),
    );

    expect(find.text('OnboardingPage'), findsOneWidget);
    expect(find.text('AuthPage'), findsOneWidget);
  });

  testWidgets('PreviewsPage lists 3 new modal/dialog previews (PR-9 拡張)',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: PreviewApp(),
      ),
    );

    // ListView の末尾 3 entries を scrollUntilVisible で順に確認する
    final listFinder = find.byType(ListView);
    for (final entry in const [
      'AIReviewSheet',
      'SignOutDialog',
      'GroupInvitationVerifying',
    ]) {
      await tester.scrollUntilVisible(
        find.text(entry),
        200,
        scrollable: find.descendant(
          of: listFinder,
          matching: find.byType(Scrollable),
        ),
      );
      expect(find.text(entry), findsOneWidget);
    }
  });
}
