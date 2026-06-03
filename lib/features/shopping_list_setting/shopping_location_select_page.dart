import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/primitives/app_cell.dart';
import 'package:shoppinglist/components/primitives/app_setting_section.dart';
import 'package:shoppinglist/provider/shopping_location.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';

/// `ShoppingListSettingPage` の「買い物する場所」Cell から遷移する選択画面。
/// 既存 locations + 「なし」を AppCell list で表示し、タップで選択結果 (`String?`) を
/// `Navigator.pop` で返す。`pop(null)` は「なし」を、`pop(<location.id>)` はその場所を表す。
/// 戻り値判別のため、AppBar の閉じるボタンと OS back は `pop(_sentinel)` で抜ける。
class ShoppingLocationSelectPage extends ConsumerWidget {
  final String groupID;
  final String? currentLocationID;

  const ShoppingLocationSelectPage({
    super.key,
    required this.groupID,
    required this.currentLocationID,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationsAsync = ref.watch(
      shoppingLocationsProvider(groupID: groupID),
    );
    final neutral = context.tokens.neutral;
    return Scaffold(
      backgroundColor: neutral.paper,
      appBar: AppBar(
        title: const Text('買い物する場所を選ぶ'),
        backgroundColor: neutral.paper,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: locationsAsync.when(
        data: (locations) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(0, 14, 0, 32),
          child: AppSettingSection(
            children: [
              AppCell(
                icon: Icons.block,
                title: 'なし',
                detail: currentLocationID == null ? '選択中' : null,
                onTap: () {
                  analytics.logEvent(
                    name: 'select_list_location',
                    parameters: {'groupID': groupID, 'value': 'none'},
                  );
                  Navigator.pop<_LocationSelectResult>(
                    context,
                    const _LocationSelectResult(null),
                  );
                },
                onSwitch: null,
                subtitle: null,
                switchValue: null,
              ),
              for (final location in locations)
                AppCell(
                  icon: Icons.place_outlined,
                  title: location.name,
                  detail: currentLocationID == location.id ? '選択中' : null,
                  onTap: () {
                    analytics.logEvent(
                      name: 'select_list_location',
                      parameters: {
                        'groupID': groupID,
                        'locationID': location.id,
                      },
                    );
                    Navigator.pop<_LocationSelectResult>(
                      context,
                      _LocationSelectResult(location.id),
                    );
                  },
                  onSwitch: null,
                  subtitle: null,
                  switchValue: null,
                ),
            ],
          ),
        ),
        error: (e, st) => Center(child: Text(e.toString())),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

/// `Navigator.pop` で「明示的に選択された」結果を返すための marker。
/// `pop(null)` (画面戻し) と `pop(_LocationSelectResult(null))` (「なし」明示選択) を
/// 区別するために使用する。
class _LocationSelectResult {
  /// 選択された location.id。`null` は「なし」を表す。
  final String? locationID;
  const _LocationSelectResult(this.locationID);
}

/// `ShoppingLocationSelectPage` を起動し、明示的に選択された場合のみ
/// `(true, locationID)` を返すヘルパー。画面戻しの場合は `(false, null)`。
Future<({bool changed, String? locationID})> pushShoppingLocationSelectPage({
  required BuildContext context,
  required String groupID,
  required String? currentLocationID,
}) async {
  final result = await Navigator.push<_LocationSelectResult>(
    context,
    MaterialPageRoute(
      builder: (_) => ShoppingLocationSelectPage(
        groupID: groupID,
        currentLocationID: currentLocationID,
      ),
    ),
  );
  if (result == null) {
    return (changed: false, locationID: null);
  }
  return (changed: true, locationID: result.locationID);
}
