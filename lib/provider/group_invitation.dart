import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:shoppinglist/utils/functions/firebase_function.dart';

part 'group_invitation.g.dart';

class CreateGroupInvitation {
  /// Cloud Functions の `createGroupInvitation` を呼び出し、
  /// 招待コードと有効期限 (`DateTime`) のレコードを返す。
  Future<({String invitationCode, DateTime expiresDateTime})> call({
    required String groupID,
  }) {
    return functions.createGroupInvitation(groupID: groupID);
  }
}

@Riverpod(dependencies: [])
CreateGroupInvitation createGroupInvitation(Ref ref) {
  return CreateGroupInvitation();
}

class AcceptGroupInvitation {
  final UserDatabase userDatabase;

  AcceptGroupInvitation({required this.userDatabase});

  Future<String> call({required String invitationCode}) async {
    final groupID = await functions.acceptGroupInvitation(
      invitationCode: invitationCode,
    );
    // 参加したグループをデフォルトグループに切り替える
    await userDatabase.userReference().update({
      'defaultGroupID': groupID,
      'updatedDateTime': FieldValue.serverTimestamp(),
    });
    return groupID;
  }
}

@Riverpod(dependencies: [userDatabase])
AcceptGroupInvitation acceptGroupInvitation(Ref ref) {
  return AcceptGroupInvitation(userDatabase: ref.watch(userDatabaseProvider));
}
