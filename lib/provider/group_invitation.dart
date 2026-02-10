import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shoppinglist/utils/functions/firebase_function.dart';

part 'group_invitation.g.dart';

class CreateGroupInvitation {
  Future<String> call({required String groupID}) async {
    final invitationURL =
        await functions.createGroupInvitation(groupID: groupID);
    return invitationURL;
  }
}

@Riverpod(dependencies: [])
CreateGroupInvitation createGroupInvitation(CreateGroupInvitationRef ref) {
  return CreateGroupInvitation();
}

class AcceptGroupInvitation {
  Future<String> call({required String token}) async {
    final groupID = await functions.acceptGroupInvitation(token: token);
    return groupID;
  }
}

@Riverpod(dependencies: [])
AcceptGroupInvitation acceptGroupInvitation(AcceptGroupInvitationRef ref) {
  return AcceptGroupInvitation();
}
