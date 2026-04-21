# RevenueCat Test Store 用 API Key 切替対応 (Flutter 側)

関連 Issue: [#229](https://github.com/bannzai/shoppinglist/issues/229)
親プラン: [plans/peppy-munching-kitten.md](./peppy-munching-kitten.md)

## Context

`revenuecat-setup` / `iap-orchestrator` Skill 側で RC Test Store の Products 自動登録と Package への attach が完了している。Test Store を使うと実 ASC/Play に商品登録せず、mock purchase modal で IAP フロー全体を debug build で検証できる（実課金は発生しない）。

このプランは Flutter アプリから Test Store を実際に使うため、`Purchases.configure()` に渡す API Key を「開発ビルド + `--dart-define=USE_RC_TEST_STORE=true` のとき」だけ Test Store 用キーに切り替える対応を行う。Release build では誤用防止のため常に本番キーを使う。

Skill 側で Entitlement / Offering に全 product が attach 済みのため、**Flutter 側で offering 選択ロジック (`currentOfferingType`) は変更不要**。API Key 切替のみで完結する。

## 変更対象ファイル

- `lib/utils/config/environment.dart` — `useRCTestStore` getter 追加
- `lib/secret/secret.dart` — `revenueCatTestStorePublicAPIKey` 定数追加
- `lib/utils/purchase/purchase.dart` — `initializePurchase()` で Key 切替
- `test/utils/config/environment_test.dart` — 本番ビルドでの Test Store 無効化ガードのユニットテスト（新規）

## 実装内容

### 1. `lib/utils/config/environment.dart`

既存の `isProduction / isDevelopment / isLocal` と並ぶ位置に `useRCTestStore` getter を追加する。`bool.fromEnvironment` のパターンは同ファイル 19 行目の `disableWidgetAnimation` と同じ構造。Release build では必ず false を返すガードを入れる。

```dart
/// RC Test Store を使うかどうか。
/// `--dart-define=USE_RC_TEST_STORE=true` で build した場合に true を返す。
/// Release build では常に false を返す（本番キー誤差し替え防止のガード）。
static bool get useRCTestStore {
  if (isProduction) return false;
  return const bool.fromEnvironment('USE_RC_TEST_STORE');
}
```

配置位置: `isLocal` getter（13 行目）の直後。

### 2. `lib/secret/secret.dart`

Test Store 用 Public API Key を `--dart-define` 経由で受け取る定数を追加する。既存の `revenueCatPublicAPIKey`（本番キー）は変更しない。

`String.fromEnvironment` のパターンは `lib/utils/config/environment.dart:21-24` の `siwaServiceIdentifier` / `androidSiwaRedirectURL` と同じ。

```dart
abstract class Secret {
  static const revenueCatPublicAPIKey = 'appl_IPitkcPMywLwdVMCOFdTKnUZvns';

  /// RC Test Store 用 Public API Key。
  /// Dashboard で Test Store App を作成した際に発行されるキー（例: `test_xxx`）。
  /// 開発者ごとに Test Store が異なり、また git に載せると漏洩リスクがあるため、
  /// ハードコードせず `--dart-define=REVENUECAT_TEST_STORE_API_KEY=test_xxx` で注入する。
  /// 本番ビルドには含めないこと（`Environment.useRCTestStore` で Release 時はガード済み）。
  static const revenueCatTestStorePublicAPIKey = String.fromEnvironment(
    'REVENUECAT_TEST_STORE_API_KEY',
  );

  static const iOSAdmobNativeAdvanceIdentifier =
      'ca-app-pub-3940256099942544/3986624511';
  // ... 既存の定数はそのまま
}
```

### 3. `lib/utils/purchase/purchase.dart`

`initializePurchase()`（159 行目）で `Environment.useRCTestStore` 判定を追加し、Key を切り替える。Debug ビルドで `USE_RC_TEST_STORE=true` かつ API Key が空のときは `assert` で早期検知する（Release では assert は削除されるため `useRCTestStore=false` と合わせて二重ガード）。

```dart
Future<void> initializePurchase() async {
  await Purchases.setLogLevel(
      Environment.isDevelopment ? LogLevel.debug : LogLevel.info);

  final apiKey = Environment.useRCTestStore
      ? Secret.revenueCatTestStorePublicAPIKey
      : Secret.revenueCatPublicAPIKey;

  assert(
    !Environment.useRCTestStore || apiKey.isNotEmpty,
    'REVENUECAT_TEST_STORE_API_KEY is required when USE_RC_TEST_STORE=true. '
    'Pass it via --dart-define=REVENUECAT_TEST_STORE_API_KEY=test_xxx',
  );

  Purchases.configure(PurchasesConfiguration(apiKey));
}
```

`offerings` / `currentOfferingPackages` / `monthlyPackage` 等の Provider はそのまま流用可能（RC SDK が起動時の API Key に応じて Package の attach 済み product から適切なものを自動選択する設計のため）。

### 4. `test/utils/config/environment_test.dart`（新規）

`Environment.useRCTestStore` の production ガードを検証する。`bool.fromEnvironment` は compile-time 解決のため「dart-define が true のときに true になる」挙動のテストは難しいが、`isProduction` 短絡のガードだけは確実にユニットテストできる。

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shoppinglist/utils/config/environment.dart';

void main() {
  tearDown(() {
    Environment.flavor = null;
  });

  group('Environment.useRCTestStore', () {
    test('returns false when flavor is PRODUCTION', () {
      Environment.flavor = Flavor.PRODUCTION;
      expect(Environment.useRCTestStore, isFalse);
    });

    test('returns false when flavor is DEVELOP and no --dart-define passed', () {
      Environment.flavor = Flavor.DEVELOP;
      // bool.fromEnvironment のデフォルトは false
      expect(Environment.useRCTestStore, isFalse);
    });

    test('returns false when flavor is LOCAL and no --dart-define passed', () {
      Environment.flavor = Flavor.LOCAL;
      expect(Environment.useRCTestStore, isFalse);
    });
  });
}
```

## 検証

### 自動テスト

```bash
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter build ios --debug --no-codesign
flutter build apk --debug
```

### 手動テスト 1: Debug build で Test Store が有効になる

前提: RC Dashboard (https://app.revenuecat.com/projects/a9466f75/apps/appd627c59489) から Test Store Public API Key（`test_xxx`）を取得しておく。

```bash
flutter run \
  --dart-define=USE_RC_TEST_STORE=true \
  --dart-define=REVENUECAT_TEST_STORE_API_KEY=test_xxx
```

- 起動 log に `test_xxx` キーで `configure` されたログが出ること（`Environment.isDevelopment ? LogLevel.debug : LogLevel.info` により debug 時はログ詳細）
- プレミアム購入導線を開き、購入ボタンを押すと **RC の mock purchase modal**（実課金画面ではない）が表示されること
- 購入完了後 `customerInfoProvider` から読み出した `isPremium` が true になること
- Firestore / Analytics に実購入相当のイベントが飛ばないこと（Test Store はダミーなので実ストア向け event は発生しない）

### 手動テスト 2: Release build で Test Store を指定しても本番キーが使われる（ガード確認）

```bash
flutter build ipa \
  --release \
  --dart-define=USE_RC_TEST_STORE=true \
  --dart-define=REVENUECAT_TEST_STORE_API_KEY=test_xxx
```

- ビルド成功後、アプリ起動時に本番キー（`appl_IPitkcPMywLwdVMCOFdTKnUZvns`）で `configure` されること（`isProduction == true` → `useRCTestStore == false` の短絡ガード）

### 手動テスト 3: Debug で Test Store を有効化したのに API Key を渡していない場合の assert 検知

```bash
flutter run --dart-define=USE_RC_TEST_STORE=true
# REVENUECAT_TEST_STORE_API_KEY を意図的に渡さない
```

- 起動時に `initializePurchase()` 内の `assert` が発火し、メッセージ `REVENUECAT_TEST_STORE_API_KEY is required when USE_RC_TEST_STORE=true...` が console に出ること

### Maestro E2E

本変更は `--dart-define` による build time 切替であり、既存 Maestro フローは本番キー想定で動いている。本 Issue の主目的は「Test Store に繋がる Debug build を提供する」ことなので、既存 Maestro フローへの追加は不要。RC Test Store 向けの E2E は後続 Issue で別途検討する（親プラン `plans/peppy-munching-kitten.md` の範疇）。

---

## チェックリスト

### 実装内容
- [ ] 変更対象ファイルごとに具体的なコード提案をコードブロックで記載している
- [ ] 既存コードのパターン・構成を確認し、同じパターンで実装している

### Flutter（lib/ に変更がある場合）
- [ ] コード生成: `dart run build_runner build` で生成ファイル更新
- [ ] 静的解析: `flutter analyze` エラーなし
- [ ] テスト: `flutter test` 全件パス
- [ ] iOS ビルド: `flutter build ios` 成功
- [ ] Android ビルド: `flutter build apk` 成功
- [ ] 新規・変更機能に対するテストが存在する（`test/utils/config/environment_test.dart` を新規作成）
- [ ] Maestro E2E: 既存 flow は本番キー前提で問題ないため追加不要（判断理由を本文に記載）
- [ ] Entity命名: フィールド名が省略されていない（本変更に Entity 変更なし）
- [ ] DB操作: Firestore操作は `call` クラスのProvider経由（本変更に DB 操作なし）
- [ ] 引数: 関数・コンストラクタの引数に `{required}` あり（本変更に引数追加なし）
- [ ] ref使い分け: build内は `ref.watch`、コールバック・操作は `ref.read`（本変更に Provider 変更なし）
- [ ] サブコレクションEntityに親ドキュメントIDフィールドあり（本変更に Entity 変更なし）

### 共通
- [ ] エラーメッセージはそのまま表示（本変更に表示エラーなし、`assert` メッセージは開発者向け）
