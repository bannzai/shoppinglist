import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/developer_options/provider.dart';
import 'package:shoppinglist/provider/app_user.dart';
import 'package:shoppinglist/provider/current_user_id.dart';
import 'package:shoppinglist/provider/shopping_list.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';

/// 開発者オプションのモーダルボトムシートを表示する。
void showDeveloperOptionsModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => const DeveloperOptionsPage(),
  );
}

class DeveloperOptionsPage extends HookConsumerWidget {
  const DeveloperOptionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUID = ref.watch(currentUserIDProvider);
    final appUserAsync = ref.watch(appUserProvider);
    final defaultGroupID = appUserAsync.asData?.value.defaultGroupID;
    final debugUID = currentUID != null
        ? debugUserID(realUserID: currentUID, index: 1)
        : null;

    final delaySeconds = useState(3);
    final itemMessage = useState('debug_item_test');
    final isProcessing = useState(false);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: scrollController,
            children: [
              Text(
                '開発者オプション',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text('UID: ${currentUID ?? "不明"}',
                  style: Theme.of(context).textTheme.bodySmall),
              Text('defaultGroupID: ${defaultGroupID ?? "なし"}',
                  style: Theme.of(context).textTheme.bodySmall),
              Text('デバッグユーザーID: ${debugUID ?? "不明"}',
                  style: Theme.of(context).textTheme.bodySmall),
              const Divider(height: 24),

              // 遅延秒数設定
              Row(
                children: [
                  const Text('遅延秒数:'),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 60,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      controller:
                          TextEditingController(text: '${delaySeconds.value}'),
                      onChanged: (v) {
                        final parsed = int.tryParse(v);
                        if (parsed != null && parsed >= 0) {
                          delaySeconds.value = parsed;
                        }
                      },
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      ),
                    ),
                  ),
                  const Text(' 秒'),
                ],
              ),
              const SizedBox(height: 16),

              // デバッグユーザー作成
              _ActionTile(
                title: 'デバッグユーザー作成',
                subtitle: 'Firestoreに /users/$debugUID を作成',
                icon: Icons.person_add,
                isProcessing: isProcessing.value,
                onTap: () => _executeWithDelay(
                  context: context,
                  delaySeconds: delaySeconds.value,
                  isProcessing: isProcessing,
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
                    : () => _executeWithDelay(
                          context: context,
                          delaySeconds: delaySeconds.value,
                          isProcessing: isProcessing,
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
                controller:
                    TextEditingController(text: itemMessage.value),
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
                subtitle: '遅延後にアイテムを追加（リアルタイム同期で反映）',
                icon: Icons.add_shopping_cart,
                isProcessing: isProcessing.value,
                onTap: defaultGroupID == null
                    ? null
                    : () => _executeWithDelayAddItem(
                          context: context,
                          ref: ref,
                          delaySeconds: delaySeconds.value,
                          isProcessing: isProcessing,
                          debugUID: debugUID!,
                          groupID: defaultGroupID,
                          message: itemMessage.value,
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
                    : () => _executeWithDelay(
                          context: context,
                          delaySeconds: delaySeconds.value,
                          isProcessing: isProcessing,
                          action: () => DebugUserCleanup().call(
                            debugUID: debugUID!,
                            groupID: defaultGroupID,
                          ),
                          actionName: 'クリーンアップ',
                        ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _executeWithDelay({
    required BuildContext context,
    required int delaySeconds,
    required ValueNotifier<bool> isProcessing,
    required Future<void> Function() action,
    required String actionName,
  }) {
    // モーダルを閉じる
    Navigator.of(context).pop();

    // 遅延後に実行
    Future.delayed(Duration(seconds: delaySeconds), () async {
      isProcessing.value = true;
      try {
        await action();
        debugPrint('[DeveloperOptions] $actionName 完了');
      } catch (e) {
        debugPrint('[DeveloperOptions] $actionName エラー: $e');
      } finally {
        isProcessing.value = false;
      }
    });
  }

  void _executeWithDelayAddItem({
    required BuildContext context,
    required WidgetRef ref,
    required int delaySeconds,
    required ValueNotifier<bool> isProcessing,
    required String debugUID,
    required String groupID,
    required String message,
  }) {
    // モーダルを閉じる
    Navigator.of(context).pop();

    // 遅延後に実行
    Future.delayed(Duration(seconds: delaySeconds), () async {
      isProcessing.value = true;
      try {
        // 既存の AddShoppingListItem を再利用
        final addItem = ref.read(addShoppingListItemProvider(groupID: groupID));
        // 現在のshoppingListのIDを取得
        final shoppingListsAsync =
            ref.read(shoppingListsProvider(groupID: groupID));
        final shoppingLists = shoppingListsAsync.asData?.value ?? [];
        if (shoppingLists.isEmpty) {
          debugPrint(
              '[DeveloperOptions] shoppingListが見つかりません。先にリストを作成してください。');
          return;
        }
        final shoppingListID = shoppingLists.first.id;

        // 現在のアイテム数を取得してorder算出
        final itemsAsync = ref.read(textShoppingListItemsProvider(
          groupID: groupID,
          shoppingListID: shoppingListID,
          showChecked: false,
        ));
        final items = itemsAsync.asData?.value ?? <GroupShoppingListItem>[];

        await addItem.call(
          shoppingListID: shoppingListID,
          userID: debugUID,
          message: message,
          order: items.nextOrder,
          description: null,
          color: null,
        );
        debugPrint('[DeveloperOptions] アイテム追加完了: $message (by $debugUID)');
      } catch (e) {
        debugPrint('[DeveloperOptions] アイテム追加エラー: $e');
      } finally {
        isProcessing.value = false;
      }
    });
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
    return ListTile(
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
    );
  }
}
