import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/auth/google.dart';

class AuthPage extends HookConsumerWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('サインイン'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SvgPicture.asset('images/undraw_shopping-app_b80f.svg'),
            const AppSignInWithGoogleButton(),
            const AppSignInWithGoogleButton(),
          ],
        ),
      ),
    );
  }
}
