import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/developer_options/firestore_viewer_page.dart';
import 'package:shoppinglist/features/developer_options/provider.dart';
import 'package:shoppinglist/features/shopping_list/components/create_list_spotlight.dart';
import 'package:shoppinglist/provider/app_user.dart';
import 'package:shoppinglist/provider/current_user_id.dart';
import 'package:shoppinglist/provider/shopping_list.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/provider/string_shared_preferences.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shoppinglist/utils/functions/firebase_function.dart';
import 'package:shoppinglist/utils/purchase/purchase.dart';
import 'package:shoppinglist/utils/shared_preferences/keys.dart';

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
    MaterialPageRoute(builder: (context) => const DeveloperOptionsPage()),
  );
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
          child: _DeveloperOptionsContent(scrollController: scrollController),
        );
      },
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
    final debugUID =
        currentUID != null
            ? debugUserID(realUserID: currentUID, index: 1)
            : null;

    final itemMessage = useState('debug_item_test');
    final isProcessing = useState(false);
    final resultMessage = useState('');

    final customerInfo = ref.watch(customerInfoProvider).asData?.value;
    final revenueCatIsPremium = customerInfo?.isPremium ?? false;
    // ④ Paywall 診断用: Offering / Package 構成のダンプ（確認後に削除可）。
    // 月額・年額が default(/current) Offering に標準 PackageType で入っているか確認する。
    final offerings = ref.watch(offeringsProvider).asData?.value;
    final offeringsDump =
        offerings == null
            ? 'Offerings: 取得中/未取得'
            : [
              'Offerings.all: ${offerings.all.keys.join(', ')}',
              'current: ${offerings.current?.identifier ?? 'なし'}',
              for (final entry in offerings.all.entries)
                for (final package in entry.value.availablePackages)
                  '[${entry.key}] ${package.identifier} / ${package.packageType.name} / ${package.storeProduct.identifier}',
            ].join('\n');
    // shoppingListsProviderをbuild内でwatchしてデータをロードする
    // （ref.readではAutoDisposeのStreamProviderがAsyncLoadingを返すため）
    final shoppingListsAsync =
        defaultGroupID != null
            ? ref.watch(
              shoppingListsProvider(
                groupID: defaultGroupID,
                isPremium: revenueCatIsPremium,
              ),
            )
            : null;
    final shoppingLists = shoppingListsAsync?.asData?.value ?? [];
    final firstShoppingListID =
        shoppingLists.isNotEmpty ? shoppingLists.first.id : null;

    // defaultGroupID は未参加ユーザーで null になり得るため、その間はキャプチャできない。
    // onTap は defaultGroupID == null の間 null ガード済みなので addShoppingListItem! で参照する。
    final addShoppingListItem =
        defaultGroupID != null
            ? ref.watch(addShoppingListItemProvider(groupID: defaultGroupID))
            : null;

    final itemsAsync =
        (defaultGroupID != null && firstShoppingListID != null)
            ? ref.watch(
              textShoppingListItemsProvider(
                groupID: defaultGroupID,
                shoppingListID: firstShoppingListID,
              ),
            )
            : null;
    final items = itemsAsync?.asData?.value ?? <GroupShoppingListItem>[];

    // リスト追加スポットライト(Issue #494)のデバッグ操作用。build 内で notifier をキャプチャする。
    final debugForceSpotlightNotifier = ref.watch(
      debugForceCreateListSpotlightProvider.notifier,
    );
    final spotlightPrefsNotifier = ref.watch(
      stringSharedPreferencesProvider(
        key: StringKey.createListSpotlightLastShownDateTime,
      ).notifier,
    );

    return ListView(
      controller: scrollController,
      children: [
        Text('開発者オプション', style: Theme.of(context).textTheme.headlineSmall),
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
        Text(
          'UID: ${currentUID ?? "不明"}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          'defaultGroupID: ${defaultGroupID ?? "なし"}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          'デバッグユーザーID: ${debugUID ?? "不明"}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          'Premium(RC): $revenueCatIsPremium',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          'Offering 構成:\n$offeringsDump',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (resultMessage.value.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              resultMessage.value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color:
                    resultMessage.value.contains('エラー')
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
          onTap:
              () => _execute(
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

        // カテゴリロケーション順序設定（Maestro E2Eテスト用）
        _ActionTile(
          title: 'カテゴリロケーション順序設定（テスト用）',
          subtitle: '「肉」→「野菜」の順序を「テストスーパー」に設定（dev環境のみ）',
          icon: Icons.sort,
          isProcessing: isProcessing.value,
          onTap:
              defaultGroupID == null
                  ? null
                  : () => _execute(
                    isProcessing: isProcessing,
                    resultMessage: resultMessage,
                    action: () async {
                      await functions.setupTestCategoryLocationOrder(
                        groupID: defaultGroupID,
                        locationName: 'テストスーパー',
                        firstCategoryName: '肉',
                        secondCategoryName: '野菜',
                      );
                    },
                    actionName: 'カテゴリロケーション順序設定',
                  ),
        ),

        // プレミアム剥奪（RC Promotions API revoke 経由）
        _ActionTile(
          title: 'プレミアム剥奪',
          subtitle:
              'RC Promo経由で付与したプレミアムEntitlementを取り消す（dev環境のみ）。'
              'RevenueCat側の反映に数秒〜数十秒かかる場合があります',
          icon: Icons.star_border,
          isProcessing: isProcessing.value,
          onTap:
              () => _execute(
                isProcessing: isProcessing,
                resultMessage: resultMessage,
                action: () async {
                  await functions.revokePromotionalPremium();
                  await _refreshCustomerInfoUntilNotPremium(ref);
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
          onTap:
              () => _execute(
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
          onTap:
              defaultGroupID == null
                  ? null
                  : () => _execute(
                    isProcessing: isProcessing,
                    resultMessage: resultMessage,
                    action:
                        () => DebugUserAddToGroup().call(
                          debugUID: debugUID!,
                          groupID: defaultGroupID,
                        ),
                    actionName: 'グループ追加',
                  ),
        ),

        // デバッグユーザーのカテゴリ設定作成
        _ActionTile(
          title: 'デバッグユーザーのカテゴリ設定作成',
          subtitle: 'カテゴリ共有E2E用の「デバッグ売り場 / 共有野菜」を作成',
          icon: Icons.category_outlined,
          isProcessing: isProcessing.value,
          onTap:
              defaultGroupID == null
                  ? null
                  : () => _execute(
                    isProcessing: isProcessing,
                    resultMessage: resultMessage,
                    action:
                        () => DebugUserCategorySetup().call(
                          debugUID: debugUID!,
                          groupID: defaultGroupID,
                        ),
                    actionName: 'デバッグカテゴリ設定作成',
                  ),
        ),

        // デバッグユーザーにこの端末のFCMトークンを登録
        _ActionTile(
          title: 'デバッグユーザーにFCMトークン登録',
          subtitle: 'この端末のトークンを登録し、グループ通知のプッシュを自端末で受信検証できるようにする',
          icon: Icons.notifications_active,
          isProcessing: isProcessing.value,
          onTap:
              () => _execute(
                isProcessing: isProcessing,
                resultMessage: resultMessage,
                action:
                    () => DebugUserRegisterFcmToken().call(debugUID: debugUID!),
                actionName: 'FCMトークン登録',
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
          onTap:
              (defaultGroupID == null || firstShoppingListID == null)
                  ? null
                  : () => _execute(
                    isProcessing: isProcessing,
                    resultMessage: resultMessage,
                    action:
                        () => addShoppingListItem!.call(
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
          onTap:
              defaultGroupID == null
                  ? null
                  : () => _execute(
                    isProcessing: isProcessing,
                    resultMessage: resultMessage,
                    action:
                        () => DebugUserCleanup().call(
                          debugUID: debugUID!,
                          groupID: defaultGroupID,
                        ),
                    actionName: 'クリーンアップ',
                  ),
        ),

        const Divider(height: 24),

        // リスト追加スポットライト(Issue #494)を強制表示
        _ActionTile(
          title: 'リスト追加スポットライトを強制表示',
          subtitle: '買い物リスト画面に戻ると表示されます（条件を無視・履歴は汚しません）',
          icon: Icons.highlight,
          isProcessing: false,
          onTap: () {
            debugForceSpotlightNotifier.show();
            resultMessage.value = 'スポットライト強制表示をON。買い物リスト画面に戻ってください';
          },
        ),

        // リスト追加スポットライトの表示履歴をリセット
        _ActionTile(
          title: 'リスト追加スポットライト履歴をリセット',
          subtitle: '最終表示日時を削除し、条件を満たせば再表示できるようにする',
          icon: Icons.restore,
          isProcessing: isProcessing.value,
          onTap:
              () => _execute(
                isProcessing: isProcessing,
                resultMessage: resultMessage,
                action: () => spotlightPrefsNotifier.remove(),
                actionName: 'スポットライト履歴リセット',
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

  /// revokePromotionalPremium 完了直後、RevenueCatの購読者向けAPI
  /// （Purchases.getCustomerInfo() が参照する側）にサーバー側の反映遅延があり、
  /// invalidateCustomerInfoCache() + getCustomerInfo() を1回行うだけではPremiumの
  /// まま返ってくることがある（RevenueCat公式コミュニティで報告されている既知の挙動）。
  /// 非Premiumに変わるか上限回数（10回・約30秒）に達するまで再取得を繰り返す。
  /// Issue #474
  Future<void> _refreshCustomerInfoUntilNotPremium(WidgetRef ref) async {
    const maxAttempts = 10;
    const interval = Duration(seconds: 3);
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      await Purchases.invalidateCustomerInfoCache();
      final customerInfo = await Purchases.getCustomerInfo();
      ref.invalidate(customerInfoProvider);
      if (!customerInfo.isPremium) {
        return;
      }
      if (attempt < maxAttempts - 1) {
        await Future.delayed(interval);
      }
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
        trailing:
            isProcessing
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
