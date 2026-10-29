import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shoppinglist/entity/ai_usage.dart';
import 'package:shoppinglist/features/resolver/database.dart';

part 'ai_usage.g.dart';

/// 現在月のAI利用回数をリアルタイム購読するProvider。
@Riverpod(dependencies: [userDatabase])
Stream<UserAIUsage?> currentMonthAIUsage(Ref ref) {
  final database = ref.watch(userDatabaseProvider);
  return database
      .aiUsageDocumentReference(
        yearMonth: currentYearMonth(now: DateTime.now()),
      )
      .snapshots()
      .map((snapshot) => snapshot.data());
}

/// 現在月のAI画像認識の残り回数を返すProvider。
@Riverpod(dependencies: [currentMonthAIUsage])
int remainingImageRecognitionCount(Ref ref, {required bool isPremium}) {
  final aiUsage = ref.watch(currentMonthAIUsageProvider).value;
  final limit =
      isPremium
          ? premiumMonthlyImageRecognitionLimit
          : freeMonthlyImageRecognitionLimit;
  final used = aiUsage?.imageRecognitionCount ?? 0;
  return (limit - used).clamp(0, limit);
}

/// 現在月のURL認識の残り回数を返すProvider。
@Riverpod(dependencies: [currentMonthAIUsage])
int remainingURLRecognitionCount(Ref ref, {required bool isPremium}) {
  final aiUsage = ref.watch(currentMonthAIUsageProvider).value;
  final limit =
      isPremium
          ? premiumMonthlyURLRecognitionLimit
          : freeMonthlyURLRecognitionLimit;
  final used = aiUsage?.urlRecognitionCount ?? 0;
  return (limit - used).clamp(0, limit);
}

/// 現在月のAIカテゴリ分けの残り回数を返すProvider。
@Riverpod(dependencies: [currentMonthAIUsage])
int remainingCategorizeCount(Ref ref, {required bool isPremium}) {
  final aiUsage = ref.watch(currentMonthAIUsageProvider).value;
  final limit =
      isPremium ? premiumMonthlyCategorizeLimit : freeMonthlyCategorizeLimit;
  final used = aiUsage?.categorizeCount ?? 0;
  return (limit - used).clamp(0, limit);
}
