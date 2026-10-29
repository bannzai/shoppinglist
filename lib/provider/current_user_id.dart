import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shoppinglist/features/resolver/auth.dart';

part 'current_user_id.g.dart';

/// サインイン中の Firebase Auth ユーザーの uid。未サインイン・読込中は null。
// firebaseUserChanges は dependencies を持つ (scoped な) provider で、Riverpod 3 は
// それを watch する provider が dependencies に列挙していないと実行時に例外を投げる
@Riverpod(keepAlive: true, dependencies: [firebaseUserChanges])
String? currentUserID(Ref ref) {
  final userAsync = ref.watch(firebaseUserChangesProvider);
  return userAsync.value?.uid;
}
