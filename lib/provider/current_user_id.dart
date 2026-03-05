import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/features/resolver/auth.dart';

final currentUserIDProvider = Provider<String?>((ref) {
  final userAsync = ref.watch(firebaseUserChangesProvider);
  return userAsync.valueOrNull?.uid;
});
