import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/features/home/page.dart';
import 'package:shoppinglist/features/resolver/app.dart';
import 'package:shoppinglist/features/resolver/app_entntiy_prepare.dart';
import 'package:shoppinglist/features/resolver/app_user_create.dart';
import 'package:shoppinglist/features/resolver/force_update.dart';
import 'package:shoppinglist/features/resolver/purchase_setup.dart';

class RootPage extends HookConsumerWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppResolvers(builder: (context, user) {
      debugPrint('Resolved AppResolvers user: ${user.uid}');
      return AppUserCreateResolver(builder: (context) {
        debugPrint('Resolved AppUserCreateResolver user: ${user.uid}');
        return ForceUpdateResolver(builder: (context) {
          debugPrint('Resolved ForceUpdateResolver user: ${user.uid}');
          return PurchaseSetupResolver(
            userID: user.uid,
            builder: (context) {
              debugPrint('Resolved PurchaseSetupResolver user: ${user.uid}');
              return AppEntityPrepareResolver(
                  userID: user.uid,
                  builder: (context) {
                    debugPrint('Resolved AppEntityPrepareResolver user: ${user.uid}');
                    return const HomePage();
                  });
            },
          );
        });
      });
    });
  }
}
