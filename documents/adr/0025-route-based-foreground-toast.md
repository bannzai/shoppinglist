# 0025. モーダル前面通知に route ベースのトーストを使う

## Status
Accepted

## Context
アイテム編集ボトムシート上で未課金ユーザーが「写真を追加」を押したとき、既存の
`ScaffoldMessenger` による SnackBar はシート背後に描画される。

既存の `MaterialApp.builder` 上の `ToastOverlay` はアプリ横断通知として動作するが、
ボトムシート表示中にユーザー操作から動的に表示した場合、シート前面へ合成されないケースが
iOS Simulator の検証で確認された。一方で `showDialog` のような route はシート前面に表示される。

## Decision
ボトムシートやダイアログの表示中にユーザー操作から動的に出す通知には、`PopupRoute` ベースの
前面トーストを使う。

既存の `ToastOverlay` と `showGlobalToast` はアプリ横断の通常通知として残し、モーダル前面表示が
必要な箇所は `showForegroundToastWidget` / `showForegroundActionToast` を使い分ける。

## Consequences
モーダルやボトムシートを閉じずに、通知を確実に前面へ表示できる。SnackBar と同じ短時間通知の
見た目を維持しつつ、アップグレードなどのアクションも載せられる。

一方で前面通知は Navigator に route を積むため、通常のグローバルトーストとはライフサイクルが
異なる。今後モーダル前面通知を追加する場合は、既存の `showGlobalToast` ではなく前面用 API を
選ぶ必要がある。
