import 'package:flutter/foundation.dart';

/// debugPrint を [printWrapped] に差し替える。
///
/// Flutter 標準の debugPrint (debugPrintThrottled) は release ビルドでも出力される
/// (SDK の print.dart に明記) ため、ビルドモードで分岐せず必ず呼び、kDebugMode
/// ガード付きの実装に差し替えることで全 debugPrint を debug 時のみの出力にする。
/// debugPrint はグローバル変数で isolate ごとに独立しているため、
/// main() と別 entry-point の isolate でも呼ぶ必要がある。
void overrideDebugPrint() {
  debugPrint = printWrapped;
}

/// kDebugMode でのみ `[SL:DEBUG]` プレフィックス付きで出力する debugPrint 実装。
void printWrapped(String? message, {int? wrapWidth}) {
  if (kDebugMode) {
    if (message == null) {
      debugPrintSynchronously('null');
    } else {
      final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
      pattern
          .allMatches(message)
          .forEach(
            (match) => debugPrintSynchronously('[SL:DEBUG] ${match.group(0)}'),
          );
    }
  }
}
