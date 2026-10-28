import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shoppinglist/entity/group.dart';
import 'package:shoppinglist/features/resolver/database.dart';

part 'group.g.dart';

@Riverpod(dependencies: [groupDatabase])
Stream<Group> group(Ref ref, {required String groupID}) {
  final database = ref.watch(groupDatabaseProvider(groupID: groupID));
  return database.groupReference().snapshots().map((event) => event.data()!);
}
