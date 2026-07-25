import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoppinglist/utils/development/debug.dart';

/// [body] 実行中の print 出力を捕捉して返す。
/// printWrapped は debugPrintSynchronously (内部で print) を使うため、
/// Zone の print ハンドラ差し替えで出力内容を検証できる。
List<String> capturePrintLines(void Function() body) {
  final lines = <String>[];
  runZoned(
    body,
    zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, line) => lines.add(line),
    ),
  );
  return lines;
}

void main() {
  test('overrideDebugPrint で debugPrint が printWrapped に差し替わる', () {
    final originalDebugPrint = debugPrint;
    addTearDown(() => debugPrint = originalDebugPrint);

    overrideDebugPrint();

    expect(debugPrint, printWrapped);
  });

  // 以下の出力検証は flutter test が debug モード (kDebugMode == true) で走る前提。
  // release での無出力 (printWrapped 内の kDebugMode ガード) はテスト環境では
  // 検証できないため、ガードの存在自体は実装コードを SSOT とする。
  test('printWrapped は [SL:DEBUG] プレフィックス付きで 800 文字ごとに分割出力する', () {
    expect(capturePrintLines(() => printWrapped('a' * 1000)), [
      '[SL:DEBUG] ${'a' * 800}',
      '[SL:DEBUG] ${'a' * 200}',
    ]);
  });

  test('printWrapped は null メッセージを "null" として出力する', () {
    expect(capturePrintLines(() => printWrapped(null)), ['null']);
  });
}
