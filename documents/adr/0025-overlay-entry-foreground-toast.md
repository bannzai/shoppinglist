# 0025. グローバルトーストは root Navigator の Overlay へ OverlayEntry で前面表示する

## Status
Accepted

## Context
アイテム編集ボトムシート上で未課金ユーザーが「写真を追加」を押したとき、既存の
`ScaffoldMessenger` による SnackBar はシート背後のページの `Scaffold` に描画され、シートに隠れて見えない。

`MaterialApp.builder` の `Stack` 最前面に `ToastOverlay` を常駐させる旧方式は、起動時から
常設の Widget はモーダル前面に出るものの、モーダル表示中に provider の状態変化で動的に
出現させたトーストが描画されないケースが iOS Simulator の検証で確認された（根本原因未特定）。

その後、root Navigator へ route（`OverlayRoute`）を push する方式で前面表示は実現できたが、
トースト表示中はトースト route が Navigator スタックの最上位になるため、シートの保存・削除後の
`Navigator.pop` がシートではなくトーストを pop してしまう（PR #378 レビュー指摘）。
通知のために Navigator の pop 履歴を汚す設計は成立しない。

## Decision
ボトムシートやダイアログの表示中に動的に出す通知も、既存の
`showGlobalToast` / `showGlobalToastWidget` を入口にする。

`toastProvider` は引き続き表示内容・自動消滅・identity による重複抑止を管理し、`ToastOverlay` は
その state を監視して、表示のたびに root Navigator の `Overlay` 最前面へ `OverlayEntry` を
insert する。`OverlayEntry` は insert 時点の全 route（`showDialog` / `showModalBottomSheet` 含む）の
エントリより上に積まれるため前面に描画され、かつ Navigator の pop 履歴には載らない。

## Consequences
モーダルやボトムシートを閉じずに通知を確実に前面へ表示でき、トースト表示中の
`Navigator.pop` は従来どおり最上位の route（シート等）を閉じる。トースト以外の領域は
タップを透過するため、背後のシート操作も妨げない。

一方で表示層は root Navigator の Overlay を参照するため、root Navigator key
（`appNavigatorKey`）が初期化されていることが前提になる。`ToastOverlay` は
`MaterialApp.builder` 内に常駐させ、provider state と OverlayEntry を同期する。
また、トースト表示中に新たな route が push されるとその route が上になる（5 秒の表示窓では許容）。
