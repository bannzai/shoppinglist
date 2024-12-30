import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shoppinglist/entity/timestamp.dart';

part 'memo_row.freezed.dart';
part 'memo_row.g.dart';

abstract class MemoRowFirestoreKeys {
  static const id = 'id';
  static const type = 'type';
  static const status = 'status';
  static const order = 'order';
  static const createdDateTime = 'createdDateTime';
  static const updatedDateTime = 'updatedDateTime';
  static const serverCreatedDateTime = 'serverCreatedDateTime';
  static const serverUpdatedDateTime = 'serverUpdatedDateTime';
}

@Freezed(unionKey: 'type')
sealed class MemoRow with _$MemoRow {
  @FreezedUnionValue('text')
  @JsonSerializable(explicitToJson: true)
  const factory MemoRow.text({
    String? id,
    required String memoID,
    required String message,
    required int order,
    @Default(MemoRowStatus.unchecked) MemoRowStatus status,
    @NullableTimestampConverter() DateTime? reminderDateTime,
    @ClientCreatedTimestamp() DateTime? createdDateTime,
    @ClientUpdatedTimestamp() DateTime? updatedDateTime,
    @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
    @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime,
  }) = TextMemoRow;

  @FreezedUnionValue('link')
  @JsonSerializable(explicitToJson: true)
  const factory MemoRow.link({
    String? id,
    required String memoID,
    required String url,
    required int order,
    String? metadataTitle,
    String? metadataDescription,
    String? metadataImageURL,
    @Default(MemoRowStatus.unchecked) MemoRowStatus status,
    @NullableTimestampConverter() DateTime? reminderDateTime,
    @ClientCreatedTimestamp() DateTime? createdDateTime,
    @ClientUpdatedTimestamp() DateTime? updatedDateTime,
    @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
    @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime,
  }) = LinkMemoRow;

  factory MemoRow.fromJson(Map<String, dynamic> json) => _$MemoRowFromJson(json);
}

extension TextMemoRowExtension on TextMemoRow {
  bool get isDraft => id == null;
}

extension LinkMemoRowExtension on LinkMemoRow {
  bool get isDraft => id == null;
}

enum MemoRowStatus {
  @JsonValue('checked')
  checked,
  @JsonValue('unchecked')
  unchecked,
}
