import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/features/developer_options/page.dart';
import 'package:shoppinglist/features/developer_options/shake_detector.dart';
import 'package:shoppinglist/provider/app_user.dart';
import 'package:shoppinglist/provider/fcm_notification.dart';
import 'package:shoppinglist/provider/geofence.dart';
import 'package:shoppinglist/provider/local_notification.dart';
import 'package:shoppinglist/provider/theme_color.dart';
import 'package:shoppinglist/root.dart';

final _navigatorKey = GlobalKey<NavigatorState>();

/// アプリケーションのルートWidget。テーマカラー・ナビゲーション・FCM通知を管理する。
class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  void initState() {
    super.initState();
    FcmNotificationHandler(navigatorKey: _navigatorKey).initialize();
  }

  @override
  Widget build(BuildContext context) {
    // ローカル通知初期化
    ref.watch(localNotificationsInitializedProvider);
    // ジオフェンス監視を開始（条件を満たした場合のみ）
    ref.watch(geofenceMonitorProvider);

    // appUserProvider は UserDatabaseResolver スコープ外では AsyncError になるが、
    // .asData?.value で安全に null フォールバックし、デフォルト色が使われる
    final seedColor = resolveThemeColor(
        ref.watch(appUserProvider).asData?.value.themeColorHex);

    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: '買い物リスト',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      builder: kDebugMode
          ? (context, child) {
              return ShakeDetectorWrapper(
                onShake: () {
                  final navigatorContext =
                      Navigator.of(context, rootNavigator: true).context;
                  showDeveloperOptionsModal(navigatorContext);
                },
                child: child ?? const SizedBox.shrink(),
              );
            }
          : null,
      home: const RootPage(),
    );
  }
}
