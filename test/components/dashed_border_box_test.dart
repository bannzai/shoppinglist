import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoppinglist/components/dashed_border_box.dart';

void main() {
  testWidgets('DashedBorderBox: 子と CustomPaint を描画する', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Center(
          child: DashedBorderBox(
            color: Color(0xFFE0D5BC),
            child: SizedBox(
              width: 200,
              height: 80,
              child: Center(child: Text('X9KP-2H4M')),
            ),
          ),
        ),
      ),
    ));
    expect(find.text('X9KP-2H4M'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(DashedBorderBox),
        matching: find.byType(CustomPaint),
      ),
      findsOneWidget,
    );
  });

  testWidgets('DashedBorderBox: 既定値 (radius 14 / stroke 1 / pattern [4,3])',
      (tester) async {
    const box = DashedBorderBox(
      color: Color(0xFFE0D5BC),
      child: SizedBox.shrink(),
    );
    expect(box.borderRadius, 14);
    expect(box.strokeWidth, 1);
    expect(box.dashPattern, const [4, 3]);
  });
}
