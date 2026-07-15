import 'package:shoppinglist/features/resolver/database.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'default_group_update.g.dart';

class DefaultGroupUpdate {
  final UserDatabase userDatabase;
  DefaultGroupUpdate({required this.userDatabase});

  Future<void> call({required String groupID}) async {
    await userDatabase.userReference().update({'defaultGroupID': groupID});
  }
}

@Riverpod(dependencies: [userDatabase])
DefaultGroupUpdate defaultGroupUpdate(Ref ref) {
  return DefaultGroupUpdate(userDatabase: ref.watch(userDatabaseProvider));
}
