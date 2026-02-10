import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/features/group_invitation/page.dart';

class DeepLinkResolver extends HookConsumerWidget {
  final Widget Function(BuildContext context) builder;

  const DeepLinkResolver({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLinks = useMemoized(() => AppLinks());
    final navigatorKey = useMemoized(() => GlobalKey<NavigatorState>());

    useEffect(() {
      // 初回起動リンクの処理
      void handleInitialLink() async {
        final initialUri = await appLinks.getInitialLink();
        if (initialUri != null) {
          _handleDeepLink(navigatorKey, initialUri);
        }
      }

      handleInitialLink();

      // アプリ実行中のリンク受信
      final subscription = appLinks.uriLinkStream.listen((uri) {
        _handleDeepLink(navigatorKey, uri);
      });

      return subscription.cancel;
    }, [appLinks]);

    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => builder(context),
        );
      },
    );
  }

  void _handleDeepLink(
      GlobalKey<NavigatorState> navigatorKey, Uri uri) {
    if (uri.path == '/invite') {
      final token = uri.queryParameters['token'];
      if (token != null && token.isNotEmpty) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => GroupInvitationAcceptPage(token: token),
          ),
        );
      }
    }
  }
}
