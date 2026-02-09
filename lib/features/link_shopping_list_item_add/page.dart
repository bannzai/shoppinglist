import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/error/alert.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';
import 'package:shoppinglist/style/color.dart';
import 'package:metadata_fetch/metadata_fetch.dart';

class LinkShoppingListItemAddPage extends HookConsumerWidget {
  final String shoppingListID;
  final LinkGroupShoppingListItem linkShoppingListItem;
  final List<GroupShoppingListItem> shoppingListItems;
  const LinkShoppingListItemAddPage({
    super.key,
    required this.shoppingListID,
    required this.linkShoppingListItem,
    required this.shoppingListItems,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textEditingController = useTextEditingController();
    final focusNode = useFocusNode();
    final addLinkShoppingListItem = ref.watch(addLinkShoppingListItemProvider);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (linkShoppingListItem.url.isEmpty) {
          focusNode.requestFocus();
        }
      });
      return null;
    }, []);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('ECサイトメモを作成しましょう！',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text('URL:'),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      hintText: 'https://www.example.com',
                      hintStyle: TextStyle(color: TextColor.lightGray),
                    ),
                    onSubmitted: (v) async {
                      final url = v.trim();
                      if (url.isEmpty) {
                        return;
                      }
                      if (!url.startsWith('https://') &&
                          !url.startsWith('http://')) {
                        return;
                      }
                      try {
                        final metadata = await MetadataFetch.extract(url);
                        final title = metadata?.title;
                        final description = metadata?.description;
                        final imageURL = metadata?.image;

                        await addLinkShoppingListItem(
                          shoppingListID: shoppingListID,
                          url: url,
                          metadataTitle: title,
                          metadataDescription: description,
                          metadataImageURL: imageURL,
                          order: shoppingListItems.length,
                        );
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          showErrorAlert(context, e);
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
