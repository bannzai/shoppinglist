import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/loading/loading.dart';
import 'package:shoppinglist/provider/app_user.dart';
import 'package:shoppinglist/provider/group_create.dart';
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
    final createGroup = ref.watch(createGroupProvider);

    // Group未作成の場合は作成してAppUserにセット
    useEffect(() {
      if (groupID == null) {
        createGroup(appUser: appUser);
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
}
