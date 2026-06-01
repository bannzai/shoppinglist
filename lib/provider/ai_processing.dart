import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ai_processing.g.dart';

/// AI で買い物リストアイテムを抽出している処理の種別。
enum AIProcessingType {
  /// 写真からの抽出。
  image,

  /// URL からの抽出。
  url,
}

/// 画面横断で「AI 処理中バナー」を表示するためのフラグ。
/// `null` のとき非表示、値が入っているとそのタイプのバナーを表示する。
/// 画像/URL 起動側で `start(...)` を呼び、結果到着 / エラー時に `end()` を呼ぶ。
@riverpod
class AIProcessing extends _$AIProcessing {
  @override
  AIProcessingType? build() => null;

  void start(AIProcessingType type) {
    state = type;
  }

  void end() {
    state = null;
  }
}
