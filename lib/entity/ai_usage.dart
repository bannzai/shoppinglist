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
abstract class AIUsage with _$AIUsage {
  const AIUsage._();

  @JsonSerializable(explicitToJson: true)
  const factory AIUsage({
    /// ドキュメントID（yearMonth形式、例: "2026-04"）
    required String id,

    /// このドキュメントの所有ユーザーID
    required String userID,

    /// AI画像認識の利用回数
    required int imageRecognitionCount,
    @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
    @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime,
  }) = _AIUsage;

  factory AIUsage.fromJson(Map<String, dynamic> json) =>
      _$AIUsageFromJson(json);

  /// Firestoreからの読み込み用コンバータ。
  static AIUsage fromFirestore(
          DocumentSnapshot<Map<String, dynamic>> snapshot,
          SnapshotOptions? options) =>
      AIUsage.fromJson(snapshot.data()!..['id'] = snapshot.id);

  /// Firestoreへの書き込み用コンバータ。
  static Map<String, dynamic> toFirestore(
          AIUsage aiUsage, SetOptions? options) =>
      aiUsage.toJson();
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
