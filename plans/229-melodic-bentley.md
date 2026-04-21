# RevenueCat Test Store 用 API Key 切替対応 (Flutter 側)

関連 Issue: [#229](https://github.com/bannzai/shoppinglist/issues/229)
親プラン: [plans/peppy-munching-kitten.md](./peppy-munching-kitten.md)

## Context

`revenuecat-setup` / `iap-orchestrator` Skill 側で RC Test Store の Products 自動登録と Package への attach が完了している。Test Store を使うと実 ASC/Play に商品登録せず、mock purchase modal で IAP フロー全体を debug build で検証できる（実課金は発生しない）。

このプランは Flutter アプリから Test Store を実際に使うため、`Purchases.configure()` に渡す API Key を **Debug ビルド（`kDebugMode=true`）のときだけ** Test Store 用キーに切り替える対応を行う。Release build では `kDebugMode=false` のため本番キーが使われ、本番キー誤差し替えを防ぐガードになる。

環境変数スイッチ（`USE_RC_TEST_STORE` 等）は設けない。Debug 時に本番課金フローを検証したい場合は、`initializePurchase()` 内の `apiKey` の値を一時的に `Secret.revenueCatPublicAPIKey` に差し替える運用とする。

Skill 側で Entitlement / Offering に全 product が attach 済みのため、**Flutter 側で offering 選択ロジック (`currentOfferingType`) は変更不要**。API Key 切替のみで完結する。

## 変更対象ファイル

- `lib/utils/config/environment.dart` — 変更なし（`useRCTestStore` getter は設けない）
- `lib/secret/secret.dart` / `lib/secret/secret.dart.sample` — `revenueCatTestStorePublicAPIKey` 定数追加
- `lib/utils/purchase/purchase.dart` — `initializePurchase()` で `kDebugMode` 判定して Key 切替、運用コメント追加
- `.vscode/launch.json` — Debug 実行時の `--dart-define=REVENUECAT_TEST_STORE_API_KEY=...` を追加

## 実装内容

### 1. `lib/secret/secret.dart` / `lib/secret/secret.dart.sample`

Test Store 用 Public API Key を `--dart-define` 経由で受け取る定数を追加する。既存の `revenueCatPublicAPIKey`（本番キー）は変更しない。

`String.fromEnvironment` のパターンは `lib/utils/config/environment.dart` の `siwaServiceIdentifier` / `androidSiwaRedirectURL` と同じ。

`secret.dart` は `.gitignore` 対象だが、テンプレートである `secret.dart.sample` も同形で追加する（チーム内の他開発者が git から取得した際に参照できるように）。

```dart
abstract class Secret {
  static const revenueCatPublicAPIKey = '[REVENUE_CAT_PUBLIC_API_KEY]';

  /// RC Test Store 用 Public API Key。
  /// Dashboard で Test Store App を作成した際に発行されるキー（例: `test_xxx`）。
  /// 開発者ごとに Test Store が異なり、また git に載せると漏洩リスクがあるため、
  /// ハードコードせず `--dart-define=REVENUECAT_TEST_STORE_API_KEY=test_xxx` で注入する。
  /// Debug ビルド（`kDebugMode=true`）のときだけ `initializePurchase()` から参照され、
  /// Release ビルドでは本番キーが使われる（本番キー誤差し替え防止のガード）。
  static const revenueCatTestStorePublicAPIKey = String.fromEnvironment(
    'REVENUECAT_TEST_STORE_API_KEY',
  );

  // ... 既存の Admob 等の定数はそのまま
}
```

### 2. `lib/utils/purchase/purchase.dart`

`initializePurchase()` で `kDebugMode` 判定を追加し、Key を切り替える。Debug ビルドで API Key が空のときは `assert` で早期検知する（Release では assert が削除されるため `kDebugMode=false` と合わせて二重ガード）。

`kDebugMode` は `package:flutter/foundation.dart` から import する。

```dart
import 'package:flutter/foundation.dart';
// ... 他の import

Future<void> initializePurchase() async {
  await Purchases.setLogLevel(
      Environment.isDevelopment ? LogLevel.debug : LogLevel.info);

  // kDebugMode=true のとき RC Test Store Key を使い、mock purchase modal で IAP フローを検証する。
  // Release ビルドでは kDebugMode=false となり本番キーが使われる（本番キー誤差し替え防止のガード）。
  // Debug ビルドで本番課金フローを検証したい場合は、ここの apiKey の値を一時的に
  // Secret.revenueCatPublicAPIKey に差し替える運用とする（USE_RC_TEST_STORE のような環境変数スイッチは設けない）。
  final apiKey = kDebugMode
      ? Secret.revenueCatTestStorePublicAPIKey
      : Secret.revenueCatPublicAPIKey;

  assert(
    !kDebugMode || apiKey.isNotEmpty,
    'REVENUECAT_TEST_STORE_API_KEY is required in debug builds. '
    'Pass it via --dart-define=REVENUECAT_TEST_STORE_API_KEY=test_xxx',
  );

  Purchases.configure(PurchasesConfiguration(apiKey));
}
```

`offerings` / `currentOfferingPackages` / `monthlyPackage` 等の Provider はそのまま流用可能（RC SDK が起動時の API Key に応じて Package の attach 済み product から適切なものを自動選択する設計のため）。

### 3. `.vscode/launch.json`

Debug 実行時に毎回 `--dart-define` を手打ちしないよう、dev configuration に dart-define を追加する。

```json
{
  "name": "shoppinglist(dev)",
  "request": "launch",
  "type": "dart",
  "program": "lib/main.dart",
  "args": [
    "--debug",
    "--dart-define=REVENUECAT_TEST_STORE_API_KEY=test_xxx"
  ]
}
```

## 検証

### 自動テスト

```bash
flutter analyze
flutter test
flutter build ios --debug --no-codesign
# flutter build apk --debug は pre-existing な core library desugaring 問題 (#232) で失敗するため実施不可
```

### 手動テスト 1: Debug build で Test Store が有効になる

前提: RC Dashboard (https://app.revenuecat.com/projects/a9466f75/apps/appd627c59489) から Test Store Public API Key（`test_xxx`）を取得しておく。

```bash
flutter run --dart-define=REVENUECAT_TEST_STORE_API_KEY=test_xxx
```

- 起動 log に Test Store キーで `configure` されたログが出ること
- プレミアム購入導線を開き、購入ボタンを押すと **RC の mock purchase modal**（実課金画面ではない）が表示されること
- 購入完了後 `customerInfoProvider` から読み出した `isPremium` が true になること
- Firestore / Analytics に実購入相当のイベントが飛ばないこと（Test Store はダミーなので実ストア向け event は発生しない）

### 手動テスト 2: Release build で本番キーが使われる（ガード確認）

```bash
flutter build ipa --release
```

- ビルド成功後、アプリ起動時に本番キー（`Secret.revenueCatPublicAPIKey` / `[REVENUE_CAT_PUBLIC_API_KEY]` にセットした本番値）で `configure` されること
- `kDebugMode=false` のため Test Store 分岐には入らない

### 手動テスト 3: Debug で API Key を渡さない場合の assert 検知

```bash
flutter run
# REVENUECAT_TEST_STORE_API_KEY を意図的に渡さない
```

- 起動時に `initializePurchase()` 内の `assert` が発火し、メッセージ `REVENUECAT_TEST_STORE_API_KEY is required in debug builds...` が console に出ること

### Maestro E2E

本変更は `kDebugMode` による build time 切替であり、既存 Maestro フローは本番キー想定で動いている。本 Issue の主目的は「Test Store に繋がる Debug build を提供する」ことなので、既存 Maestro フローへの追加は不要。RC Test Store 向けの E2E は後続 Issue で別途検討する（親プラン `plans/peppy-munching-kitten.md` の範疇）。

---

## チェックリスト

### 実装内容
- [x] 変更対象ファイルごとに具体的なコード提案をコードブロックで記載している
- [x] 既存コードのパターン・構成を確認し、同じパターンで実装している

### Flutter（lib/ に変更がある場合）
- [ ] コード生成: `dart run build_runner build` で生成ファイル更新（本変更は codegen 対象の annotation を含まないため不要）
- [x] 静的解析: `flutter analyze` エラーなし
- [x] テスト: `flutter test` 全件パス
- [x] iOS ビルド: `flutter build ios` 成功
- [ ] Android ビルド: `flutter build apk` 成功（#232 の pre-existing 問題でスキップ）
- [ ] 新規・変更機能に対するテストが存在する（kDebugMode ベースの切替は compile-time のためユニットテスト困難。手動テストで担保）
- [x] Maestro E2E: 既存 flow は本番キー前提で問題ないため追加不要（判断理由を本文に記載）
- [x] Entity命名: フィールド名が省略されていない（本変更に Entity 変更なし）
- [x] DB操作: Firestore操作は `call` クラスのProvider経由（本変更に DB 操作なし）
- [x] 引数: 関数・コンストラクタの引数に `{required}` あり（本変更に引数追加なし）
- [x] ref使い分け: build内は `ref.watch`、コールバック・操作は `ref.read`（本変更に Provider 変更なし）
- [x] サブコレクションEntityに親ドキュメントIDフィールドあり（本変更に Entity 変更なし）

### 共通
- [x] エラーメッセージはそのまま表示（本変更に表示エラーなし、`assert` メッセージは開発者向け）
