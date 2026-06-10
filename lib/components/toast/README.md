# グローバルトースト (toast)

アプリ横断のトースト通知。

## 通常のグローバルトースト

`MaterialApp.builder` の出力はウィジェットツリー上 `Navigator` の **外側（親）** に位置する。
`builder` を `Stack` 化してその最前面に `ToastOverlay` を常駐させ、アプリ全体から
`showGlobalToast` で通知を表示する。

標準の `ScaffoldMessenger` の SnackBar は表示中ページの `Scaffold` 内に描画されるため
モーダルの背後に隠れる。

## モーダル/シート前面に出す通知

ボトムシートやダイアログの表示中にユーザー操作で動的に出す通知は、route として積む
`showForegroundToastWidget` / `showForegroundActionToast` を使う。`ToastOverlay` の状態更新では、
シート表示中の動的出現が前面に合成されないケースがあるため。

## 使い方

`showGlobalToast` / `showGlobalToastWidget` は `ref` も `BuildContext` も不要。
`appProviderContainer`（`main()` で `UncontrolledProviderScope` に渡したコンテナ）を内部で参照する。
`showForegroundToastWidget` / `showForegroundActionToast` は前面に route を積むため `BuildContext`
を渡す。

```dart
import 'package:shoppinglist/components/toast/toast_overlay.dart';

// テキスト（タイトル任意）
showGlobalToast('保存しました', title: '完了');

// 任意 Widget（リッチ内容）
showGlobalToastWidget(MyRichContent(), duration: const Duration(seconds: 5));

// モーダル/シート前面に出すアクション付き通知
showForegroundActionToast(
  context: context,
  message: '商品写真の添付はプレミアム機能です',
  actionLabel: 'アップグレード',
  onAction: () => showPaywall(context: context),
);

// 即座に消す
dismissGlobalToast();
```

- 表示中に再度呼ばれたら **最新で即置き換え**（単一表示）。
- 既定で 5 秒後に自動消滅。
- 上記の単一表示制御は `showGlobalToast` / `showGlobalToastWidget` の挙動。

## 配置制約

`ToastOverlay` のルートは `Positioned` なので、`Stack` の直接の子として配置する
（`lib/app.dart` の `MaterialApp.builder` 内）。
