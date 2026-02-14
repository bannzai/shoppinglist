import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shoppinglist/utils/functions/firebase_function.dart';

part 'group_member_remove.g.dart';

class RemoveGroupMember {
  Future<void> call({
    required String groupID,
    required String targetUserID,
  }) async {
    await functions.removeGroupMember(
      groupID: groupID,
      targetUserID: targetUserID,
    );
  }
}

@Riverpod(dependencies: [])
RemoveGroupMember removeGroupMember(RemoveGroupMemberRef ref) {
  return RemoveGroupMember();
}
