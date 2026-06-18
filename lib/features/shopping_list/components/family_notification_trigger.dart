import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/toast/toast_overlay.dart';
import 'package:shoppinglist/features/shopping_list/components/notification_member_bar.dart';
import 'package:shoppinglist/provider/bool_shared_preferences.dart';
import 'package:shoppinglist/provider/current_user_id.dart';
import 'package:shoppinglist/provider/group_user_profile.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/utils/functions/firebase_function.dart';
import 'package:shoppinglist/utils/shared_preferences/keys.dart';

/// 表示中の買い物リストに対する「自分(ローカル端末)の変更」を検知して、家族へ通知を促す
/// トースト([NotificationMemberBar])の表示と、バックグラウンド遷移時の自動通知を担う。
/// 画面には何も描画しない(SizedBox.shrink)常駐トリガー。
///
/// 機能の要望は「自分の変更を相手(他メンバー)に知らせたい」こと。よって通知を促すのは
/// 自分が変更した時のみで、他メンバーの変更が Firestore stream で同期されてきても発火しない。
/// 「相手が編集したのに自分に通知バーが出る」(Issue #430)を防ぐため、トリガーは stream の
/// 任意の更新ではなく、[localShoppingListItemEditCountProvider]
/// (hasPendingWrites=自分の書き込み)由来のローカル編集回数のみを使う。
class FamilyNotificationTrigger extends HookConsumerWidget {
  final String groupID;
  final String shoppingListID;
  final String? shoppingListName;

  const FamilyNotificationTrigger({
    super.key,
    required this.groupID,
    required this.shoppingListID,
    required this.shoppingListName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserID = ref.watch(currentUserIDProvider);
    final memberProfiles =
        ref.watch(groupUserProfilesProvider(groupID: groupID)).asData?.value ??
        [];
    final autoNotify = ref.watch(
      boolSharedPreferencesProvider(key: BoolKey.autoNotifyShoppingListUpdate),
    );
    final localEditCount =
        ref
            .watch(
              localShoppingListItemEditCountProvider(
                groupID: groupID,
                shoppingListID: shoppingListID,
              ),
            )
            .valueOrNull ??
        0;

    // 自動通知のために保持する「未通知のローカル変更件数」。Provider 側のカウンタは
    // バックグラウンド送信後に 0 へ戻せないため、リセット可能なローカル state を別に持つ。
    final pendingEditCount = useState(0);

    // ローカル(自分の端末)の変更が検知されるたびに未通知カウントを増やす。
    // localEditCount は hasPendingWrites=true の snapshot(=自分の書き込み)時のみ増えるため、
    // 他メンバーの変更が stream 同期されてきても増えない。これにより「自分が変更した時だけ」
    // 通知バー/自動通知が出る(Issue #430)。
    // 依存配列は localEditCount のみ — その増加イベントだけをトリガーにする。
    useEffect(() {
      if (localEditCount > 0) {
        pendingEditCount.value++;
      }
      return null;
    }, [localEditCount]);

    // 未通知のローカル変更(1件以上)で家族通知バーをグローバルトーストで表示する。
    // モーダル表示中でも最前面に出すためグローバルトースト経由。他メンバーが居る時だけ表示する。
    // 依存配列は pendingEditCount.value のみ — 変更回数の増加イベントだけをトリガーにする。
    useEffect(() {
      if (pendingEditCount.value > 0 && currentUserID != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) {
            return;
          }
          if (!memberProfiles.any((p) => p.userID != currentUserID)) {
            return;
          }
          showGlobalToastWidget(
            NotificationMemberBar(
              groupID: groupID,
              shoppingListID: shoppingListID,
              shoppingListName: shoppingListName,
              currentUserID: currentUserID,
              memberProfiles: memberProfiles,
            ),
            // 同一リストの更新通知は内容が同一。連続更新でトーストが消えなくなるのを防ぐため
            // identity でまとめる。
            identity: 'member_bar $shoppingListID',
          );
        });
      }
      return null;
    }, [pendingEditCount.value]);

    // 自動通知: アプリが background(paused)へ移る時に未通知のローカル変更があれば家族へ送る。
    // autoNotify 設定 OFF / 未ログイン時は監視しない。依存配列の値が変わったら古い
    // AppLifecycleListener を破棄して張り直す。
    useEffect(() {
      if (!autoNotify || currentUserID == null) {
        return null;
      }
      final listener = AppLifecycleListener(
        onStateChange: (state) {
          if (state == AppLifecycleState.paused && pendingEditCount.value > 0) {
            final otherMemberIDs =
                memberProfiles
                    .where((p) => p.userID != currentUserID)
                    .map((p) => p.userID)
                    .toList();
            if (otherMemberIDs.isEmpty) {
              return;
            }
            functions.sendShoppingListUpdateNotification(
              groupID: groupID,
              shoppingListID: shoppingListID,
              shoppingListName: shoppingListName,
              targetUserIDs: otherMemberIDs,
            );
            pendingEditCount.value = 0;
          }
        },
      );
      return listener.dispose;
    }, [autoNotify, currentUserID, memberProfiles]);

    return const SizedBox.shrink();
  }
}
