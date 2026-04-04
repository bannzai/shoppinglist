import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/group_shopping_location.dart';
import 'package:shoppinglist/features/shopping_location/location_picker_page.dart';
import 'package:shoppinglist/provider/shopping_location.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';
import 'package:shoppinglist/utils/purchase/purchase.dart';

class ShoppingLocationPage extends ConsumerWidget {
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
                leading: Icon(
                  location.latitude != null ? Icons.location_on : Icons.store,
                  color: location.latitude != null
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                title: Text(location.name),
                subtitle:
                    location.latitude != null ? const Text('位置情報設定済み') : null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        analytics.logEvent(
                            name: 'tap_edit_location',
                            parameters: {
                              'groupID': groupID,
                              'locationID': location.id
                            });
                        _showEditDialog(
                          context: context,
                          ref: ref,
                          location: location,
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete,
                          color: Theme.of(context).colorScheme.error),
                      onPressed: () {
                        analytics.logEvent(
                            name: 'tap_delete_location',
                            parameters: {
                              'groupID': groupID,
                              'locationID': location.id
                            });
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
          analytics.logEvent(
              name: 'tap_add_location', parameters: {'groupID': groupID});
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
    double? selectedLatitude;
    double? selectedLongitude;
    final isPremium =
        ref.read(customerInfoProvider).asData?.value.isPremium ?? false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('場所を追加'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: '場所の名前（例: スーパー）',
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.map),
                title: Text(selectedLatitude != null ? '位置設定済み' : '地図で場所を設定'),
                trailing: !isPremium
                    ? Icon(Icons.lock,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant)
                    : (selectedLatitude != null
                        ? const Icon(Icons.check, color: Colors.green)
                        : null),
                onTap: () async {
                  analytics.logEvent(
                    name: 'tap_set_location_on_map',
                  );
                  if (!isPremium) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('位置情報リマインダーはプレミアム機能です'),
                      ),
                    );
                    return;
                  }
                  final result = await Navigator.push<
                      ({double latitude, double longitude})>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LocationPickerPage(
                        initialLatitude: null,
                        initialLongitude: null,
                      ),
                    ),
                  );
                  if (result != null) {
                    setDialogState(() {
                      selectedLatitude = result.latitude;
                      selectedLongitude = result.longitude;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isEmpty) return;
                analytics.logEvent(
                    name: 'tap_confirm_add_location',
                    parameters: {'groupID': groupID});
                Navigator.pop(dialogContext);
                try {
                  await ref
                      .read(shoppingLocationAddProvider(groupID: groupID))
                      .call(
                        name: name,
                        latitude: selectedLatitude,
                        longitude: selectedLongitude,
                        geofenceRadiusMeters: null,
                      );
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
                analytics.logEvent(
                    name: 'cancel_add_location',
                    parameters: {'groupID': groupID});
                Navigator.pop(dialogContext);
              },
              child: const Text('キャンセル'),
            ),
          ],
        ),
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
              analytics.logEvent(
                  name: 'tap_save_location',
                  parameters: {'groupID': groupID, 'locationID': location.id});
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
              analytics.logEvent(
                  name: 'cancel_edit_location',
                  parameters: {'groupID': groupID, 'locationID': location.id});
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
              analytics.logEvent(
                  name: 'tap_confirm_del_location',
                  parameters: {'groupID': groupID, 'locationID': location.id});
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
            child: Text(
              '削除',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
          TextButton(
            onPressed: () {
              analytics.logEvent(
                  name: 'cancel_del_location',
                  parameters: {'groupID': groupID, 'locationID': location.id});
              Navigator.pop(dialogContext);
            },
            child: const Text('キャンセル'),
          ),
        ],
      ),
    );
  }
}
