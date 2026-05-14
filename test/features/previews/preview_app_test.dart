import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/features/previews/preview_app.dart';
import 'package:shoppinglist/features/previews/previews_page.dart';
import 'package:shoppinglist/style/tokens.dart';

void main() {
  testWidgets('PreviewApp provides AppTokens', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: PreviewApp(),
      ),
    );

    final context = tester.element(find.byType(PreviewsPage));
    final tokens = Theme.of(context).extension<AppTokens>();

    expect(tokens, isNotNull);
    expect(tokens!.brightness, Brightness.light);
    expect(tokens.accentPreset, AccentPreset.shu);
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
}
