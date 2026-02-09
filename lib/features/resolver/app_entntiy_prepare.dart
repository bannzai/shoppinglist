import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/loading/loading.dart';
import 'package:shoppinglist/provider/shopping_list.dart';

class AppEntityPrepareResolver extends HookConsumerWidget {
  final String userID;
  final String groupID;
  final Widget Function(BuildContext context) builder;

  const AppEntityPrepareResolver({
    super.key,
    required this.userID,
    required this.groupID,
    required this.builder,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shoppingListAdd =
        ref.watch(shoppingListAddProvider(groupID: groupID));
    final shoppingLists = ref.watch(shoppingListsProvider(groupID: groupID));

    useEffect(() {
      void f() async {
        if (shoppingLists is AsyncData &&
            shoppingLists.value?.isEmpty == true) {
          await shoppingListAdd(createUserID: userID, groupID: groupID);
        }
      }

      f();
      return null;
    }, [shoppingLists]);

    if (shoppingLists.valueOrNull?.isEmpty == true) {
      return const Loading();
    }
    return builder(context);
  }
}
