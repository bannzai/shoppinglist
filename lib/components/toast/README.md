# グローバルトースト (toast)

モーダル（ダイアログ/ボトムシート）の **上にも表示できる** アプリ横断のトースト通知。

## なぜモーダルの上に出るのか

`MaterialApp.builder` の出力はウィジェットツリー上 `Navigator` の **外側（親）** に位置する。
`builder` を `Stack` 化してその最前面に `ToastOverlay` を常駐させることで、`Navigator` の
Overlay に積まれる全 Route（`showDialog` / `showModalBottomSheet` 含む）より手前に描画される。

標準の `ScaffoldMessenger` の SnackBar は表示中ページの `Scaffold` 内に描画されるため
モーダルの背後に隠れる。本トーストはその制約を回避する。

## 使い方

`ref` も `BuildContext` も不要。`appProviderContainer`（`main()` で `UncontrolledProviderScope`
に渡したコンテナ）を内部で参照する。

```dart
import 'package:shoppinglist/components/toast/toast_overlay.dart';

// テキスト（タイトル任意）
showGlobalToast('保存しました', title: '完了');

// 任意 Widget（リッチ内容）
showGlobalToastWidget(MyRichContent(), duration: const Duration(seconds: 5));

// 即座に消す
dismissGlobalToast();
```

- 表示中に再度呼ばれたら **最新で即置き換え**（単一表示）。
- 既定で 5 秒後に自動消滅。

## 配置制約

`ToastOverlay` のルートは `Positioned` なので、`Stack` の直接の子として配置する
（`lib/app.dart` の `MaterialApp.builder` 内）。
