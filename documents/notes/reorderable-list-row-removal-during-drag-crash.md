---
scope: cross-repository
recorded: 2026-11-10
---
# `ReorderableListView` のドラッグ中に行を消すと GlobalKey の重複でクラッシュする。同じ key のまま中身を `SizedBox.shrink` に替える

買い物リストで、セクションをドラッグしている間にそのセクションの行を畳む実装をした時に実測した。ドラッグ中 (`onReorderStart` の後) に行を取り除いて index をずらすと、`Multiple widgets used the same GlobalKey` でクラッシュした。

**なぜ:** material の `ReorderableListView` は、各行を行の key から作った GlobalKey で包む。Sliver は index で子を作り直すため、古い index の要素が残ったまま、同じ GlobalKey が新しい index で作られる。

**どう使う:**

- ドラッグ中に行を消したい時は、行を取り除かず、同じ key のまま中身だけを `SizedBox.shrink(key: ...)` に替える (`lib/features/shopping_list/components/shopping_list_items/shopping_list_items.dart` がこの形)。行の数と index が変わらなければ重複は起きず、見た目は畳んだ状態になる
- 落とした位置から意味 (どのセクションか) を決める処理は、見出しの数を数えるなど、高さ 0 の行が挟まっても結果が変わらない作りにする
- `proxyDecorator` は元の行より背の高い Widget を返してよい (見出しと数件の行を見せる等)
- 同じ位置に落とした時は `onReorder` が呼ばれない。ポインタがキャンセルされた時は `onReorder` も `onReorderEnd` も呼ばれない。後始末は `onReorderEnd` と、外側の `Listener(onPointerCancel)` の両方に置く
