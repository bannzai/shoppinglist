import 'package:flutter/foundation.dart';

void overrideDebugPrint() {
  debugPrint = printWrapped;
}

void printWrapped(String? message, {int? wrapWidth}) {
  if (kDebugMode) {
    if (message == null) {
      debugPrintSynchronously('null');
    } else {
      final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
      pattern.allMatches(message).forEach(
          (match) => debugPrintSynchronously('[SL:DEBUG] ${match.group(0)}'));
    }
  }
}
