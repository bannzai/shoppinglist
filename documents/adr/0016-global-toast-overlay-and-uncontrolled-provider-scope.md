# 0016. グローバルトースト（モーダル上表示）と UncontrolledProviderScope によるツリー外 Provider アクセス

## Status

Accepted

- Date: 2026-05-31
- Decision-Makers: bannzai

## Context

「通知系の表示をモーダル（ダイアログ / ボトムシート）の上にも出したい」という要件が発生した。

標準の `ScaffoldMessenger` の SnackBar は、表示中ページの `Scaffold` 内（`_ScaffoldSlot.snackBar`）に描画される。一方 `showDialog` / `showModalBottomSheet` は同じ `Navigator` の Overlay スタックに後から積まれる `ModalRoute` であり、ページの `Scaffold` より手前に描画される。結果として **SnackBar はモーダルの背後に隠れる**（Flutter 3.41.9 の SDK ソースで構造確認済み）。

加えて、次の制約・要件があった。

1. 通知を出したい場所には `BuildContext` / `WidgetRef` を持たないものがある（FCM フォアグラウンドハンドラ `FcmNotificationHandler` 等）。
2. 既存のグローバル通知は ADR 0004 の FCM フォアグラウンド SnackBar（`scaffoldMessengerKey` 経由）と、メンバー通知バー `showNotificationSnackBar`（`ScaffoldMessenger.of(context)` 経由）に分かれていた。これらもモーダル背後に隠れる問題を抱えていた。
3. このアプリは Riverpod（riverpod_generator）採用で、状態管理は Provider に寄せる慣習がある。

## Decision

### 1. 表示層: `MaterialApp.builder` の Stack 最前面に常駐する `ToastOverlay`

`MaterialApp.builder` の出力はウィジェットツリー上 `Navigator`（builder の `child`）の **外側（親）** に位置する。`builder` を `Stack([child, ToastOverlay()])` 化し、`Navigator` の兄弟として最前面に `ToastOverlay` を置くことで、`Navigator` の全 Route（ダイアログ / ボトムシート含む）より手前に描画する。

- これは `oktoast` / `toastification` 等のトーストライブラリと同方式。外部パッケージは追加せず自前実装した（描画は `Material` + ink 背景 + 角丸で既存 `showNotificationSnackBar` の装飾に合わせる）。
- 既存の debug 限定 `ShakeDetectorWrapper`（`kDebugMode` 時のみ）は builder 内で `child` をラップする形で維持する。

### 2. ツリー外 Provider アクセス: `UncontrolledProviderScope` + グローバル `ProviderContainer`

`main()` で `ProviderContainer` を生成して `appProviderContainer`（`late ProviderContainer`、グローバル変数）へ代入し、`runApp(UncontrolledProviderScope(container: appProviderContainer, ...))` でルートに渡す。

- これにより Widget ツリー（`ToastOverlay` が `ref.watch(toastProvider)`）と、ツリー外のグローバル関数（`appProviderContainer.read(toastProvider.notifier)`）が **同一コンテナ・同一 Provider インスタンス** を共有する。
- 従来の `ProviderScope` は内部でコンテナを自動生成するため、ツリー外から read できなかった。`UncontrolledProviderScope` は Riverpod 公式の「ツリー外から Provider を読む」標準パターン。
- ルートコンテナはアプリ寿命と一致するため明示 dispose は不要。`final` ではなく `late` にしているのは Widget テストでテスト用コンテナを差し替えるため。

#### 検討した代替案: GlobalKey で Overlay の State を直接叩く

`final globalToastKey = GlobalKey<ToastOverlayState>()` を公開し `globalToastKey.currentState?.show(...)` で叩く案も検討した。`main()` のルート構造を変えずに済むが、状態を Riverpod 外に置くことになりテスト時の `ProviderScope` override 慣習・既存の状態管理規約（`AIProcessing` Notifier 等）から外れる。一貫性を優先し採用しなかった。

### 3. トースト状態と公開 API

- 状態は `toastProvider`（`@Riverpod(keepAlive: true)` Notifier、state = `Widget?`）。`null` で非表示。表示中に再度 `show` されたら最新で即置き換え（単一表示）。自動消滅は Notifier 内の `Timer` で行い `ref.onDispose` で cancel する（`hourlyTrigger` の Timer 破棄作法に倣う）。
- 公開 API はグローバル関数 `showGlobalToast(message, {title})` / `showGlobalToastWidget(widget)` / `dismissGlobalToast()`。`ref` も `BuildContext` も不要。
- ink 背景フレーム（`_ToastFrame`）でのラップは表示層に閉じ込め、`toastProvider` は「描画する Widget」だけを持つ汎用状態に保つ。

### 4. 既存通知の統一

ADR 0004 の FCM フォアグラウンド通知と メンバー通知バーを新トーストに集約する。

- `FcmNotificationHandler` は `scaffoldMessengerKey` 依存を廃止し `showGlobalToast(body, title)` を呼ぶ。
- `showNotificationSnackBar` を `showNotificationToast` にリネームし `showGlobalToastWidget(NotificationMemberBar(...))` で表示する。
- 未使用になった `_scaffoldMessengerKey`（`MaterialApp.scaffoldMessengerKey`）は削除する。`ScaffoldMessenger.of(context)` 系の既存 SnackBar（設定画面のエラー表示等）はキー無しでも動作するため影響なし。

## Consequences

### 良い点
- ダイアログ / ボトムシート表示中でも通知が前面に出る。
- `BuildContext` / `ref` 無しで `showGlobalToast(...)` をどこからでも呼べる（FCM ハンドラ等で有効）。
- 通知表示の経路が 1 つに集約され、装飾・挙動（5 秒・単一表示・下部フローティング）が統一される。
- 状態が Riverpod Provider に乗るため、Widget テストで `UncontrolledProviderScope` + テスト用コンテナにより検証できる。

### 悪い点・トレードオフ
- アプリの DI ルート（`main()` の `ProviderScope` → `UncontrolledProviderScope`）に手を入れる構造変更が伴う（Provider のライフサイクル意味論は同じ）。
- グローバル可変変数 `appProviderContainer` を導入する。テスト差し替えのため `late`（非 final）であり、未初期化アクセスは `LateInitializationError` になる（`main()` で必ず代入される前提）。
- `ToastOverlay` は `Stack` 直下に置く配置制約がある（ルートが `Positioned`）。
- メンバー通知バー内のエラー時 SnackBar（`_sendNotification` の catch）は引き続き `ScaffoldMessenger.of(context)` のままで、これはモーダル背後に隠れうる（レアパスのため統一対象外）。
- 任意トーストをアプリ内から確実に発火させる導線が無く、安定した Maestro E2E 化は難しい。Widget Test + 手動確認でカバーする。

## 関連
- ADR 0004: FCMプッシュ通知のアーキテクチャ（本 ADR でフォアグラウンド表示経路を SnackBar → グローバルトーストへ変更）
- `lib/components/toast/README.md`
