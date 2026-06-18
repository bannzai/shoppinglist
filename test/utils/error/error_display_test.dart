import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoppinglist/utils/error/error_display.dart';

void main() {
  group('describeError', () {
    final stack = StackTrace.fromString('#0 fake.frame (file.dart:1)');

    test('FirebaseException は本文から StackTrace を分離する', () {
      final error = FirebaseException(
        plugin: 'firebase_functions',
        code: 'internal',
        message: 'INTERNAL',
        stackTrace: stack,
      );
      // FirebaseException.toString() は本文末尾に StackTrace を連結する仕様。
      expect(error.toString(), contains('fake.frame'));

      final result = describeError(error);
      expect(result.title, 'サーバーでエラーが発生しました');
      expect(result.message, '[firebase_functions/internal] INTERNAL');
      // 本文には StackTrace を含めない。
      expect(result.message, isNot(contains('fake.frame')));
      // StackTrace は分離して保持する。
      expect(result.stackTrace, stack);
    });

    test('特定のエラーコードにタイトルを付ける', () {
      expect(
        describeError(
          FirebaseException(
            plugin: 'firebase_functions',
            code: 'unauthenticated',
            message: 'x',
          ),
        ).title,
        'ログインが必要です',
      );
      expect(
        describeError(
          FirebaseException(
            plugin: 'firebase_functions',
            code: 'permission-denied',
            message: 'x',
          ),
        ).title,
        '操作する権限がありません',
      );
    });

    test('未知のコードは title=null・本文は [plugin/code] message', () {
      final result = describeError(
        FirebaseException(
          plugin: 'cloud_firestore',
          code: 'aborted',
          message: 'やり直してください',
        ),
      );
      expect(result.title, isNull);
      expect(result.message, '[cloud_firestore/aborted] やり直してください');
    });

    test('一般のエラーは toString をそのまま本文にし、引数の StackTrace を返す', () {
      final result = describeError(Exception('boom'), stack);
      expect(result.title, isNull);
      expect(result.message, 'Exception: boom');
      expect(result.stackTrace, stack);
    });
  });
}
