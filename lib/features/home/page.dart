import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/features/shopping_list/page.dart';
import 'package:shoppinglist/features/settings/page.dart';
import 'package:shoppinglist/features/ec_items/page.dart';
import 'package:shoppinglist/style/color.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';

enum HomePageTabType { shoppingList, ecItems, settings }

extension HomePageTabFunctions on HomePageTabType {
  String get screenName {
    switch (this) {
      case HomePageTabType.shoppingList:
        return 'ShoppingListPage';
      case HomePageTabType.ecItems:
        return 'ECItemsPage';
      case HomePageTabType.settings:
        return 'SettingsPage';
    }
  }
}

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabIndex = useState(0);
    final ticker = useSingleTickerProvider();
    final tabController = useTabController(initialLength: HomePageTabType.values.length, vsync: ticker);
    tabController.addListener(() {
      tabIndex.value = tabController.index;
      _screenTracking(tabController.index);
    });

    return DefaultTabController(
      length: HomePageTabType.values.length,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: null,
        bottomNavigationBar: Ink(
          child: SafeArea(
            child: TabBar(
              controller: tabController,
              labelColor: AppColors.primary,
              labelStyle: const TextStyle(fontSize: 12),
              indicatorColor: Colors.transparent,
              unselectedLabelColor: TextColor.gray,
              tabs: const <Tab>[
                Tab(
                  text: '買い物リスト',
                  icon: Icon(Icons.list_alt_outlined),
                ),
                Tab(
                  text: 'EC商品メモ',
                  icon: Icon(Icons.shopping_cart_outlined),
                ),
                Tab(
                  text: '設定',
                  icon: Icon(Icons.settings_outlined),
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          controller: tabController,
          children: const [
            ShoppingListPage(),
            ECItemsPage(),
            SettingPage(),
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
