import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shoppinglist/entity/ai_usage.dart';
import 'package:shoppinglist/features/resolver/database.dart';

part 'ai_usage.g.dart';

/// 現在月のAI利用回数をリアルタイム購読するProvider。
@Riverpod(dependencies: [userDatabase])
Stream<AIUsage?> currentMonthAIUsage(Ref ref) {
  final database = ref.watch(userDatabaseProvider);
  return database
      .aiUsageDocumentReference(
          yearMonth: currentYearMonth(now: DateTime.now()))
      .snapshots()
      .map((snapshot) => snapshot.data());
}

/// 現在月のAI画像認識の残り回数を返すProvider。
@Riverpod(dependencies: [currentMonthAIUsage])
int remainingImageRecognitionCount(Ref ref, {required bool isPremium}) {
  final aiUsage = ref.watch(currentMonthAIUsageProvider).valueOrNull;
  final limit = isPremium
      ? premiumMonthlyImageRecognitionLimit
      : freeMonthlyImageRecognitionLimit;
  final used = aiUsage?.imageRecognitionCount ?? 0;
  return (limit - used).clamp(0, limit);
}
