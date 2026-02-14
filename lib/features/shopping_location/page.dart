import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/group_shopping_location.dart';
import 'package:shoppinglist/provider/shopping_location.dart';
import 'package:shoppinglist/style/color.dart';

class ShoppingLocationPage extends HookConsumerWidget {
  final String groupID;

  const ShoppingLocationPage({
    super.key,
    required this.groupID,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationsAsync =
        ref.watch(shoppingLocationsProvider(groupID: groupID));

    return Scaffold(
      appBar: AppBar(
        title: const Text('買い物する場所'),
      ),
      body: locationsAsync.when(
        data: (locations) {
          if (locations.isEmpty) {
            return const Center(
              child: Text('買い物する場所がまだありません'),
            );
          }
          return ListView.builder(
            itemCount: locations.length,
            itemBuilder: (context, index) {
              final location = locations[index];
              return ListTile(
                leading: const Icon(Icons.store),
                title: Text(location.name),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        _showEditDialog(
                          context: context,
                          ref: ref,
                          location: location,
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete,
                          color: TextColor.danger),
                      onPressed: () {
                        _showDeleteDialog(
                          context: context,
                          ref: ref,
                          location: location,
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        error: (e, st) => Center(child: Text(e.toString())),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddDialog(context: context, ref: ref);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog({
    required BuildContext context,
    required WidgetRef ref,
  }) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('場所を追加'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '場所の名前（例: スーパー）',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(dialogContext);
              try {
                await ref
                    .read(shoppingLocationAddProvider(groupID: groupID))
                    .call(name: name);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              }
            },
            child: const Text('追加'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: const Text('キャンセル'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog({
    required BuildContext context,
    required WidgetRef ref,
    required GroupShoppingLocation location,
  }) {
    final controller = TextEditingController(text: location.name);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('場所を編集'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '場所の名前',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(dialogContext);
              try {
                await ref
                    .read(shoppingLocationUpdateProvider(groupID: groupID))
                    .call(
                      shoppingLocationID: location.id,
                      shoppingLocation: location.copyWith(name: name),
                    );
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              }
            },
            child: const Text('保存'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: const Text('キャンセル'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog({
    required BuildContext context,
    required WidgetRef ref,
    required GroupShoppingLocation location,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('「${location.name}」を削除しますか？'),
        content: const Text('この場所を削除しても、この場所が設定されている買い物リストには影響しません'),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await ref
                    .read(shoppingLocationDeleteProvider(groupID: groupID))
                    .call(shoppingLocationID: location.id);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              }
            },
            child: const Text(
              '削除',
              style: TextStyle(color: TextColor.danger),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: const Text('キャンセル'),
          ),
        ],
      ),
    );
  }
}
