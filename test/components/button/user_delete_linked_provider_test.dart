import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/button/user_delete.dart';
import 'package:shoppinglist/features/resolver/auth.dart';

// Riverpod 3 は scoped な provider (firebaseUserChangesProvider) を watch する provider が
// dependencies に列挙していないと、読んだ時点で例外を投げる。設定画面のアカウント削除ボタンが
// 読む連携状態の provider がこの検査を通ることを確かめる。
void main() {
  group('連携状態の provider は firebaseUserChanges の override 下で読める', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          firebaseUserChangesProvider.overrideWith(
            (ref) => Stream<User?>.value(null),
          ),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('isAppleLinkedProvider は未サインイン時に false', () {
      expect(container.read(isAppleLinkedProvider), isFalse);
    });

    test('isGoogleLinkedProvider は未サインイン時に false', () {
      expect(container.read(isGoogleLinkedProvider), isFalse);
    });
  });
}
