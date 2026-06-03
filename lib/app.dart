import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/toast/toast_overlay.dart';
import 'package:shoppinglist/features/developer_options/page.dart';
import 'package:shoppinglist/features/developer_options/shake_detector.dart';
import 'package:shoppinglist/features/resolver/auth.dart';
import 'package:shoppinglist/provider/app_user.dart';
import 'package:shoppinglist/provider/fcm_notification.dart';
import 'package:shoppinglist/provider/geofence.dart';
import 'package:shoppinglist/provider/theme_color.dart';
import 'package:shoppinglist/root.dart';
import 'package:shoppinglist/style/theme.dart';

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
    FcmNotificationHandler().initialize();

    // ジオフェンス監視: 監視プランの変化に追従して開始/停止する。
    // Provider は計算に徹し、副作用（service の開始/停止）はここで起こす（Riverpod 公式 DO）。
    // build ではなく initState で listenManual するのは、購読を1回だけ確立すれば以降の変化は
    // listener が追従するため（build 内 ref.listen は fireImmediately 非対応）。
    // fireImmediately: true で初回プランにも反応し、従来の ref.watch と同じ初回挙動を保つ。
    ref.listenManual(
      geofenceMonitoringPlanProvider,
      (previous, next) {
        final service = ref.read(geofenceServiceProvider);
        if (!next.shouldMonitor) {
          service.stopMonitoring();
          return;
        }
        service.updateMonitoredData(
          locationsByGroupID: next.locationsByGroupID,
          activeListsByLocationID: next.activeListsByLocationID,
        );
        service.startMonitoring();
      },
      fireImmediately: true,
    );

    // サインアウト（Auth Stream が未サインインを流した）時に、push 済みの画面
    // (設定画面など) を全て pop してルートへ戻す。ルートの AuthResolver は同じ
    // Auth Stream を watch して AuthPage(サインイン画面) を表示するため、pop に
    // よってサインイン画面が前面に出る。signOut を呼ぶ各画面で個別に Navigator を
    // 操作せず、Auth Stream を一元監視して画面復帰を一箇所で行う。
    //
    // 購読を initState で1回だけ確立するのは geofence 監視と同じ理由。
    // previous がサインイン済み → next が未サインイン の遷移時のみ pop する
    // （起動直後の未サインイン状態で無駄に popUntil しないため）。
    // popUntil は既にルートのみなら no-op で冪等。
    ref.listenManual(
      firebaseUserChangesProvider,
      (previous, next) {
        final wasSignedIn = previous?.asData?.valueOrNull != null;
        final user = next.asData?.valueOrNull;
        // AuthResolver と同じ判定。非デバッグ時の匿名ユーザーは未サインイン扱い。
        final isSignedOut = user == null || (!kDebugMode && user.isAnonymous);
        if (wasSignedIn && isSignedOut) {
          _navigatorKey.currentState?.popUntil((route) => route.isFirst);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // appUserProvider は UserDatabaseResolver スコープ外では AsyncError になるが、
    // .asData?.value で安全に null フォールバックし、shu（朱）が使われる
    final accent = resolveAccentPreset(
        ref.watch(appUserProvider).asData?.value.themeColorHex);

    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: '買い物リスト',
      theme: buildAppTheme(brightness: Brightness.light, accent: accent),
      darkTheme: buildAppTheme(brightness: Brightness.dark, accent: accent),
      themeMode: ThemeMode.system,
      builder: (context, child) {
        Widget content = child ?? const SizedBox.shrink();
        if (kDebugMode) {
          content = ShakeDetectorWrapper(
            onShake: () => showDeveloperOptionsModal(
              Navigator.of(context, rootNavigator: true).context,
            ),
            child: content,
          );
        }
        // ToastOverlay は Navigator(=child) の外側・最前面に置く。
        // これによりダイアログ/ボトムシートの上にもトーストが表示される。
        return Stack(
          children: [
            content,
            const ToastOverlay(),
          ],
        );
      },
      home: const RootPage(),
    );
  }
}
