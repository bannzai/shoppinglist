import 'package:flutter_test/flutter_test.dart';
import 'package:shoppinglist/entity/ai_usage.dart';

void main() {
  group('yearMonthFrom', () {
    test('UTC基準の年月を返す', () {
      // JST 2026-04-01 00:30 → UTC 2026-03-31 15:30 → "2026-03"
      final jstDate = DateTime.utc(2026, 3, 31, 15, 30);
      expect(yearMonthFrom(dateTime: jstDate), '2026-03');
    });

    test('UTC月初の場合', () {
      expect(
          yearMonthFrom(dateTime: DateTime.utc(2026, 4, 1, 0, 0)), '2026-04');
    });

    test('月が1桁の場合ゼロパディングされる', () {
      expect(yearMonthFrom(dateTime: DateTime.utc(2026, 1, 15)), '2026-01');
    });

    test('月が2桁の場合そのまま出力される', () {
      expect(yearMonthFrom(dateTime: DateTime.utc(2026, 12, 15)), '2026-12');
    });
  });

  group('currentYearMonth', () {
    test('yyyy-MM形式で返される', () {
      expect(currentYearMonth(now: DateTime.utc(2026, 4, 1)),
          matches(RegExp(r'^\d{4}-\d{2}$')));
    });

    test('指定した日時から年月を算出する', () {
      expect(currentYearMonth(now: DateTime.utc(2026, 4, 1)), '2026-04');
    });
  });

  group('UserAIUsage', () {
    test('fromJsonで正しくデシリアライズされる', () {
      final json = {
        'id': '2026-04',
        'userID': 'user-1',
        'imageRecognitionCount': 3,
      };
      final aiUsage = UserAIUsage.fromJson(json);
      expect(aiUsage.id, '2026-04');
      expect(aiUsage.userID, 'user-1');
      expect(aiUsage.imageRecognitionCount, 3);
    });

    test('toJsonで正しくシリアライズされる', () {
      const aiUsage = UserAIUsage(
        id: '2026-04',
        userID: 'user-1',
        imageRecognitionCount: 5,
      );
      final json = aiUsage.toJson();
      expect(json['id'], '2026-04');
      expect(json['userID'], 'user-1');
      expect(json['imageRecognitionCount'], 5);
    });
  });

  group('urlRecognitionCount', () {
    test('fromJsonでurlRecognitionCountが正しくデシリアライズされる', () {
      final json = {
        'id': '2026-04',
        'userID': 'user-1',
        'imageRecognitionCount': 3,
        'urlRecognitionCount': 2,
      };
      expect(UserAIUsage.fromJson(json).urlRecognitionCount, 2);
    });

    test('fromJsonでurlRecognitionCountが未設定の場合デフォルト0になる', () {
      final json = {
        'id': '2026-04',
        'userID': 'user-1',
        'imageRecognitionCount': 3,
      };
      expect(UserAIUsage.fromJson(json).urlRecognitionCount, 0);
    });

    test('toJsonでurlRecognitionCountが正しくシリアライズされる', () {
      const aiUsage = UserAIUsage(
        id: '2026-04',
        userID: 'user-1',
        imageRecognitionCount: 5,
        urlRecognitionCount: 3,
      );
      expect(aiUsage.toJson()['urlRecognitionCount'], 3);
    });
  });

  group('categorizeCount', () {
    test('fromJsonでcategorizeCountが正しくデシリアライズされる', () {
      final json = {
        'id': '2026-04',
        'userID': 'user-1',
        'imageRecognitionCount': 3,
        'categorizeCount': 4,
      };
      expect(UserAIUsage.fromJson(json).categorizeCount, 4);
    });

    test('fromJsonでcategorizeCountが未設定の場合デフォルト0になる', () {
      final json = {
        'id': '2026-04',
        'userID': 'user-1',
        'imageRecognitionCount': 3,
      };
      expect(UserAIUsage.fromJson(json).categorizeCount, 0);
    });

    test('toJsonでcategorizeCountが正しくシリアライズされる', () {
      const aiUsage = UserAIUsage(
        id: '2026-04',
        userID: 'user-1',
        imageRecognitionCount: 5,
        categorizeCount: 2,
      );
      expect(aiUsage.toJson()['categorizeCount'], 2);
    });
  });

  group('画像認識月次制限定数', () {
    test('無料ユーザーの月次上限は5回', () {
      expect(freeMonthlyImageRecognitionLimit, 5);
    });

    test('プレミアムユーザーの月次上限は50回', () {
      expect(premiumMonthlyImageRecognitionLimit, 50);
    });
  });

  group('URL認識月次制限定数', () {
    test('無料ユーザーの月次上限は5回', () {
      expect(freeMonthlyURLRecognitionLimit, 5);
    });

    test('プレミアムユーザーの月次上限は50回', () {
      expect(premiumMonthlyURLRecognitionLimit, 50);
    });
  });

  group('AIカテゴリ分け月次制限定数', () {
    test('無料ユーザーの月次上限は5回', () {
      expect(freeMonthlyCategorizeLimit, 5);
    });

    test('プレミアムユーザーの月次上限は50回', () {
      expect(premiumMonthlyCategorizeLimit, 50);
    });
  });
}
