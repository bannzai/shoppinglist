# 0025. グローバルトーストを route ベースで前面表示する

## Status
Accepted

## Context
アイテム編集ボトムシート上で未課金ユーザーが「写真を追加」を押したとき、既存の
`ScaffoldMessenger` による SnackBar はシート背後に描画される。

既存の `MaterialApp.builder` 上の `ToastOverlay` はアプリ横断通知として動作するが、
ボトムシート表示中にユーザー操作から動的に表示した場合、シート前面へ合成されないケースが
iOS Simulator の検証で確認された。一方で `showDialog` のような route はシート前面に表示される。

## Decision
ボトムシートやダイアログの表示中にユーザー操作から動的に出す通知も、既存の
`showGlobalToast` / `showGlobalToastWidget` を入口にする。

`toastProvider` は引き続き表示内容・自動消滅・identity による重複抑止を管理し、`ToastOverlay` は
その state を監視して root Navigator の最前面へトースト用 route を積む。これにより、呼び出し側は
通知の表示先を意識せず、既存のグローバルトースト API を使い続けられる。

## Consequences
モーダルやボトムシートを閉じずに、通知を確実に前面へ表示できる。SnackBar と同じ短時間通知の
見た目を維持しつつ、アップグレードなどのアクションも載せられる。

一方で表示層は Navigator に route を積むため、root Navigator key が初期化されていることが前提に
なる。`ToastOverlay` は `MaterialApp.builder` 内に常駐させ、provider state と route を同期する。
