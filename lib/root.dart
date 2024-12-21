import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/features/resolver/app.dart';
import 'package:shoppinglist/features/resolver/app_user_create.dart';

class RootPage extends HookConsumerWidget {
  final String title;

  const RootPage({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppResolvers(builder: (context, user) {
      return AppUserCreateResolver(builder: (context) {
        return ForceUpdateResolver(builder: (context) {
          return PurchaseSetupResolver(
            userID: user.uid,
            builder: (context) {
              return const HomePage();
            },
          );
        });
      });
    });
  }
}
