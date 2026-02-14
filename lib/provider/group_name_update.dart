import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shoppinglist/utils/functions/firebase_function.dart';

part 'group_name_update.g.dart';

class UpdateGroupName {
  Future<void> call({
    required String groupID,
    required String name,
  }) async {
    await functions.updateGroupName(
      groupID: groupID,
      name: name,
    );
  }
}

@Riverpod(dependencies: [])
UpdateGroupName updateGroupName(UpdateGroupNameRef ref) {
  return UpdateGroupName();
}
