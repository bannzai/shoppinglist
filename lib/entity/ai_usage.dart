import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shoppinglist/entity/timestamp.dart';

part 'ai_usage.g.dart';
part 'ai_usage.freezed.dart';

/// AI機能の月次利用回数を管理するエンティティ。
///
/// Firestore 上では `/users/{userID}/aiUsage/{yearMonth}` に保存される。
/// yearMonth はドキュメントID（例: "2026-04"）。
@freezed
abstract class UserAIUsage with _$UserAIUsage {
  const UserAIUsage._();

  @JsonSerializable(explicitToJson: true)
  const factory UserAIUsage({
    /// ドキュメントID（yearMonth形式、例: "2026-04"）
    required String id,

    /// このドキュメントの所有ユーザーID
    required String userID,

    /// AI画像認識の利用回数
    required int imageRecognitionCount,

    /// URLからの買い物リスト生成の利用回数
    @Default(0) int urlRecognitionCount,

    /// AIカテゴリ分けの利用回数
    @Default(0) int categorizeCount,
    @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
    @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime,
  }) = _UserAIUsage;

  factory UserAIUsage.fromJson(Map<String, dynamic> json) =>
      _$UserAIUsageFromJson(json);

  /// Firestoreからの読み込み用コンバータ。
  static UserAIUsage fromFirestore(
          DocumentSnapshot<Map<String, dynamic>> snapshot,
          SnapshotOptions? options) =>
      UserAIUsage.fromJson(snapshot.data()!..['id'] = snapshot.id);

  /// Firestoreへの書き込み用コンバータ。
  static Map<String, dynamic> toFirestore(
          UserAIUsage userAIUsage, SetOptions? options) =>
      userAIUsage.toJson();
}

/// 指定日時をUTC基準の "yyyy-MM" 形式へ変換する。
String yearMonthFrom({required DateTime dateTime}) {
  final utc = dateTime.toUtc();
  return '${utc.year}-${utc.month.toString().padLeft(2, '0')}';
}

/// 現在時刻をUTC基準で "yyyy-MM" 形式にして返す。
String currentYearMonth({required DateTime now}) =>
    yearMonthFrom(dateTime: now);

/// 無料ユーザーのAI画像認識月次上限。
const int freeMonthlyImageRecognitionLimit = 5;

/// プレミアムユーザーのAI画像認識月次上限。
const int premiumMonthlyImageRecognitionLimit = 50;

/// 無料ユーザーのURL認識月次上限。
const int freeMonthlyURLRecognitionLimit = 5;

/// プレミアムユーザーのURL認識月次上限。
const int premiumMonthlyURLRecognitionLimit = 50;

/// 無料ユーザーのAIカテゴリ分け月次上限。
const int freeMonthlyCategorizeLimit = 5;

/// プレミアムユーザーのAIカテゴリ分け月次上限。
const int premiumMonthlyCategorizeLimit = 50;
