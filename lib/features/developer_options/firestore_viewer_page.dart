import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/app_user.dart';
import 'package:shoppinglist/entity/app_user_private.dart';
import 'package:shoppinglist/entity/group.dart';
import 'package:shoppinglist/entity/group_category.dart';
import 'package:shoppinglist/entity/group_category_axis.dart';
import 'package:shoppinglist/entity/group_shopping_list.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/entity/group_shopping_location.dart';
import 'package:shoppinglist/entity/group_user_profile.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:shoppinglist/provider/current_user_id.dart';

/// 開発者オプションからFirestoreの全関連データをJSON形式で閲覧するページ。
/// QAテスト時にDBの状態を確認するために使用する。
class FirestoreViewerPage extends ConsumerWidget {
  const FirestoreViewerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUID = ref.watch(currentUserIDProvider);

    if (currentUID == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Firestoreデータ確認')),
        body: const Center(child: Text('ユーザーIDが取得できません')),
      );
    }

    final userDB = UserDatabase(userID: currentUID);

    return Scaffold(
      appBar: AppBar(title: const Text('Firestoreデータ確認')),
      body: SafeArea(
        child: ListView(
          children: [
            _UserSection(userDB: userDB),
            _UserPrivateSection(userDB: userDB),
            _GroupsSection(currentUID: currentUID),
          ],
        ),
      ),
    );
  }
}

/// AppUser セクション
class _UserSection extends StatelessWidget {
  final UserDatabase userDB;
  const _UserSection({required this.userDB});

  @override
  Widget build(BuildContext context) {
    return _AsyncExpansionTile<AppUser>(
      title: 'AppUser',
      icon: Icons.person,
      future: () => userDB.userReference().get().then((s) => s.data()),
      builder: (user) => _JsonText(data: user?.toJson()),
    );
  }
}

/// AppUserPrivate セクション
class _UserPrivateSection extends StatelessWidget {
  final UserDatabase userDB;
  const _UserPrivateSection({required this.userDB});

  @override
  Widget build(BuildContext context) {
    return _AsyncExpansionTile<AppUserPrivate>(
      title: 'AppUserPrivate',
      icon: Icons.lock,
      future: () => userDB.privateReference().get().then((s) => s.data()),
      builder: (data) => _JsonText(data: data?.toJson()),
    );
  }
}

/// グループ一覧セクション
class _GroupsSection extends StatelessWidget {
  final String currentUID;
  const _GroupsSection({required this.currentUID});

  @override
  Widget build(BuildContext context) {
    return _AsyncExpansionTile<List<Group>>(
      title: 'Groups',
      icon: Icons.groups,
      future: () async {
        final snapshot = await FirebaseFirestore.instance
            .collection('/groups')
            .where('memberUserIDs', arrayContains: currentUID)
            .withConverter(
              fromFirestore: Group.fromFirestore,
              toFirestore: Group.toFirestore,
            )
            .get();
        return snapshot.docs.map((doc) => doc.data()).toList();
      },
      builder: (groups) {
        if (groups == null || groups.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('グループなし'),
          );
        }
        return Column(
          children: groups
              .map((group) => _GroupDetailSection(group: group))
              .toList(),
        );
      },
    );
  }
}

/// 個別グループの詳細セクション
class _GroupDetailSection extends StatelessWidget {
  final Group group;
  const _GroupDetailSection({required this.group});

  @override
  Widget build(BuildContext context) {
    final groupDB = GroupDatabase(groupID: group.id);

    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Column(
        children: [
          _AsyncExpansionTile<Map<String, dynamic>>(
            title: 'Group: ${group.name ?? '名前未設定'} (${group.id})',
            icon: Icons.group,
            future: () async => group.toJson(),
            builder: (data) => _JsonText(data: data),
          ),
          _ShoppingListsSection(groupDB: groupDB),
          _ShoppingLocationsSection(groupDB: groupDB),
          _CategoryAxesSection(groupDB: groupDB),
          _UserProfilesSection(groupDB: groupDB),
        ],
      ),
    );
  }
}

/// ShoppingLists + Items セクション
class _ShoppingListsSection extends StatelessWidget {
  final GroupDatabase groupDB;
  const _ShoppingListsSection({required this.groupDB});

  @override
  Widget build(BuildContext context) {
    return _AsyncExpansionTile<List<GroupShoppingList>>(
      title: 'ShoppingLists',
      icon: Icons.list_alt,
      future: () async {
        final snapshot = await groupDB.shoppingListsReference().get();
        return snapshot.docs.map((doc) => doc.data()).toList();
      },
      builder: (lists) {
        if (lists == null || lists.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('リストなし'),
          );
        }
        return Column(
          children: lists.map((list) {
            return Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                children: [
                  _JsonExpansionTile(
                    title: 'List: ${list.name} (${list.id})',
                    icon: Icons.shopping_cart,
                    data: list.toJson(),
                  ),
                  _ShoppingListItemsSection(
                    groupDB: groupDB,
                    shoppingListID: list.id,
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

/// ShoppingListItems セクション
class _ShoppingListItemsSection extends StatelessWidget {
  final GroupDatabase groupDB;
  final String shoppingListID;
  const _ShoppingListItemsSection({
    required this.groupDB,
    required this.shoppingListID,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: _AsyncExpansionTile<List<GroupShoppingListItem>>(
        title: 'Items',
        icon: Icons.check_box,
        future: () async {
          final snapshot = await groupDB
              .shoppingListItemsReference(shoppingListID: shoppingListID)
              .get();
          return snapshot.docs.map((doc) => doc.data()).toList();
        },
        builder: (items) {
          if (items == null || items.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Text('アイテムなし'),
            );
          }
          return Column(
            children: items
                .map((item) => _JsonExpansionTile(
                      title: '${item.message} (${item.status.name})',
                      icon: Icons.shopping_bag,
                      data: item.toJson(),
                    ))
                .toList(),
          );
        },
      ),
    );
  }
}

/// ShoppingLocations セクション
class _ShoppingLocationsSection extends StatelessWidget {
  final GroupDatabase groupDB;
  const _ShoppingLocationsSection({required this.groupDB});

  @override
  Widget build(BuildContext context) {
    return _AsyncExpansionTile<List<GroupShoppingLocation>>(
      title: 'ShoppingLocations',
      icon: Icons.location_on,
      future: () async {
        final snapshot = await groupDB.shoppingLocationsReference().get();
        return snapshot.docs.map((doc) => doc.data()).toList();
      },
      builder: (locations) {
        if (locations == null || locations.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('場所なし'),
          );
        }
        return Column(
          children: locations
              .map((loc) => _JsonExpansionTile(
                    title: loc.name,
                    icon: Icons.store,
                    data: loc.toJson(),
                  ))
              .toList(),
        );
      },
    );
  }
}

/// CategoryAxes + Categories セクション
class _CategoryAxesSection extends StatelessWidget {
  final GroupDatabase groupDB;
  const _CategoryAxesSection({required this.groupDB});

  @override
  Widget build(BuildContext context) {
    return _AsyncExpansionTile<List<GroupCategoryAxis>>(
      title: 'UserCategoryAxes',
      icon: Icons.category,
      future: () async {
        final snapshot = await groupDB.categoryAxesReference().get();
        return snapshot.docs.map((doc) => doc.data()).toList();
      },
      builder: (axes) {
        if (axes == null || axes.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('カテゴリ軸なし'),
          );
        }
        return Column(
          children: axes.map((axis) {
            return Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                children: [
                  _JsonExpansionTile(
                    title: 'Axis: ${axis.name} (${axis.id})',
                    icon: Icons.account_tree,
                    data: axis.toJson(),
                  ),
                  _CategoriesSection(
                    groupDB: groupDB,
                    categoryAxisID: axis.id,
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

/// Categories セクション
class _CategoriesSection extends StatelessWidget {
  final GroupDatabase groupDB;
  final String categoryAxisID;
  const _CategoriesSection({
    required this.groupDB,
    required this.categoryAxisID,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: _AsyncExpansionTile<List<GroupCategory>>(
        title: 'Categories',
        icon: Icons.label,
        future: () async {
          final snapshot = await groupDB
              .categoriesReference(categoryAxisID: categoryAxisID)
              .get();
          return snapshot.docs.map((doc) => doc.data()).toList();
        },
        builder: (categories) {
          if (categories == null || categories.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Text('カテゴリなし'),
            );
          }
          return Column(
            children: categories
                .map((cat) => _JsonExpansionTile(
                      title: cat.name,
                      icon: Icons.label_outline,
                      data: cat.toJson(),
                    ))
                .toList(),
          );
        },
      ),
    );
  }
}

/// UserProfiles セクション
class _UserProfilesSection extends StatelessWidget {
  final GroupDatabase groupDB;
  const _UserProfilesSection({required this.groupDB});

  @override
  Widget build(BuildContext context) {
    return _AsyncExpansionTile<List<GroupUserProfile>>(
      title: 'UserProfiles',
      icon: Icons.badge,
      future: () async {
        final snapshot = await groupDB.userProfilesReference().get();
        return snapshot.docs.map((doc) => doc.data()).toList();
      },
      builder: (profiles) {
        if (profiles == null || profiles.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('プロフィールなし'),
          );
        }
        return Column(
          children: profiles
              .map((p) => _JsonExpansionTile(
                    title:
                        '${p.displayName ?? '名前未設定'} (${p.userID})',
                    icon: Icons.person_outline,
                    data: p.toJson(),
                  ))
              .toList(),
        );
      },
    );
  }
}

/// 非同期データ読み込み付きExpansionTile。
/// 展開時にfutureを実行してデータを読み込む。
class _AsyncExpansionTile<T> extends StatefulWidget {
  final String title;
  final IconData icon;
  final Future<T?> Function() future;
  final Widget Function(T?) builder;

  const _AsyncExpansionTile({
    required this.title,
    required this.icon,
    required this.future,
    required this.builder,
  });

  @override
  State<_AsyncExpansionTile<T>> createState() =>
      _AsyncExpansionTileState<T>();
}

class _AsyncExpansionTileState<T> extends State<_AsyncExpansionTile<T>> {
  Future<T?>? _future;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: Icon(widget.icon, size: 20),
      title: Text(widget.title, style: const TextStyle(fontSize: 14)),
      onExpansionChanged: (expanded) {
        if (expanded && _future == null) {
          setState(() {
            _future = widget.future();
          });
        }
      },
      children: [
        if (_future == null)
          const SizedBox.shrink()
        else
          FutureBuilder<T?>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2)),
                );
              }
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'エラー: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }
              return widget.builder(snapshot.data);
            },
          ),
      ],
    );
  }
}

/// JSONデータを表示するExpansionTile
class _JsonExpansionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Map<String, dynamic>? data;

  const _JsonExpansionTile({
    required this.title,
    required this.icon,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: Icon(icon, size: 20),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      children: [_JsonText(data: data)],
    );
  }
}

/// JSONデータをフォーマットして表示するウィジェット
class _JsonText extends StatelessWidget {
  final Map<String, dynamic>? data;
  const _JsonText({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('データなし'),
      );
    }
    // Timestamp等のFirestoreオブジェクトをJSON文字列に変換するためカスタムエンコーダーを使用
    final jsonString = JsonEncoder.withIndent('  ', (object) {
      if (object is Timestamp) {
        return object.toDate().toIso8601String();
      }
      return object.toString();
    }).convert(data);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: SelectableText(
          jsonString,
          style: const TextStyle(
            fontSize: 12,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }
}
