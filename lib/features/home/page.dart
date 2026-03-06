import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/loading/loading.dart';
import 'package:shoppinglist/features/shopping_list/page.dart';
import 'package:shoppinglist/features/settings/page.dart';
// import 'package:shoppinglist/features/ec_items/page.dart';
import 'package:shoppinglist/provider/app_user.dart';
import 'package:shoppinglist/provider/default_group_update.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';

enum HomePageTabType {
  shoppingList,
  // ecItems,
  settings
}

extension HomePageTabFunctions on HomePageTabType {
  String get screenName {
    switch (this) {
      case HomePageTabType.shoppingList:
        return 'ShoppingListPage';
      // case HomePageTabType.ecItems:
      //   return 'ECItemsPage';
      case HomePageTabType.settings:
        return 'SettingsPage';
    }
  }
}

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appUserAsync = ref.watch(appUserProvider);
    final appUser = appUserAsync.asData?.value;
    final currentGroupID = useState<String?>(appUser?.defaultGroupID);

    // defaultGroupIDの初期化
    useEffect(() {
      if (appUser?.defaultGroupID != null && currentGroupID.value == null) {
        currentGroupID.value = appUser!.defaultGroupID;
      }
      return null;
    }, [appUser?.defaultGroupID]);

    final groupID = currentGroupID.value;
    if (groupID == null) {
      return const Loading();
    }

    final currentShoppingListID = useState<String?>(null);
    final tabIndex = useState(0);
    final ticker = useSingleTickerProvider();
    final tabController = useTabController(
        initialLength: HomePageTabType.values.length, vsync: ticker);
    tabController.addListener(() {
      tabIndex.value = tabController.index;
      _screenTracking(tabController.index);
    });

    return DefaultTabController(
      length: HomePageTabType.values.length,
      child: Scaffold(
        appBar: null,
        bottomNavigationBar: NavigationBar(
          selectedIndex: tabIndex.value,
          onDestinationSelected: (index) {
            tabIndex.value = index;
            tabController.animateTo(index);
            _screenTracking(index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.list_alt_outlined),
              selectedIcon: Icon(Icons.list_alt),
              label: '買い物リスト',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: '設定',
            ),
          ],
        ),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          controller: tabController,
          children: [
            ShoppingListPage(
              groupID: groupID,
              currentShoppingListID: currentShoppingListID,
              onGroupChanged: (newGroupID) {
                currentGroupID.value = newGroupID;
                currentShoppingListID.value = null;
                ref.read(defaultGroupUpdateProvider).call(groupID: newGroupID);
              },
            ),
            const SettingPage(),
          ],
        ),
      ),
    );
  }

  void _screenTracking(int index) {
    analytics.setCurrentScreen(
      screenName: HomePageTabType.values[index].screenName,
    );
  }
}
