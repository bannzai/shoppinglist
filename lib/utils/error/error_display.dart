import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shoppinglist/utils/logger/error.dart';

/// エラーを表示用に分解した結果。
/// - [title]: 特定のエラーコードにだけ付ける見出し。該当しなければ null。
/// - [message]: ユーザーに見せる本文。規約どおり加工せず、StackTrace だけ分離したもの。
/// - [stackTrace]: ページ全体エラー表示用。トースト/スナックバー/アラートでは使わない。
typedef ErrorDisplay = ({
  String? title,
  String message,
  StackTrace? stackTrace,
});

/// 任意のエラーを表示用の (title, message, stackTrace) に分解する。
///
/// 本文(message)は加工しない（規約: e.toString() のプレフィックス除去等はしない）。
/// FirebaseException は toString() 末尾に `\n\n$stackTrace` を連結するため、
/// 連結前の `[plugin/code] message` のみを本文とし、StackTrace は分離して返す。
ErrorDisplay describeError(Object error, [StackTrace? stackTrace]) {
  if (error is FirebaseException) {
    return (
      title: _specialTitle(error),
      message: '[${error.plugin}/${error.code}] ${error.message}',
      stackTrace: stackTrace ?? error.stackTrace,
    );
  }
  return (title: null, message: error.toString(), stackTrace: stackTrace);
}

/// 特定のエラーコードにだけ、ユーザーに意味が伝わるタイトルを付ける。
/// 本文はそのまま表示し、タイトルだけを補う。該当しなければ null。
String? _specialTitle(FirebaseException error) {
  switch ('${error.plugin}/${error.code}') {
    case 'firebase_functions/internal':
      return 'サーバーでエラーが発生しました';
    case 'firebase_functions/unauthenticated':
      return 'ログインが必要です';
    case 'firebase_functions/permission-denied':
      return '操作する権限がありません';
    default:
      return null;
  }
}

/// エラーを debugPrint と Crashlytics に「そのまま」記録する。
/// 表示用の整形とは独立に、常に生のエラーと StackTrace を残す。
void logError(Object error, StackTrace? stackTrace) {
  debugPrint('Error: $error\n$stackTrace');
  // ログ記録自体が表示や描画を巻き込んで落ちないようにする。
  // 例: Firebase 未初期化のテスト環境では FirebaseCrashlytics.instance が
  // [core/no-app] を投げるため、握りつぶして debugPrint だけ残す。
  try {
    errorLogger.recordError(error, stackTrace);
  } catch (_) {}
}

/// エラーを SnackBar で通知する。本文・タイトルはそのまま、StackTrace は出さない。
/// debugPrint/Crashlytics には生のエラーを記録する。
/// 呼び出し側で `context.mounted` を確認してから呼ぶこと。
void showErrorSnackBar(
  BuildContext context,
  Object error, [
  StackTrace? stackTrace,
]) {
  logError(error, stackTrace);
  final display = describeError(error, stackTrace);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        display.title == null
            ? display.message
            : '${display.title}\n${display.message}',
      ),
    ),
  );
}
