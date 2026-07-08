import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/error/error_view.dart';
import 'package:shoppinglist/components/toast/toast_overlay.dart';
import 'package:shoppinglist/entity/group_shopping_location.dart';
import 'package:shoppinglist/features/paywall/paywall.dart';
import 'package:shoppinglist/features/shopping_location/location_picker_page.dart';
import 'package:shoppinglist/provider/shopping_location.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/error/error_display.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';
import 'package:shoppinglist/utils/purchase/purchase.dart';

class ShoppingLocationPage extends ConsumerWidget {
  final String groupID;

  const ShoppingLocationPage({super.key, required this.groupID});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationsAsync = ref.watch(
      shoppingLocationsProvider(groupID: groupID),
    );
    final isPremium =
        ref.watch(customerInfoProvider).asData?.value.isPremium ?? false;
    final shoppingLocationAdd = ref.watch(
      shoppingLocationAddProvider(groupID: groupID),
    );
    final shoppingLocationUpdate = ref.watch(
      shoppingLocationUpdateProvider(groupID: groupID),
    );
    final shoppingLocationDelete = ref.watch(
      shoppingLocationDeleteProvider(groupID: groupID),
    );
    final tokens = context.appTheme;
    final neutral = tokens.neutral;

    return Scaffold(
      backgroundColor: neutral.paper,
      appBar: AppBar(
        title: const Text('買い物する場所'),
        backgroundColor: neutral.paper,
      ),
      body: locationsAsync.when(
        data: (locations) {
          if (locations.isEmpty) {
            return Center(
              child: Container(
                margin: const EdgeInsets.all(32),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                decoration: BoxDecoration(
                  color: neutral.surface2,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: neutral.divider, width: 0.5),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.store, size: 36, color: neutral.ink3),
                    const SizedBox(height: 12),
                    Text(
                      '買い物する場所がまだありません',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: neutral.ink2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
            itemCount: locations.length,
            itemBuilder: (context, index) {
              final location = locations[index];
              final hasGeo = location.latitude != null;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: neutral.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: neutral.divider, width: 0.5),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: hasGeo ? tokens.accentSoft : neutral.surface2,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        hasGeo ? Icons.location_on : Icons.store,
                        size: 18,
                        color: hasGeo ? tokens.accent : neutral.ink3,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            location.name,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: neutral.ink,
                            ),
                          ),
                          if (hasGeo)
                            Text(
                              '位置情報設定済み',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: neutral.ink3),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit, color: neutral.ink3),
                      onPressed: () {
                        analytics.logEvent(
                          name: 'tap_edit_location',
                          parameters: {
                            'groupID': groupID,
                            'locationID': location.id,
                          },
                        );
                        _showEditDialog(
                          context: context,
                          shoppingLocationUpdate: shoppingLocationUpdate,
                          location: location,
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: neutral.danger),
                      onPressed: () {
                        analytics.logEvent(
                          name: 'tap_delete_location',
                          parameters: {
                            'groupID': groupID,
                            'locationID': location.id,
                          },
                        );
                        _showDeleteDialog(
                          context: context,
                          shoppingLocationDelete: shoppingLocationDelete,
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
        error: (e, st) => ErrorView(error: e, stackTrace: st),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: tokens.accent,
        foregroundColor: Colors.white,
        onPressed: () {
          analytics.logEvent(
            name: 'tap_add_location',
            parameters: {'groupID': groupID},
          );
          _showAddDialog(
            context: context,
            shoppingLocationAdd: shoppingLocationAdd,
            isPremium: isPremium,
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog({
    required BuildContext context,
    required ShoppingLocationAdd shoppingLocationAdd,
    required bool isPremium,
  }) {
    final controller = TextEditingController();
    double? selectedLatitude;
    double? selectedLongitude;
    String selectedAddress = '';

    showDialog(
      context: context,
      builder:
          (dialogContext) => StatefulBuilder(
            builder:
                (dialogContext, setDialogState) => AlertDialog(
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
                        title: Text(
                          selectedLatitude != null ? '位置設定済み' : '地図で場所を設定',
                        ),
                        trailing:
                            !isPremium
                                ? Icon(
                                  Icons.lock,
                                  size: 16,
                                  color: context.appTheme.neutral.ink3,
                                )
                                : (selectedLatitude != null
                                    ? Icon(
                                      Icons.check,
                                      color: context.appTheme.neutral.ok,
                                    )
                                    : null),
                        onTap: () async {
                          analytics.logEvent(
                            name: 'tap_set_location_on_map',
                            parameters: null,
                          );
                          if (!isPremium) {
                            // ダイアログ上の SnackBar は背後の Scaffold に描画されて
                            // 見えないため、前面に出るグローバルトーストで通知する。
                            // ダイアログが閉じられた後でもアクションからペイウォールを
                            // 開けるよう、生存し続ける root Navigator の context を束ねる。
                            final paywallContext =
                                Navigator.of(
                                  context,
                                  rootNavigator: true,
                                ).context;
                            showGlobalActionToast(
                              message: '位置情報リマインダーはプレミアム機能です',
                              actionLabel: 'アップグレード',
                              onAction:
                                  () => showPaywall(context: paywallContext),
                            );
                            return;
                          }
                          final result = await Navigator.push<
                            ({
                              double latitude,
                              double longitude,
                              String address,
                            })
                          >(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => const LocationPickerPage(
                                    initialLatitude: null,
                                    initialLongitude: null,
                                  ),
                            ),
                          );
                          if (result != null) {
                            setDialogState(() {
                              selectedLatitude = result.latitude;
                              selectedLongitude = result.longitude;
                              selectedAddress = result.address;
                            });
                          }
                        },
                      ),
                      if (selectedAddress.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          selectedAddress,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: context.appTheme.neutral.ink3),
                        ),
                      ],
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () async {
                        final name = controller.text.trim();
                        if (name.isEmpty) {
                          return;
                        }
                        analytics.logEvent(
                          name: 'tap_confirm_add_location',
                          parameters: {'groupID': groupID},
                        );
                        Navigator.pop(dialogContext);
                        try {
                          await shoppingLocationAdd.call(
                            name: name,
                            address: selectedAddress,
                            latitude: selectedLatitude,
                            longitude: selectedLongitude,
                            geofenceRadiusMeters: null,
                          );
                        } catch (e, st) {
                          if (context.mounted) {
                            showErrorSnackBar(context, e, st);
                          }
                        }
                      },
                      child: const Text('追加'),
                    ),
                    TextButton(
                      onPressed: () {
                        analytics.logEvent(
                          name: 'cancel_add_location',
                          parameters: {'groupID': groupID},
                        );
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
    required ShoppingLocationUpdate shoppingLocationUpdate,
    required GroupShoppingLocation location,
  }) {
    final controller = TextEditingController(text: location.name);
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('場所を編集'),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(hintText: '場所の名前'),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  final name = controller.text.trim();
                  if (name.isEmpty) {
                    return;
                  }
                  analytics.logEvent(
                    name: 'tap_save_location',
                    parameters: {'groupID': groupID, 'locationID': location.id},
                  );
                  Navigator.pop(dialogContext);
                  try {
                    await shoppingLocationUpdate.call(
                      shoppingLocationID: location.id,
                      shoppingLocation: location.copyWith(name: name),
                    );
                  } catch (e, st) {
                    if (context.mounted) {
                      showErrorSnackBar(context, e, st);
                    }
                  }
                },
                child: const Text('保存'),
              ),
              TextButton(
                onPressed: () {
                  analytics.logEvent(
                    name: 'cancel_edit_location',
                    parameters: {'groupID': groupID, 'locationID': location.id},
                  );
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
    required ShoppingLocationDelete shoppingLocationDelete,
    required GroupShoppingLocation location,
  }) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text('「${location.name}」を削除しますか？'),
            content: const Text('この場所を削除しても、この場所が設定されている買い物リストには影響しません'),
            actions: [
              TextButton(
                onPressed: () async {
                  analytics.logEvent(
                    name: 'tap_confirm_del_location',
                    parameters: {'groupID': groupID, 'locationID': location.id},
                  );
                  Navigator.pop(dialogContext);
                  try {
                    await shoppingLocationDelete.call(
                      shoppingLocationID: location.id,
                    );
                  } catch (e, st) {
                    if (context.mounted) {
                      showErrorSnackBar(context, e, st);
                    }
                  }
                },
                child: Text(
                  '削除',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.appTheme.neutral.danger,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  analytics.logEvent(
                    name: 'cancel_del_location',
                    parameters: {'groupID': groupID, 'locationID': location.id},
                  );
                  Navigator.pop(dialogContext);
                },
                child: const Text('キャンセル'),
              ),
            ],
          ),
    );
  }
}
