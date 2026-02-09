import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/loading/loading.dart';
import 'package:shoppinglist/entity/app_user.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:shoppinglist/provider/app_user.dart';
import 'package:shoppinglist/provider/shopping_list.dart';

class AppEntityPrepareResolver extends HookConsumerWidget {
  final Widget Function(BuildContext context, String groupID) builder;

  const AppEntityPrepareResolver({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appUserAsync = ref.watch(appUserProvider);
    final appUser = appUserAsync.asData?.value;

    if (appUser == null) {
      return const Loading();
    }

    final groupID = appUser.defaultGroupID;

    // Group未作成の場合は作成してAppUserにセット
    useEffect(() {
      if (groupID == null) {
        _createDefaultGroup(ref, appUser);
      }
      return null;
    }, [groupID]);

    if (groupID == null) {
      return const Loading();
    }

    final shoppingListAdd =
        ref.watch(shoppingListAddProvider(groupID: groupID));
    final shoppingLists = ref.watch(shoppingListsProvider(groupID: groupID));

    useEffect(() {
      void f() async {
        if (shoppingLists is AsyncData &&
            shoppingLists.value?.isEmpty == true) {
          await shoppingListAdd(createUserID: appUser.id, groupID: groupID);
        }
      }

      f();
      return null;
    }, [shoppingLists]);

    if (shoppingLists.valueOrNull?.isEmpty == true) {
      return const Loading();
    }
    return builder(context, groupID);
  }

  // 1人用グループを作成し、AppUserのdefaultGroupIDにセットする
  // 合成ID: group_{uid}
  static Future<void> _createDefaultGroup(
      WidgetRef ref, AppUser appUser) async {
    final syntheticGroupID = AppUser.appUserGroupID(appUser.id);
    await FirebaseFirestore.instance
        .collection('groups')
        .doc(syntheticGroupID)
        .set({
      'members': [appUser.id],
    }, SetOptions(merge: true));
    final userDatabase = ref.read(userDatabaseProvider);
    await userDatabase.userReference().set(
          appUser.copyWith(defaultGroupID: syntheticGroupID),
          SetOptions(merge: true),
        );
  }
}
