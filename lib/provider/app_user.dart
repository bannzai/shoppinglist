import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shoppinglist/entity/app_user.dart';
import 'package:shoppinglist/features/resolver/database.dart';

part 'app_user.g.dart';

@Riverpod(dependencies: [userDatabase])
Stream<AppUser> appUser(Ref ref) {
  final database = ref.watch(userDatabaseProvider);
  return database.userReference().snapshots().map((event) => event.data()!);
}
