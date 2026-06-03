import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/loading/loading.dart';
import 'package:shoppinglist/features/shopping_list/page.dart';
import 'package:shoppinglist/provider/app_user.dart';
import 'package:shoppinglist/provider/default_group_update.dart';
import 'package:shoppinglist/style/tokens.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appUserAsync = ref.watch(appUserProvider);
    final appUser = appUserAsync.asData?.value;
    final currentGroupID = useState<String?>(appUser?.defaultGroupID);
    final currentShoppingListID = useState<String?>(null);

    useEffect(() {
      if (appUser?.defaultGroupID != null && currentGroupID.value == null) {
        currentGroupID.value = appUser!.defaultGroupID;
      }
      return null;
    }, [appUser?.defaultGroupID]);

    final groupID = currentGroupID.value;
    if (groupID == null) {
      return LaunchLoading.shared();
    }

    return Scaffold(
      backgroundColor: context.tokens.neutral.paper,
      body: ShoppingListPage(
        groupID: groupID,
        currentShoppingListID: currentShoppingListID,
        onGroupChanged: (newGroupID) {
          currentGroupID.value = newGroupID;
          currentShoppingListID.value = null;
          ref.read(defaultGroupUpdateProvider).call(groupID: newGroupID);
        },
      ),
    );
  }
}
