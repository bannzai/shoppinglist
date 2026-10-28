import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shoppinglist/entity/app_user.dart';
import 'package:shoppinglist/features/resolver/database.dart';

part 'app_user.g.dart';

@Riverpod(dependencies: [userDatabase])
Stream<AppUser> appUser(Ref ref) {
  final database = ref.watch(userDatabaseProvider);
  return database.userReference().snapshots().map((event) => event.data()!);
}

/// AppUserドキュメントが存在しない場合は null を返す。
/// AppUserCreateResolver で使用する。ドキュメント作成前のストリーム発火時に
/// エラーにならず null として扱える。
@Riverpod(dependencies: [userDatabase])
Stream<AppUser?> optionalAppUser(Ref ref) {
  final database = ref.watch(userDatabaseProvider);
  return database.userReference().snapshots().map((event) => event.data());
}
