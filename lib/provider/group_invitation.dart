import 'package:riverpod_annotation/riverpod_annotation.dart';
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
  Future<String> call({required String invitationCode}) async {
    final groupID =
        await functions.acceptGroupInvitation(invitationCode: invitationCode);
    return groupID;
  }
}

@Riverpod(dependencies: [])
AcceptGroupInvitation acceptGroupInvitation(AcceptGroupInvitationRef ref) {
  return AcceptGroupInvitation();
}
