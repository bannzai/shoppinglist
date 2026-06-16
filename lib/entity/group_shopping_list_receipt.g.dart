// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_shopping_list_receipt.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GroupShoppingListReceipt _$GroupShoppingListReceiptFromJson(
        Map<String, dynamic> json) =>
    _GroupShoppingListReceipt(
      id: json['id'] as String,
      groupID: json['groupID'] as String,
      shoppingListID: json['shoppingListID'] as String,
      userID: json['userID'] as String,
      storagePath: json['storagePath'] as String?,
      amount: (json['amount'] as num?)?.toInt(),
      memo: json['memo'] as String?,
      createdDateTime: const ClientCreatedTimestamp()
          .fromJson(json['createdDateTime'] as Timestamp?),
      updatedDateTime: const ClientUpdatedTimestamp()
          .fromJson(json['updatedDateTime'] as Timestamp?),
      serverCreatedDateTime: const ServerCreatedTimestamp()
          .fromJson(json['serverCreatedDateTime']),
      serverUpdatedDateTime: const ServerUpdatedTimestamp()
          .fromJson(json['serverUpdatedDateTime']),
    );

Map<String, dynamic> _$GroupShoppingListReceiptToJson(
        _GroupShoppingListReceipt instance) =>
    <String, dynamic>{
      'id': instance.id,
      'groupID': instance.groupID,
      'shoppingListID': instance.shoppingListID,
      'userID': instance.userID,
      'storagePath': instance.storagePath,
      'amount': instance.amount,
      'memo': instance.memo,
      'createdDateTime':
          const ClientCreatedTimestamp().toJson(instance.createdDateTime),
      'updatedDateTime':
          const ClientUpdatedTimestamp().toJson(instance.updatedDateTime),
      'serverCreatedDateTime':
          const ServerCreatedTimestamp().toJson(instance.serverCreatedDateTime),
      'serverUpdatedDateTime':
          const ServerUpdatedTimestamp().toJson(instance.serverUpdatedDateTime),
    };
