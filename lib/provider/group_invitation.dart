import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:shoppinglist/utils/functions/firebase_function.dart';

part 'group_invitation.g.dart';

class CreateGroupInvitation {
  Future<String> call({required String groupID}) async {
    final invitationCode =
        await functions.createGroupInvitation(groupID: groupID);
    return invitationCode;
  }
}

@Riverpod(dependencies: [])
CreateGroupInvitation createGroupInvitation(CreateGroupInvitationRef ref) {
  return CreateGroupInvitation();
}

class AcceptGroupInvitation {
  final UserDatabase userDatabase;

  AcceptGroupInvitation({required this.userDatabase});

  Future<String> call({required String invitationCode}) async {
    final groupID =
        await functions.acceptGroupInvitation(invitationCode: invitationCode);
    // 参加したグループをデフォルトグループに切り替える
    await userDatabase.userReference().update({
      'defaultGroupID': groupID,
      'updatedDateTime': FieldValue.serverTimestamp(),
    });
    return groupID;
  }
}

@Riverpod(dependencies: [userDatabase])
AcceptGroupInvitation acceptGroupInvitation(AcceptGroupInvitationRef ref) {
  return AcceptGroupInvitation(userDatabase: ref.read(userDatabaseProvider));
}
