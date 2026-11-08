import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/toast/toast_overlay.dart';
import 'package:shoppinglist/l10n/l10n.dart';
import 'package:shoppinglist/features/developer_options/page.dart';
import 'package:shoppinglist/features/developer_options/shake_detector.dart';
import 'package:shoppinglist/provider/app_navigator_key.dart';
import 'package:shoppinglist/provider/app_user.dart';
import 'package:shoppinglist/provider/fcm_notification.dart';
import 'package:shoppinglist/provider/geofence.dart';
import 'package:shoppinglist/provider/theme_color.dart';
import 'package:shoppinglist/root.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/utils/config/feature_flags.dart';
import 'package:riverpod_annotation/experimental/scope.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:shoppinglist/provider/shopping_list.dart';
import 'package:shoppinglist/provider/user_developer_token_sync.dart';
import 'package:shoppinglist/provider/user_groups.dart';
import 'package:shoppinglist/features/resolver/auth.dart';
import 'package:shoppinglist/provider/bool_shared_preferences.dart';
import 'package:shoppinglist/provider/current_user_id.dart';
import 'package:shoppinglist/provider/shared_preferences.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/provider/string_shared_preferences.dart';
import 'package:shoppinglist/provider/default_group_update.dart';
import 'package:shoppinglist/provider/ai_usage.dart';
import 'package:shoppinglist/provider/group.dart';
import 'package:shoppinglist/provider/group_category.dart';
import 'package:shoppinglist/provider/group_user_profile.dart';
import 'package:shoppinglist/provider/receipt.dart';
import 'package:shoppinglist/provider/source_image.dart';
import 'package:shoppinglist/provider/shopping_location.dart';

/// アプリケーションのルートWidget。テーマカラー・ナビゲーション・FCM通知を管理する。
@Dependencies([
  geofenceMonitoringPlan,
  geofenceService,
  appUser,
  optionalAppUser,
  userDatabase,
  userDeveloperTokenSync,
  shoppingListAdd,
  shoppingLists,
  userGroups,
  currentUserID,
  addShoppingListItem,
  textShoppingListItems,
  StringSharedPreferences,
  firebaseUserChanges,
  sharedPreferences,
  BoolSharedPreferences,
  defaultGroupUpdate,
  remainingImageRecognitionCount,
  remainingURLRecognitionCount,
  shoppingListDuplicate,
  groupUserProfiles,
  shoppingListUpdate,
  group,
  groupUserProfileUpdate,
  sourceImages,
  receipts,
  groupCategoryAxes,
  shoppingLocations,
  groupCategoryAxisAdd,
  groupCategoryAdd,
  shoppingListItemBatchUpdate,
  groupCategories,
  themeColorUpdate,
  groupDatabase,
  addReceipt,
  updateReceipt,
  updateShoppingListItem,
  toggleShoppingListItemCheck,
  restoreShoppingListItem,
  deleteShoppingListItem,
  remainingCategorizeCount,
  aiCategorizeApply,
  groupCategoryBatchUpdate,
  moveItemCategoryKeyword,
  shareableGroupCategoryAxes,
  groupCategoryImportFromMember,
  groupCategoryDelete,
  shoppingLocationAdd,
  shoppingLocationUpdate,
  shoppingLocationDelete,
  groupCategoryUpdate,
])
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
    // 位置情報機能はファーストリリースでは非表示のため監視自体を確立しない (issue #465)。
    if (shoppingLocationFeatureEnabled) {
      ref.listenManual(geofenceMonitoringPlanProvider, (previous, next) {
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
      }, fireImmediately: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    // appUserProvider は UserDatabaseResolver スコープ外では AsyncError になるが、
    // .asData?.value で安全に null フォールバックし、shu（朱）が使われる
    final accent = resolveAccentPreset(
      ref.watch(appUserProvider).asData?.value.themeColorHex,
    );

    return MaterialApp(
      navigatorKey: appNavigatorKey,
      onGenerateTitle: (context) => context.l10n.appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // アプリはライトモード固定。darkTheme は提供しない（OS がダークでも常にライト表示）。
      theme: buildAppTheme(accent: accent),
      builder: (context, child) {
        Widget content = child ?? const SizedBox.shrink();
        if (kDebugMode) {
          content = ShakeDetectorWrapper(
            onShake:
                () => showDeveloperOptionsModal(
                  Navigator.of(context, rootNavigator: true).context,
                ),
            child: content,
          );
        }
        // ToastOverlay は toastProvider を監視し、root Navigator の Overlay
        // 最前面へトーストの OverlayEntry を積む。builder に常駐させるのは
        // route 遷移に依存せずアプリ起動から監視を確立するため。
        return Stack(children: [content, const ToastOverlay()]);
      },
      home: const RootPage(),
    );
  }
}
