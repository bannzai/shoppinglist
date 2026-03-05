import 'package:flutter/material.dart';
import 'package:shoppinglist/features/auth/page.dart';
import 'package:shoppinglist/features/group_create/page.dart';
import 'package:shoppinglist/features/group_invitation/page.dart';
import 'package:shoppinglist/features/group_list/page.dart';
import 'package:shoppinglist/features/group_setting/page.dart';
import 'package:shoppinglist/features/group_shopping_list_item_category/category_edit_page.dart';
import 'package:shoppinglist/features/group_shopping_list_item_category/page.dart';
import 'package:shoppinglist/features/home/page.dart';
import 'package:shoppinglist/features/previews/mock/mock_data.dart';
import 'package:shoppinglist/features/previews/screens/shopping_list_item_filter_preview.dart';
import 'package:shoppinglist/features/previews/screens/shopping_list_preview.dart';
import 'package:shoppinglist/features/previews/screens/shopping_list_setting_preview.dart';
import 'package:shoppinglist/features/settings/page.dart';
import 'package:shoppinglist/features/shopping_location/page.dart';

class _PreviewEntry {
  final String title;
  final Widget Function(BuildContext context) builder;

  const _PreviewEntry({required this.title, required this.builder});
}

final _previewEntries = <_PreviewEntry>[
  _PreviewEntry(
    title: 'AuthPage',
    builder: (_) => const AuthPage(),
  ),
  _PreviewEntry(
    title: 'HomePage',
    builder: (_) => const HomePage(),
  ),
  _PreviewEntry(
    title: 'ShoppingListPage',
    builder: (_) => const ShoppingListPreview(),
  ),
  _PreviewEntry(
    title: 'SettingPage',
    builder: (_) => const SettingPage(),
  ),
  _PreviewEntry(
    title: 'GroupListPage',
    builder: (_) => const GroupListPage(),
  ),
  _PreviewEntry(
    title: 'GroupCreatePage',
    builder: (_) => const GroupCreatePage(),
  ),
  _PreviewEntry(
    title: 'GroupSettingPage',
    builder: (_) => GroupSettingPage(groupID: mockGroupID),
  ),
  _PreviewEntry(
    title: 'GroupInvitationAcceptPage',
    builder: (_) => const GroupInvitationAcceptPage(),
  ),
  _PreviewEntry(
    title: 'ShoppingLocationPage',
    builder: (_) => ShoppingLocationPage(groupID: mockGroupID),
  ),
  _PreviewEntry(
    title: 'GroupShoppingListItemCategoryPage',
    builder: (_) => GroupShoppingListItemCategoryPage(groupID: mockGroupID),
  ),
  _PreviewEntry(
    title: 'GroupShoppingListItemCategoryEditPage',
    builder: (_) => GroupShoppingListItemCategoryEditPage(
      groupID: mockGroupID,
      categoryAxisID: mockCategoryAxisID,
      categoryID: mockCategoryID,
    ),
  ),
  _PreviewEntry(
    title: 'ShoppingListItemFilterPage',
    builder: (_) => const ShoppingListItemFilterPreview(),
  ),
  _PreviewEntry(
    title: 'ShoppingListSettingPage',
    builder: (_) => const ShoppingListSettingPreview(),
  ),
];

class PreviewsPage extends StatelessWidget {
  const PreviewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Previews')),
      body: ListView.separated(
        itemCount: _previewEntries.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final entry = _previewEntries[index];
          return ListTile(
            title: Text(entry.title),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: entry.builder,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
