import 'package:shoppinglist/utils/firestore/firestore.dart';
import 'package:shoppinglist/entity/group.dart';
import 'package:shoppinglist/provider/current_user_id.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_groups.g.dart';

@Riverpod(dependencies: [])
Stream<List<Group>> userGroups(Ref ref) {
  final currentUserID = ref.watch(currentUserIDProvider);
  // ログアウト・ユーザー切替直後のティアダウン中に古い uid で groups を
  // クエリしないよう、uid が無い間は Firestore を触らず空リストを流す。
  if (currentUserID == null) {
    return Stream.value(const <Group>[]);
  }
  return firestore
      .collection('/groups')
      .where('memberUserIDs', arrayContains: currentUserID)
      .withConverter(
        fromFirestore: Group.fromFirestore,
        toFirestore: Group.toFirestore,
      )
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
}
