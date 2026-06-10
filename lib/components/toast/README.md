# グローバルトースト (toast)

アプリ横断のトースト通知。

## 通常のグローバルトースト

`MaterialApp.builder` の出力はウィジェットツリー上 `Navigator` の **外側（親）** に位置する。
`builder` に `ToastOverlay` を常駐させ、アプリ全体から `showGlobalToast` で通知を表示する。

標準の `ScaffoldMessenger` の SnackBar は表示中ページの `Scaffold` 内に描画されるため
モーダルの背後に隠れる。

`ToastOverlay` は `toastProvider` の state を監視し、root Navigator の最前面へトースト route を
積む。これにより、通常画面だけでなくボトムシートやダイアログの表示中でも同じ
`showGlobalToast` / `showGlobalToastWidget` で前面表示する。

## 使い方

`showGlobalToast` / `showGlobalToastWidget` は `ref` も `BuildContext` も不要。`appProviderContainer`
（`main()` で `UncontrolledProviderScope` に渡したコンテナ）を内部で参照する。

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

`ToastOverlay` は root Navigator が作られる `MaterialApp.builder` 内に配置する。
