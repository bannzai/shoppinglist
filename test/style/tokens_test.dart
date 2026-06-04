import 'package:flutter_test/flutter_test.dart';
import 'package:shoppinglist/style/tokens.dart';

void main() {
  /// 背景の奥行き（paper < surface < surface2 < card）を明度で保証する。
  /// この順序が崩れると面境界が消え視認性が落ちるため不変条件として固定する（ADR 0018）。
  void expectDepthOrder(AppNeutralColors neutral) {
    expect(neutral.paper.computeLuminance(),
        lessThan(neutral.surface.computeLuminance()));
    expect(neutral.surface.computeLuminance(),
        lessThan(neutral.surface2.computeLuminance()));
    expect(neutral.surface2.computeLuminance(),
        lessThan(neutral.card.computeLuminance()));
  }

  group('AppNeutralColors 背景の明度順', () {
    test('light: paper < surface < surface2 < card', () {
      expectDepthOrder(AppNeutralColors.light);
    });

    test('dark: paper < surface < surface2 < card', () {
      expectDepthOrder(AppNeutralColors.dark);
    });
  });
}
