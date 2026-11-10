---
scope: cross-repository
recorded: 2026-11-10
---
# Maestro で Flutter の長押しドラッグは、`duration: 10000` の遅い swipe で再現できる

2026-06-11 に、カテゴリのセクションの並べ替えの E2E (`maestro/flows/category_section_reorder.yaml`、Issue #386) で実測した。Maestro には「長押ししてからドラッグ」の専用のコマンドが無いが、Flutter の `ReorderableDelayedDragStartListener` (長押しの判定 500 ms、指のぶれの許容 18 pt) は次の swipe で動いた。

```yaml
- swipe:
    start: "30%, 21%"   # ドラッグする対象の上
    end: "30%, 40%"     # 落とす先
    duration: 10000
```

**なぜ:** swipe の移動は `duration` の全体に均等に割り振られる。`duration` を長くすると最初の 500 ms の移動量が許容の範囲に収まって長押しと判定され、その後の移動がドラッグとして扱われる。画面の高さの 18% (約 157 pt) を 10000 ms で動かすと、500 ms あたり約 8 pt になる。

**どう使う:** 長押しドラッグを Maestro で検証する時は上の形で書く。同じ flow で確かめた、Flutter のアプリを iOS で操作する時の点:

- `ReorderableListView` は各行を 1 つの要素にまとめ、ラベルが「見出し・件数・行の文言」を改行でつないだものになる。セレクタは `"(?s)乳製品.*"` のように `(?s)` を付けた正規表現にする
- 並び順は相対のセレクタで確かめる: `assertVisible: {text: "(?s)A.*", below: {text: "(?s)B.*"}}`
- iOS では `- back` は何もしない。戻る時は左上の戻るボタンを `tapOn: point: "5%,10%"` でタップするか、`- launchApp` で起動し直す
- Flutter の Widget の `Key()` は iOS のアクセシビリティの ID に出ないため、`id:` のセレクタは使えない。tooltip の文言 (例: 「リスト設定」) でタップする
