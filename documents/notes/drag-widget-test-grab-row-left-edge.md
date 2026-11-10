---
scope: repository
recorded: 2026-11-10
---
# 買い物リストの行の長押しドラッグを widget test で動かす時は、行の中央ではなく左端をつかむ

買い物リストの行 (`TextShoppingListItemWidget`) を `ReorderableListView` の上で長押しドラッグする widget test で、`tester.getCenter(行)` の位置をつかむとドラッグが始まらず、`onReorder` が呼ばれなかった。

**なぜ:** 行の中央には `TextField` があり、長押しが文字の操作として処理される。

**どう使う:** `test/features/shopping_list/components/shopping_list_items/shopping_list_items_cross_category_test.dart` の形で書く。

- `tester.getRect(行).left + 6` の位置 (行の左の余白) を `startGesture` でつかむ
- `pump(600 ms)` で長押しを成立させた後、最初の 1 回を指のぶれの許容 (約 18 px) を超える `moveBy(Offset(0, 24))` で動かしてから、残りを移動する
- 行は `ValueKey('item_<id>')` で探す。`ValueKey('<id>')` は内側の `Dismissible` にも付いていて 2 つに一致する
