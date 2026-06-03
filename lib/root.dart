import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/features/home/page.dart';
import 'package:shoppinglist/features/home_widget/home_widget_sync.dart';
import 'package:shoppinglist/features/resolver/app.dart';
import 'package:shoppinglist/features/resolver/app_entntiy_prepare.dart';
import 'package:shoppinglist/features/resolver/app_user_create.dart';
import 'package:shoppinglist/features/resolver/current_group_resolver.dart';
import 'package:shoppinglist/features/resolver/force_update.dart';

class RootPage extends ConsumerWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppResolvers(builder: (context, user) {
      debugPrint('Resolved AppResolvers user: ${user.uid}');
      return AppUserCreateResolver(
          firebaseUser: user,
          builder: (context) {
            debugPrint('Resolved AppUserCreateResolver user: ${user.uid}');
            return ForceUpdateResolver(builder: (context) {
              debugPrint('Resolved ForceUpdateResolver user: ${user.uid}');
              return AppEntityPrepareResolver(builder: (context) {
                debugPrint(
                    'Resolved AppEntityPrepareResolver user: ${user.uid}');
                // currentGroupID を確定 → ホームウィジェット同期(provider 内部 watch) →
                // 表示。HomeWidgetSync を chain に置くことで、表示ツリーの深さに依存せず
                // 現在グループ/リストの変更をウィジェットストレージへ同期する。
                return CurrentGroupResolver(builder: (context) {
                  return HomeWidgetSync(builder: (context) {
                    return const HomePage();
                  });
                });
              });
            });
          });
    });
  }
}
