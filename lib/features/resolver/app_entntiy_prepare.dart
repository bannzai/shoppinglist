import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/loading/loading.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:shoppinglist/provider/app_user.dart';
import 'package:shoppinglist/provider/auth_claim.dart';
import 'package:shoppinglist/provider/fcm_token.dart';
import 'package:shoppinglist/provider/group_create.dart';
import 'package:shoppinglist/provider/shopping_list.dart';

class AppEntityPrepareResolver extends HookConsumerWidget {
  final Widget Function(BuildContext context) builder;

  const AppEntityPrepareResolver({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appUserAsync = ref.watch(appUserProvider);
    final appUser = appUserAsync.asData?.value;
    final appUserDefaultGroupID = appUser?.defaultGroupID;
    final createGroup = ref.watch(createGroupProvider);
    final firestoreIsPremiumAsync = ref.watch(firestoreIsPremiumProvider);
    final isPremium = firestoreIsPremiumAsync.asData?.value;

    final shoppingListAdd = appUserDefaultGroupID != null
        ? ref.watch(shoppingListAddProvider(groupID: appUserDefaultGroupID))
        : null;
    final shoppingLists =
        (appUserDefaultGroupID != null && isPremium != null)
            ? ref.watch(shoppingListsProvider(
                groupID: appUserDefaultGroupID,
                isPremium: isPremium,
              ))
            : null;

    // FCMトークン登録: appUserが取得できたらFCMトークンをFirestoreに保存し、トークン更新を監視する
    // 依存配列: [appUser] — appUserがnullから値に変わった時に実行。再実行時は前回のリフレッシュリスナーをキャンセル
    final userDatabase = ref.watch(userDatabaseProvider);
    useEffect(() {
      if (appUser != null) {
        final fcmRegistration =
            FcmTokenRegistration(userDatabase: userDatabase);
        fcmRegistration.registerToken();
        final subscription = fcmRegistration.listenTokenRefresh();
        return subscription.cancel;
      }
      return null;
    }, [appUser]);

    // Group未作成の場合は作成してAppUserにセット
    useEffect(() {
      if (appUser != null && appUserDefaultGroupID == null) {
        createGroup(appUser: appUser, name: null, setAsDefault: true);
      }
      return null;
    }, [appUser, appUserDefaultGroupID]);

    useEffect(() {
      void f() async {
        if (appUser != null &&
            appUserDefaultGroupID != null &&
            shoppingListAdd != null &&
            shoppingLists is AsyncData &&
            shoppingLists?.value?.isEmpty == true) {
          await shoppingListAdd(
              createUserID: appUser.id,
              groupID: appUserDefaultGroupID,
              shoppingLocationID: null,
              duplicatedFromGroupShoppingListID: null);
        }
      }

      f();
      return null;
    }, [shoppingLists]);

    if (appUser == null) {
      return const Loading();
    }

    // isPremium未解決時は初期リスト自動作成判定を実行しない
    if (firestoreIsPremiumAsync.isLoading) {
      return const Loading();
    }

    if (appUserDefaultGroupID == null) {
      return const Loading();
    }

    if (shoppingLists?.valueOrNull?.isEmpty == true) {
      return const Loading();
    }
    return builder(context);
  }
}
