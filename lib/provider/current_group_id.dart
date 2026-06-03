import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_group_id.g.dart';

/// 現在表示中のグループID。アプリ全体で1つだけ保持する選択状態。
///
/// 既定値(appUser.defaultGroupID)の初期化は CurrentGroupResolver が行う。
/// ここで appUserProvider を読まないのは、appUser の更新ごとに build が再実行され
/// ユーザーの手動グループ切替がリセットされるのを避けるため(scope 依存も持ち込まない)。
@riverpod
class CurrentGroupID extends _$CurrentGroupID {
  @override
  String? build() => null;

  /// 表示中グループを切り替える。
  void update(String groupID) => state = groupID;
}
