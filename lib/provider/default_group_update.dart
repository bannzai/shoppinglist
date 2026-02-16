import 'package:shoppinglist/features/resolver/database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'default_group_update.g.dart';

class DefaultGroupUpdate {
  final UserDatabase userDatabase;
  DefaultGroupUpdate({required this.userDatabase});

  Future<void> call({required String groupID}) async {
    await userDatabase.userReference().update({
      'defaultGroupID': groupID,
    });
  }
}

@Riverpod(dependencies: [userDatabase])
DefaultGroupUpdate defaultGroupUpdate(DefaultGroupUpdateRef ref) {
  return DefaultGroupUpdate(userDatabase: ref.read(userDatabaseProvider));
}
