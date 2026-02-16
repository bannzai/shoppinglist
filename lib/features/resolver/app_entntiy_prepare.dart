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
    final groupID = appUser?.defaultGroupID;
    final createGroup = ref.watch(createGroupProvider);

    final shoppingListAdd = groupID != null
        ? ref.watch(shoppingListAddProvider(groupID: groupID))
        : null;
    final shoppingLists = groupID != null
        ? ref.watch(shoppingListsProvider(groupID: groupID))
        : null;

    // Group未作成の場合は作成してAppUserにセット
    useEffect(() {
      if (appUser != null && groupID == null) {
        createGroup(appUser: appUser);
      }
      return null;
    }, [appUser, groupID]);

    useEffect(() {
      void f() async {
        if (appUser != null &&
            groupID != null &&
            shoppingListAdd != null &&
            shoppingLists is AsyncData &&
            shoppingLists?.value?.isEmpty == true) {
          await shoppingListAdd(
              createUserID: appUser.id,
              groupID: groupID,
              shoppingLocationID: null,
              duplicatedFromGroupShoppingListID: null);
        }
      }

      f();
      return null;
    }, [shoppingLists]);

    if (appUser == null) {
      throw StateError('AppUser is not available');
    }

    if (groupID == null) {
      return const Loading();
    }

    if (shoppingLists?.valueOrNull?.isEmpty == true) {
      return const Loading();
    }
    return builder(context, groupID);
  }
}
