# グローバルトースト (toast)

アプリ横断のトースト通知。ボトムシート/ダイアログの表示中でも前面に表示される。

## 仕組み

`ToastOverlay`（`MaterialApp.builder` に常駐）が `toastProvider` の state を監視し、
表示のたびに root Navigator の `Overlay` 最前面へ `OverlayEntry` を insert する。
`Overlay` のエントリは insert 時点の全 route（`showDialog` / `showModalBottomSheet` 含む）の
エントリより上に積まれるため、モーダル表示中の動的発火でも前面に描画される。

route（`Navigator.push`）で表示しないのは、トースト表示中の `Navigator.pop`
（シートの保存後クローズ等）がシートではなくトーストを pop してしまうため。
`OverlayEntry` は pop 履歴に載らない。詳細: `documents/adr/0025-overlay-entry-foreground-toast.md`

標準の `ScaffoldMessenger` の SnackBar は表示中ページの `Scaffold` 内に描画されるため
モーダルの背後に隠れる。モーダル/シート上で出す通知には本トーストを使うこと。

## 使い方

`showGlobalToast` / `showGlobalToastWidget` は `ref` も `BuildContext` も不要。`appProviderContainer`
（`main()` で `UncontrolledProviderScope` に渡したコンテナ）を内部で参照する。

```dart
import 'package:shoppinglist/components/toast/toast_overlay.dart';

// テキスト（タイトル任意）
showGlobalToast('保存しました', title: '完了');

// 任意 Widget（リッチ内容）
showGlobalToastWidget(MyRichContent(), duration: const Duration(seconds: 5));

// 本文 + アクションボタン（アップグレード導線等）
showGlobalToastWidget(
  ToastActionContent(
    message: '商品写真の添付はプレミアム機能です',
    actionLabel: 'アップグレード',
    onAction: () { /* ... */ },
  ),
  identity: 'item_photo_non_premium',
);

// 即座に消す
dismissGlobalToast();
```

- 表示中に再度呼ばれたら **最新で即置き換え**（単一表示）。
- `identity` が同一なら再 show を無視（重複抑止）。
- 既定で 5 秒後に自動消滅。

## 配置制約

`ToastOverlay` は root Navigator が作られる `MaterialApp.builder` 内に配置する
（`appNavigatorKey` で root Navigator の Overlay を参照するため）。
