# maintenance

## 概要

owner が `service-maintenance on shoppinglist` を実行した間、アプリの全画面の代わりにメンテナンス中の画面を出す。`service-maintenance off shoppinglist` で通常の画面に戻る。費用が急に増えた時に、ストアの審査やデプロイを待たずにサービスを止めるための備え (起票元: https://github.com/bannzai/castle/issues/3490 。仕組みは castle の service-maintenance-setup skill)。

## 画面

- メンテナンス中の画面 (`MaintenanceScreen`): 状態の `message` (無ければ翻訳の `maintenanceDefaultMessage`) と、状態に `button` がある時だけそのボタンを出す。ボタンを押すと URL を外部のブラウザで開く
- `MaterialApp` の `builder` で一番外側に置くため、どの画面を開いていても切り替わる。通常の画面は外さずに隠すため、通常に戻ると元いた画面に戻る

## フロー

1. 起動時・前面に戻った時・前面にいる間の 60 秒ごとに `Environment.maintenanceStateURL` の状態を読む
2. `maintenance` が true ならメンテナンス中の画面を出し、false なら通常の画面を出す
3. 状態を読めない時 (通信の失敗・2 秒の時間切れ・200 以外・形の違う応答) は通常の画面を出す

## データ形式

`maintenance_state.dart` の `MaintenanceState` (状態を返す Worker の `GET /shoppinglist` の JSON)。

## 制約

- サーバーの Gemini を呼ぶ Functions (`categorizeShoppingListItems`・`generateShoppingListItemsFromImage`・`generateShoppingListItemsFromURL`) も、メンテナンス中は `unavailable` のエラーで断る (`firebase/functions/src/functions/utils/maintenance.ts`)
- 検証用のビルドだけ、dart-define `MAINTENANCE_STATE_URL` で読む先を手元のサーバーに差し替える。本番の状態を検証のために切り替えない
