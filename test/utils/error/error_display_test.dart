import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoppinglist/l10n/l10n.dart';
import 'package:shoppinglist/utils/error/error_display.dart';

void main() {
  group('describeError', () {
    final stack = StackTrace.fromString('#0 fake.frame (file.dart:1)');
    // 期待値はハードコードせず、日本語ロケールの AppLocalizations から取る
    // (文言の SSOT は lib/l10n/app_ja.arb)。
    late AppLocalizations l10n;

    setUpAll(() async {
      l10n = await AppLocalizations.delegate.load(const Locale('ja'));
    });

    test('FirebaseException は本文から StackTrace を分離する', () {
      final error = FirebaseException(
        plugin: 'firebase_functions',
        code: 'internal',
        message: 'INTERNAL',
        stackTrace: stack,
      );
      // FirebaseException.toString() は本文末尾に StackTrace を連結する仕様。
      expect(error.toString(), contains('fake.frame'));

      final result = describeError(l10n, error);
      expect(result.title, l10n.errorTitleServerError);
      expect(result.message, '[firebase_functions/internal] INTERNAL');
      // 本文には StackTrace を含めない。
      expect(result.message, isNot(contains('fake.frame')));
      // StackTrace は分離して保持する。
      expect(result.stackTrace, stack);
    });

    test('特定のエラーコードにタイトルを付ける', () {
      expect(
        describeError(
          l10n,
          FirebaseException(
            plugin: 'firebase_functions',
            code: 'unauthenticated',
            message: 'x',
          ),
        ).title,
        l10n.errorTitleSignInRequired,
      );
      expect(
        describeError(
          l10n,
          FirebaseException(
            plugin: 'firebase_functions',
            code: 'permission-denied',
            message: 'x',
          ),
        ).title,
        l10n.errorTitlePermissionDenied,
      );
    });

    test('未知のコードは title=null・本文は [plugin/code] message', () {
      final result = describeError(
        l10n,
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
      final result = describeError(l10n, Exception('boom'), stack);
      expect(result.title, isNull);
      expect(result.message, 'Exception: boom');
      expect(result.stackTrace, stack);
    });

    // アカウントリンク（issue #548）で起きる firebase_auth の 3 コードは、
    // 状況の分かるタイトルを付ける（本文はそのまま）。
    test('アカウントリンク時の firebase_auth コードにタイトルを付ける', () {
      expect(
        describeError(
          l10n,
          FirebaseException(
            plugin: 'firebase_auth',
            code: 'provider-already-linked',
            message: 'x',
          ),
        ).title,
        l10n.errorTitleProviderAlreadyLinked,
      );
      expect(
        describeError(
          l10n,
          FirebaseException(
            plugin: 'firebase_auth',
            code: 'credential-already-in-use',
            message: 'x',
          ),
        ).title,
        l10n.errorTitleCredentialAlreadyInUse,
      );
      expect(
        describeError(
          l10n,
          FirebaseException(
            plugin: 'firebase_auth',
            code: 'email-already-in-use',
            message: 'x',
          ),
        ).title,
        l10n.errorTitleEmailAlreadyInUse,
      );
    });
  });
}
