import 'package:flutter_test/flutter_test.dart';
import 'package:shoppinglist/utils/invitation_code_validator.dart';

void main() {
  group('isValidInvitationCode', () {
    test('有効なコードでtrueを返す', () {
      expect(isValidInvitationCode('ABCD3456'), isTrue);
      expect(isValidInvitationCode('HJKMNPQR'), isTrue);
      expect(isValidInvitationCode('STVWXY78'), isTrue);
    });

    test('除外文字 I を含むコードでfalseを返す', () {
      expect(isValidInvitationCode('ABCDI456'), isFalse);
    });

    test('除外文字 L を含むコードでfalseを返す', () {
      expect(isValidInvitationCode('ABCDL456'), isFalse);
    });

    test('除外文字 O を含むコードでfalseを返す', () {
      expect(isValidInvitationCode('ABCDO456'), isFalse);
    });

    test('除外文字 U を含むコードでfalseを返す', () {
      expect(isValidInvitationCode('ABCDU456'), isFalse);
    });

    test('除外文字 Z を含むコードでfalseを返す', () {
      expect(isValidInvitationCode('ABCDZ456'), isFalse);
    });

    test('除外数字 0 を含むコードでfalseを返す', () {
      expect(isValidInvitationCode('ABCD0456'), isFalse);
    });

    test('除外数字 1 を含むコードでfalseを返す', () {
      expect(isValidInvitationCode('ABCD1456'), isFalse);
    });

    test('除外数字 2 を含むコードでfalseを返す', () {
      expect(isValidInvitationCode('ABCD2456'), isFalse);
    });

    test('短すぎるコードでfalseを返す', () {
      expect(isValidInvitationCode('ABCD345'), isFalse);
    });

    test('長すぎるコードでfalseを返す', () {
      expect(isValidInvitationCode('ABCD34567'), isFalse);
    });

    test('空文字列でfalseを返す', () {
      expect(isValidInvitationCode(''), isFalse);
    });

    test('小文字入力でもtrueを返す（toUpperCaseされるため）', () {
      expect(isValidInvitationCode('abcd3456'), isTrue);
    });
  });
}
