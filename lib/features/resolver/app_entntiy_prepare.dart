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
    final shoppingLists = (appUserDefaultGroupID != null && isPremium != null)
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

    // ソログループ自動作成の二重発火防止フラグ。
    // createGroup は await せず fire-and-forget のため、完了前(=defaultGroupIDがまだnull)に
    // appUserストリームが再emitするとこのEffectが再実行され、同一ユーザーに複数のソログループが
    // 作られてしまう。作成を一度だけ走らせるため in-flight/完了済みを ref で記録する。
    final isCreatingSoloGroup = useRef(false);

    // Group未作成の場合に1度だけ作成してAppUserにセットする (ソログループは default icon の 'home')。
    // 依存配列 [appUser, appUserDefaultGroupID, createGroup]:
    //   appUser取得後かつ defaultGroupID が未設定の時に作成する。
    //   成功すると defaultGroupID がセットされ条件を抜けるため再実行されない。
    //   createGroup は createGroupProvider 由来で widget の生存期間中は同一インスタンスのため
    //   実質的に再実行は増えないが、Effectが参照する関数なので依存完全性のため明示する。
    //   isCreatingSoloGroup ガードにより、いずれの再実行でも作成は二重に発火しない。
    useEffect(() {
      if (appUser != null &&
          appUserDefaultGroupID == null &&
          !isCreatingSoloGroup.value) {
        isCreatingSoloGroup.value = true;
        () async {
          try {
            await createGroup(
              appUser: appUser,
              name: null,
              setAsDefault: true,
              iconName: 'home',
            );
            // 成功時はフラグを戻さない(defaultGroupID設定で条件を抜けるため再実行されない)。
          } catch (_) {
            // 失敗時のみ再試行できるようフラグを戻す。
            isCreatingSoloGroup.value = false;
          }
        }();
      }
      return null;
    }, [appUser, appUserDefaultGroupID, createGroup]);

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
      return LaunchLoading.shared();
    }

    // isPremium未解決時は初期リスト自動作成判定を実行しない
    if (firestoreIsPremiumAsync.isLoading) {
      return LaunchLoading.shared();
    }

    if (appUserDefaultGroupID == null) {
      return LaunchLoading.shared();
    }

    if (shoppingLists?.valueOrNull?.isEmpty == true) {
      return LaunchLoading.shared();
    }
    return builder(context);
  }
}
