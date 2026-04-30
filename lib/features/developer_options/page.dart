import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/developer_options/firestore_viewer_page.dart';
import 'package:shoppinglist/features/developer_options/provider.dart';
import 'package:shoppinglist/provider/app_user.dart';
import 'package:shoppinglist/provider/auth_claim.dart';
import 'package:shoppinglist/provider/current_user_id.dart';
import 'package:shoppinglist/provider/shopping_list.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shoppinglist/utils/functions/firebase_function.dart';
import 'package:shoppinglist/utils/purchase/purchase.dart';

/// 開発者オプションのモーダルボトムシートを表示する。
void showDeveloperOptionsModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => const _DeveloperOptionsSheet(),
  );
}

/// 開発者オプションを全画面ページとして表示する。
/// Maestro E2Eテストではモーダル内の要素を検出できないため、この関数を使用する。
void navigateToDeveloperOptionsPage(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const DeveloperOptionsPage(),
    ),
  );
}

/// モーダル表示用のラッパー。DraggableScrollableSheet を使用。
class _DeveloperOptionsSheet extends HookConsumerWidget {
  const _DeveloperOptionsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: _DeveloperOptionsContent(
            scrollController: scrollController,
          ),
        );
      },
    );
  }
}

/// 全画面ページ表示用。Scaffold + AppBar を使用。
class DeveloperOptionsPage extends StatelessWidget {
  const DeveloperOptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('開発者オプション')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: _DeveloperOptionsContent(),
      ),
    );
  }
}

class _DeveloperOptionsContent extends HookConsumerWidget {
  final ScrollController? scrollController;

  const _DeveloperOptionsContent({this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUID = ref.watch(currentUserIDProvider);
    final appUserAsync = ref.watch(appUserProvider);
    final defaultGroupID = appUserAsync.asData?.value.defaultGroupID;
    final debugUID = currentUID != null
        ? debugUserID(realUserID: currentUID, index: 1)
        : null;

    final itemMessage = useState('debug_item_test');
    final isProcessing = useState(false);
    final resultMessage = useState('');

    final customerInfo = ref.watch(customerInfoProvider).asData?.value;
    final revenueCatIsPremium = customerInfo?.isPremium ?? false;
    final firestoreIsPremium =
        ref.watch(firestoreIsPremiumProvider).asData?.value ?? false;
    // shoppingListsProviderをbuild内でwatchしてデータをロードする
    // （ref.readではAutoDisposeのStreamProviderがAsyncLoadingを返すため）
    final shoppingListsAsync = defaultGroupID != null
        ? ref.watch(shoppingListsProvider(
            groupID: defaultGroupID, isPremium: firestoreIsPremium))
        : null;
    final shoppingLists = shoppingListsAsync?.asData?.value ?? [];
    final firstShoppingListID =
        shoppingLists.isNotEmpty ? shoppingLists.first.id : null;

    final itemsAsync = (defaultGroupID != null && firstShoppingListID != null)
        ? ref.watch(textShoppingListItemsProvider(
            groupID: defaultGroupID,
            shoppingListID: firstShoppingListID,
            showChecked: false,
          ))
        : null;
    final items = itemsAsync?.asData?.value ?? <GroupShoppingListItem>[];

    return ListView(
      controller: scrollController,
      children: [
        Text(
          '開発者オプション',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),

        // Firestoreデータ確認
        _ActionTile(
          title: 'Firestoreデータ確認',
          subtitle: '自分に関連するFirestoreデータをJSON形式で閲覧',
          icon: Icons.storage,
          isProcessing: false,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FirestoreViewerPage(),
              ),
            );
          },
        ),
        const Divider(height: 24),
        const SizedBox(height: 8),
        Text('UID: ${currentUID ?? "不明"}',
            style: Theme.of(context).textTheme.bodySmall),
        Text('defaultGroupID: ${defaultGroupID ?? "なし"}',
            style: Theme.of(context).textTheme.bodySmall),
        Text('デバッグユーザーID: ${debugUID ?? "不明"}',
            style: Theme.of(context).textTheme.bodySmall),
        Text(
            'Premium(RC): $revenueCatIsPremium / Premium(Claims): $firestoreIsPremium',
            style: Theme.of(context).textTheme.bodySmall),
        if (resultMessage.value.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              resultMessage.value,
              style: TextStyle(
                color: resultMessage.value.contains('エラー')
                    ? Colors.red
                    : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        const Divider(height: 24),

        // プレミアム付与（RC Promotions API経由）
        _ActionTile(
          title: 'プレミアム付与（1日）',
          subtitle: 'RC Promo経由でプレミアムEntitlementを付与（dev環境のみ）',
          icon: Icons.star,
          isProcessing: isProcessing.value,
          onTap: () => _execute(
            isProcessing: isProcessing,
            resultMessage: resultMessage,
            action: () async {
              await functions.grantPromotionalPremium(duration: 'daily');
              // RC SDK のキャッシュを無効化してから fresh fetch する。
              // invalidate を挟まないと getCustomerInfo() が古いキャッシュを返し、
              // Promotional Entitlement の付与が UI に反映されない。
              await Purchases.invalidateCustomerInfoCache();
              await Purchases.getCustomerInfo();
              ref.invalidate(customerInfoProvider);
            },
            actionName: 'プレミアム付与',
          ),
        ),

        // プレミアム剥奪（RC Promotions API revoke 経由）
        _ActionTile(
          title: 'プレミアム剥奪',
          subtitle: 'RC Promo経由で付与したプレミアムEntitlementを取り消す（dev環境のみ）',
          icon: Icons.star_border,
          isProcessing: isProcessing.value,
          onTap: () => _execute(
            isProcessing: isProcessing,
            resultMessage: resultMessage,
            action: () async {
              await functions.revokePromotionalPremium();
              await Purchases.invalidateCustomerInfoCache();
              await Purchases.getCustomerInfo();
              ref.invalidate(customerInfoProvider);
            },
            actionName: 'プレミアム剥奪',
          ),
        ),

        const Divider(height: 24),

        // デバッグユーザー作成
        _ActionTile(
          title: 'デバッグユーザー作成',
          subtitle: 'Firestoreに /users/$debugUID を作成',
          icon: Icons.person_add,
          isProcessing: isProcessing.value,
          onTap: () => _execute(
            isProcessing: isProcessing,
            resultMessage: resultMessage,
            action: () => DebugUserCreate().call(debugUID: debugUID!),
            actionName: 'デバッグユーザー作成',
          ),
        ),

        // グループにデバッグユーザーを追加
        _ActionTile(
          title: 'グループにデバッグユーザーを追加',
          subtitle: 'memberUserIDsに追加 + プロフィール作成',
          icon: Icons.group_add,
          isProcessing: isProcessing.value,
          onTap: defaultGroupID == null
              ? null
              : () => _execute(
                    isProcessing: isProcessing,
                    resultMessage: resultMessage,
                    action: () => DebugUserAddToGroup().call(
                      debugUID: debugUID!,
                      groupID: defaultGroupID,
                    ),
                    actionName: 'グループ追加',
                  ),
        ),

        const Divider(height: 24),

        // アイテムメッセージ入力
        TextField(
          controller: TextEditingController(text: itemMessage.value),
          onChanged: (v) => itemMessage.value = v,
          decoration: const InputDecoration(
            labelText: 'アイテムメッセージ',
            isDense: true,
          ),
        ),
        const SizedBox(height: 8),

        // デバッグユーザーとしてアイテム追加
        _ActionTile(
          title: 'デバッグユーザーとしてアイテム追加',
          subtitle: 'アイテムを追加（リアルタイム同期で反映）',
          icon: Icons.add_shopping_cart,
          isProcessing: isProcessing.value,
          onTap: (defaultGroupID == null || firstShoppingListID == null)
              ? null
              : () => _execute(
                    isProcessing: isProcessing,
                    resultMessage: resultMessage,
                    action: () => ref
                        .read(addShoppingListItemProvider(
                            groupID: defaultGroupID))
                        .call(
                          shoppingListID: firstShoppingListID,
                          userID: debugUID!,
                          message: itemMessage.value,
                          order: items.nextOrder,
                          description: null,
                          color: null,
                        ),
                    actionName: 'アイテム追加',
                  ),
        ),

        const Divider(height: 24),

        // クリーンアップ
        _ActionTile(
          title: 'デバッグデータクリーンアップ',
          subtitle: 'デバッグユーザー関連データを全て削除',
          icon: Icons.cleaning_services,
          isProcessing: isProcessing.value,
          onTap: defaultGroupID == null
              ? null
              : () => _execute(
                    isProcessing: isProcessing,
                    resultMessage: resultMessage,
                    action: () => DebugUserCleanup().call(
                      debugUID: debugUID!,
                      groupID: defaultGroupID,
                    ),
                    actionName: 'クリーンアップ',
                  ),
        ),
      ],
    );
  }

  /// 操作を即時実行し、結果をページ上に表示する。
  /// ページは閉じない（Maestroが結果を確認してから手動で戻る）。
  Future<void> _execute({
    required ValueNotifier<bool> isProcessing,
    required ValueNotifier<String> resultMessage,
    required Future<void> Function() action,
    required String actionName,
  }) async {
    isProcessing.value = true;
    resultMessage.value = '';
    try {
      await action();
      resultMessage.value = '$actionName 完了';
      debugPrint('[DeveloperOptions] $actionName 完了');
    } catch (e) {
      resultMessage.value = '$actionName エラー: $e';
      debugPrint('[DeveloperOptions] $actionName エラー: $e');
    } finally {
      isProcessing.value = false;
    }
  }
}

class _ActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isProcessing;
  final VoidCallback? onTap;

  const _ActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isProcessing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Maestro E2Eテストがテキストを検出できるようにセマンティクスラベルを明示設定
    return Semantics(
      label: title,
      excludeSemantics: true,
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: isProcessing
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.play_arrow),
        onTap: isProcessing ? null : onTap,
      ),
    );
  }
}
