import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shoppinglist/entity/timestamp.dart';

part 'memo.g.dart';
part 'memo.freezed.dart';

@freezed
class Memo with _$Memo {
  const Memo._();

  @JsonSerializable(explicitToJson: true)
  const factory Memo({
    String? id,
    @Default('') String name,
    @Default(MemoStatus.active) MemoStatus status,
    @ClientCreatedTimestamp() DateTime? createdDateTime,
    @ClientUpdatedTimestamp() DateTime? updatedDateTime,
    @ServerCreatedTimestamp() DateTime? serverCreatedDateTime,
    @ServerUpdatedTimestamp() DateTime? serverUpdatedDateTime,
  }) = _Memo;

  factory Memo.fromJson(Map<String, dynamic> json) => _$MemoFromJson(json);
}

enum MemoStatus {
  @JsonValue('active')
  active,
  @JsonValue('done')
  done,
  @JsonValue('archived')
  archived,
}
