import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shoppinglist/features/resolver/auth.dart';

part 'auth_claim.g.dart';

/// Firebase Auth IDトークンの Custom Claims から isPremium を解決するプロバイダー。
/// Firestoreクエリの表示フィルタに使用する。UI表示用途には customerInfoProvider を使用すること。
/// 購入/復元直後は currentUser.getIdToken(true) 実行後に invalidate して再取得する。
@Riverpod(keepAlive: true, dependencies: [firebaseUserChanges])
Future<bool> firestoreIsPremium(Ref ref) async {
  final user = ref.watch(firebaseUserChangesProvider).asData?.value;
  if (user == null) return false;

  final tokenResult = await user.getIdTokenResult();
  return tokenResult.claims?['isPremium'] == true;
}
