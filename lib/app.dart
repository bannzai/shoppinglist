import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shoppinglist/features/developer_options/page.dart';
import 'package:shoppinglist/features/developer_options/shake_detector.dart';
import 'package:shoppinglist/provider/fcm_notification.dart';
import 'package:shoppinglist/root.dart';

final _navigatorKey = GlobalKey<NavigatorState>();

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    FcmNotificationHandler(navigatorKey: _navigatorKey).initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: '買い物リスト',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
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
