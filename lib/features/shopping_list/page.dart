import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shoppinglist/components/admob/banner.dart';
import 'package:shoppinglist/components/error/retry_page.dart';
import 'package:shoppinglist/components/loading/loading.dart';
import 'package:shoppinglist/entity/group_shopping_list.dart';
import 'package:shoppinglist/features/shopping_list/components/app_bar.dart';
import 'package:shoppinglist/features/shopping_list/components/buttons/copy_multiline_text_button.dart';
import 'package:shoppinglist/features/shopping_list/components/buttons/image_picker_button.dart';
import 'package:shoppinglist/features/shopping_list/components/buttons/shopping_list_item_add_button.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/empty_text_shopping_list_item.dart';
import 'package:shoppinglist/features/shopping_list/components/shopping_list_items/shopping_list_items.dart';
import 'package:shoppinglist/provider/shopping_list.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/style/color.dart';

class ShoppingListPage extends HookConsumerWidget {
  const ShoppingListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shoppingLists = ref.watch(shoppingListsProvider);

    return Retry(
      retry: () => ref.invalidate(shoppingListsProvider),
      child: shoppingLists.when(
        data: (shoppingLists) => _Body(shoppingLists: shoppingLists),
        error: (e, st) => RetryPage(exception: e),
        loading: () => const Loading(),
      ),
    );
  }
}

class _Body extends HookConsumerWidget {
  final List<GroupShoppingList> shoppingLists;

  const _Body({required this.shoppingLists});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shoppingListID = useState(shoppingLists.first.id);
    final retry = Retry.of(context).retry;
    final showChecked = useState(true);
    final shoppingListItemsAsync = ref.watch(textShoppingListItemsProvider(
      shoppingListID: shoppingListID.value,
      showChecked: showChecked.value,
    ));
    final shoppingList =
        shoppingLists.firstWhereOrNull((sl) => sl.id == shoppingListID.value);
    final ttlExpiresDateTime = shoppingList?.ttlExpiresDateTime;

    // 削除した時にshoppingListIDを入れ替える
    useEffect(() {
      if (!shoppingLists.map((e) => e.id).contains(shoppingListID.value)) {
        final firstID = shoppingLists.firstOrNull?.id;
        if (firstID != null) {
          shoppingListID.value = firstID;
        }
      }
      return null;
    }, [shoppingLists.length]);

    // shoppingListIDが変わったらshoppingListsProviderから更新してWidgetツリーを更新
    useEffect(() {
      ref.invalidate(shoppingListsProvider);
      return null;
    }, [shoppingListID.value]);

    return Retry(
      retry: () {
        retry();
        ref.invalidate(textShoppingListItemsProvider(
            shoppingListID: shoppingListID.value,
            showChecked: showChecked.value));
      },
      child: Scaffold(
        appBar: ShoppingListAppBar(
          shoppingListID: shoppingListID,
          shoppingLists: shoppingLists,
          shoppingList: shoppingList,
          showChecked: showChecked,
          shoppingListItems: shoppingListItemsAsync.asData?.value ?? [],
        ),
        body: SafeArea(
          child: shoppingListItemsAsync.when(
            data: (shoppingListItems) {
              if (showChecked.value && shoppingListItems.isEmpty) {
                return EmptyTextShoppingListItems(
                    shoppingListID: shoppingListID.value,
                    shoppingListItems: shoppingListItems);
              } else {
                return Column(
                  children: [
                    if (ttlExpiresDateTime != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '※ この買い物リストは${DateFormat.MEd().format(ttlExpiresDateTime)}まで保存されてます',
                        style: const TextStyle(
                          color: TextColor.gray,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    Expanded(
                        child: ShoppingListItems(
                            shoppingListID: shoppingListID.value,
                            shoppingListItems: shoppingListItems,
                            shoppingListItemsAsync: shoppingListItemsAsync)),
                    const AdMobBanner(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                child: ShoppingListItemAddButton(
                                    shoppingListID: shoppingListID.value,
                                    shoppingListItems: shoppingListItems),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ImagePickerButton(
                                    shoppingListID: shoppingListID.value,
                                    shoppingListItems: shoppingListItems),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: CopyMultilineTextButton(
                                    shoppingListID: shoppingListID.value,
                                    shoppingListItems: shoppingListItems),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
            },
            error: (e, st) => RetryPage(exception: e),
            loading: () => const Loading(),
          ),
        ),
      ),
    );
  }
}
