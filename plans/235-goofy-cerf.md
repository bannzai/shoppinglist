# test(e2e): IAP を含む Maestro E2E フローを iOS / Android で整備する

- 関連 Issue: [#235](https://github.com/bannzai/shoppinglist/issues/235)
- 親プラン: [plans/peppy-munching-kitten.md](./peppy-munching-kitten.md)（RC Test Store Skill 全体）
- 関連 PR: [#233 (merged)](https://github.com/bannzai/shoppinglist/pull/233) / 関連プラン: [plans/229-melodic-bentley.md](./229-melodic-bentley.md)

## Context

PR #233 で `kDebugMode` + `--dart-define=REVENUECAT_TEST_STORE_API_KEY` による RC Test Store API Key 切替基盤が merged 済。これを踏まえて、Issue #235 は「実課金なしで monthly/annual/lifetime の購入フローと 11 の premium 機能解除を iOS+Android の両方で Maestro E2E として自動化する」タスク。

ただし本プラン策定時の事前調査で、Issue #235 本文の前提と相違する事実が判明した:

1. **ペイウォール UI が `lib/` に未実装**: `Purchases.purchase(PurchaseParams.package(...))` を呼ぶ UI が lib/ 配下に一切存在しない（`purchaseProvider` を `ref.read` している箇所ゼロ）。そのためユーザーは現状アプリから課金を開始できず、E2E が踏むべき導線が無い。
2. **`lib/utils/purchase/purchase.dart` の Package Provider は `weekly / monthly / sixMonth / monthlyPremium` のみ**で、`annualPackage` / `lifetimePackage` が未定義。Test Store Offering に 3 Package (`$rc_monthly` / `$rc_annual` / `$rc_lifetime`) が attach 済みでも、アプリ側が拾えない。
3. **購入後の専用表示が無い**: 「プレミアム会員」のような文言は UI に未実装。assert 対象は "ロックアイコン消失 / 『プレミアム: 無制限』文言表示" 等の既存 UI 変化しかない。
4. **`maestro/flows/premium_category_location_order.yaml` はファイル名に反し実態は非プレミアム検証**（`shared/anonymous_sign_in.yaml` で匿名ログインして「非 premium でロケーション別ソートがデフォルト順にフォールバック」することを確認している）。Issue 本文の「category_location_order: 既に premium 版あり」という認識は誤り。

### ユーザー決定方針（AskUserQuestion 済）

- ペイウォール UI 新規実装 + E2E 整備を本 Issue 内で両方やる（大規模スコープ）
- 購入後の premium 判定は「既存 UI 変化 ＋ 有料機能の実操作」を組み合わせる
- フロー粒度: パッケージ別 3 本（iap_purchase_*）+ 機能別解除確認 10 本（premium_*）の分離
- 新規フローの `inputText` は ASCII (`milk` / `egg` / `bread` 等)。既存フローは日本語のまま残す

### スコープ（含む / 含まない）

**含む**
- Flutter: `annualPackage` / `lifetimePackage` Provider 追加
- Flutter: `lib/features/paywall/` 新規（PaywallPage + showPaywall() 導線関数 + README）
- Flutter: Settings に「プレミアム会員」ListTile 追加（E2E assert 対象として機能）
- Flutter: 各 premium gate の SnackBar に `SnackBarAction('アップグレード')` 追加（ペイウォール遷移）
- Maestro: `shared/mock_purchase.yaml` 新規（PACKAGE_TYPE 引数付き共通購入サブフロー）
- Maestro: `iap_purchase_{monthly,annual,lifetime}.yaml` 新規 3 本
- Maestro: `premium_{feature}.yaml` 新規 10 本
- Maestro: `maestro/README.md` 新規（iOS/Android 手順＋トラブルシュート）

**含まない（別 Issue 化）**
- GitHub Actions CI 連携
- 既存 `*_non_premium.yaml` の全面 ASCII 化
- `maestro/flows/premium_category_location_order.yaml`（既存非 premium 検証版）のリネーム → 本プラン U-5 で扱うが実装は別 Issue

---

## 変更対象ファイル

| パス | 役割 | 変更種別 |
|---|---|---|
| `lib/utils/purchase/purchase.dart` | Package Provider に annual / lifetime 追加 | 修正 |
| `lib/features/paywall/paywall_page.dart` | ペイウォール画面（3 Package 提示・購入実行） | 新規 |
| `lib/features/paywall/paywall.dart` | `showPaywall(BuildContext)` 導線関数 | 新規 |
| `lib/features/paywall/README.md` | feature README | 新規 |
| `lib/features/settings/page.dart` | 「プレミアム会員」ListTile 追加 + theme_color / location_reminder gate の SnackBar 差し替え | 修正 |
| `lib/features/shopping_list/components/app_bar.dart` | export / ai image / ai url gate の SnackBar 差し替え | 修正 |
| `lib/features/group_list/page.dart` | group 作成上限 gate の SnackBar 差し替え | 修正 |
| `lib/features/shopping_list/components/shopping_list_items/text_shopping_list_item_detail_bottom_sheet.dart` | item_photo gate の SnackBar 差し替え | 修正 |
| `lib/features/shopping_location/page.dart` | location_reminder gate の SnackBar 差し替え | 修正 |
| `lib/features/group_category/page.dart` | category_location_order gate の SnackBar 差し替え | 修正 |
| `lib/provider/shopping_list.dart` | `ShoppingListLimitExceededException` 発生時の SnackBar 呼出箇所に action 追加（呼び出し元 UI 側で対応） | 修正（呼び出し元側） |
| `maestro/flows/shared/mock_purchase.yaml` | 購入共通サブフロー（PACKAGE_TYPE env で分岐） | 新規 |
| `maestro/flows/iap_purchase_monthly.yaml` | monthly 購入 E2E | 新規 |
| `maestro/flows/iap_purchase_annual.yaml` | annual 購入 E2E | 新規 |
| `maestro/flows/iap_purchase_lifetime.yaml` | lifetime 購入 E2E | 新規 |
| `maestro/flows/premium_theme_color_setting.yaml` | テーマカラー設定解除確認 | 新規 |
| `maestro/flows/premium_export_shopping_list.yaml` | エクスポート解除確認 | 新規 |
| `maestro/flows/premium_group_creation.yaml` | グループ作成上限解除確認 | 新規 |
| `maestro/flows/premium_item_photo_attachment.yaml` | 写真添付解除確認 | 新規 |
| `maestro/flows/premium_location_reminder.yaml` | 位置情報リマインダー解除確認 | 新規 |
| `maestro/flows/premium_shopping_list_display_period.yaml` | 表示期間解除確認 | 新規 |
| `maestro/flows/premium_shopping_list_limit.yaml` | リスト作成上限解除確認 | 新規 |
| `maestro/flows/premium_shopping_list_limit_duplicate.yaml` | リスト複製上限解除確認 | 新規 |
| `maestro/flows/premium_ai_image_recognition.yaml` | AI 画像認識上限解除確認 | 新規 |
| `maestro/flows/premium_ai_url_recognition.yaml` | AI URL 認識上限解除確認 | 新規 |
| `maestro/README.md` | E2E 実行手順 + RC Test Store Key 取得 + トラブルシュート | 新規 |

合計 Flutter 11 ファイル（うち新規 3、修正 8）+ Maestro 15 ファイル（すべて新規）+ 1 README。

---

## Phase（実装順序）

```
[Phase A] Flutter: Package Provider 追加（annualPackage / lifetimePackage）
  A-1. purchase.dart に 2 Provider を追加
  A-2. dart run build_runner build で purchase.g.dart 更新

[Phase B] Flutter: ペイウォール機能 新規実装
  B-1. lib/features/paywall/paywall_page.dart 作成
  B-2. lib/features/paywall/paywall.dart (showPaywall 関数) 作成
  B-3. lib/features/paywall/README.md 作成

[Phase C] Flutter: Settings / 各 gate から showPaywall() への差し替え
  C-1. Settings に「プレミアム会員」ListTile 追加
  C-2. 各 premium gate の SnackBar に SnackBarAction('アップグレード') 追加

[Phase D] Flutter: 自動検証
  flutter analyze / flutter test / flutter build ios / flutter build apk

[Phase E] Maestro: mock purchase modal UI 調査（iOS / Android 両方）
  実機 flutter run → maestro studio / maestro hierarchy で要素 text/id を採取

[Phase F] Maestro: shared/mock_purchase.yaml 作成（Phase E 結果を反映）

[Phase G] Maestro: iap_purchase_{monthly,annual,lifetime}.yaml 作成（3 本）

[Phase H] Maestro: premium_{feature}.yaml 作成（10 本）

[Phase I] Maestro: iOS 実行確認（iPhone 16 Plus / iOS 18.5）
[Phase J] Maestro: Android 実行確認（test_device_api35）
[Phase K] Docs: maestro/README.md 作成
```

---

## 実装コード提案

### A-1. `lib/utils/purchase/purchase.dart` 修正

既存の `monthlyPackage` / `sixMonthPackage` と同じパターンで追加:

```dart
/// 現在 Offering から annual (1 年) Package を返す。未定義なら null。
@Riverpod()
Package? annualPackage(Ref ref) {
  final currentOfferingPackages = ref.watch(currentOfferingPackagesProvider);
  return currentOfferingPackages.firstWhereOrNull(
      (element) => element.packageType == PackageType.annual);
}

/// 現在 Offering から lifetime (買い切り) Package を返す。未定義なら null。
@Riverpod()
Package? lifetimePackage(Ref ref) {
  final currentOfferingPackages = ref.watch(currentOfferingPackagesProvider);
  return currentOfferingPackages.firstWhereOrNull(
      (element) => element.packageType == PackageType.lifetime);
}
```

### B-1. `lib/features/paywall/paywall_page.dart`（新規）

Issue #235 の検証対象は monthly / annual / lifetime の 3 Package。既存 `purchaseProvider.call(Package)` をそのまま呼ぶ。

```dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shoppinglist/utils/purchase/purchase.dart';

/// ペイウォール画面。現在 Offering の monthly / annual / lifetime の 3 Package を提示する。
class PaywallPage extends ConsumerWidget {
  const PaywallPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthly = ref.watch(monthlyPackageProvider);
    final annual = ref.watch(annualPackageProvider);
    final lifetime = ref.watch(lifetimePackageProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('プレミアムプラン')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('プレミアムにアップグレードすると全機能が解放されます'),
          const SizedBox(height: 16),
          if (monthly != null) _PaywallPackageTile(package: monthly),
          if (annual != null) _PaywallPackageTile(package: annual),
          if (lifetime != null) _PaywallPackageTile(package: lifetime),
        ],
      ),
    );
  }
}

/// 1 つの Package を行として表示し、タップで Purchase().call() を実行する。
class _PaywallPackageTile extends ConsumerWidget {
  const _PaywallPackageTile({required this.package});

  final Package package;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        title: Text(package.storeProduct.title),
        subtitle: Text(package.storeProduct.priceString),
        trailing: ElevatedButton(
          key: Key('paywall_subscribe_${package.packageType.name}'),
          onPressed: () async {
            try {
              final completed = await ref.read(purchaseProvider).call(package);
              if (!context.mounted) return;
              if (completed) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('購入ありがとうございました')),
                );
                Navigator.of(context).pop();
              }
            } catch (e) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(e.toString())),
              );
            }
          },
          child: const Text('購入'),
        ),
      ),
    );
  }
}
```

### B-2. `lib/features/paywall/paywall.dart`（新規）

各 gate から開く導線関数。`fullscreenDialog: true` で画面下から迫り出す形。

```dart
import 'package:flutter/material.dart';
import 'package:shoppinglist/features/paywall/paywall_page.dart';

/// 各 premium gate から呼ぶためのペイウォール遷移関数。
Future<void> showPaywall({required BuildContext context}) {
  return Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => const PaywallPage(),
      fullscreenDialog: true,
    ),
  );
}
```

### C-1. `lib/features/settings/page.dart` 修正: 「プレミアム会員」ListTile

「アプリについて」セクションの手前に以下を挿入。E2E の assertVisible 対象として機能する。

```dart
// customerInfoProvider から isPremium を取得
final customerInfo = ref.watch(customerInfoProvider).asData?.value;
final isPremium = customerInfo?.isPremium ?? false;

// 「プレミアム会員」ListTile
ListTile(
  leading: const Icon(Icons.workspace_premium),
  title: const Text('プレミアム会員'),
  subtitle: Text(isPremium ? '有効' : '未加入'),
  onTap: isPremium ? null : () => showPaywall(context: context),
),
```

### C-2. 各 premium gate の差し替え（全 gate 同パターン）

**Before** (`lib/features/settings/page.dart:299-301`):
```dart
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text('テーマカラーの変更はプレミアム機能です')),
);
```

**After**:
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: const Text('テーマカラーの変更はプレミアム機能です'),
    action: SnackBarAction(
      label: 'アップグレード',
      onPressed: () => showPaywall(context: context),
    ),
  ),
);
```

差し替え対象箇所（ファイル:L#）:
- `lib/features/settings/page.dart:300` — theme_color_setting
- `lib/features/settings/page.dart:411` — location_reminder（Switch tap）
- `lib/features/shopping_list/components/app_bar.dart:425` — export_shopping_list
- `lib/features/shopping_list/components/app_bar.dart:247` — ai image recognition limit
- `lib/features/shopping_list/components/app_bar.dart:374` — ai url recognition limit
- `lib/features/group_list/page.dart:92` — group creation limit
- `lib/features/shopping_list/components/shopping_list_items/text_shopping_list_item_detail_bottom_sheet.dart:460` — item_photo_attachment
- `lib/features/shopping_location/page.dart:144` — location_reminder（地図側）
- `lib/features/group_category/page.dart:240` / `:394` — category_location_order（dropdown / reorder）

### F. `maestro/flows/shared/mock_purchase.yaml`（新規）

```yaml
appId: com.bannzai.shoppinglist
env:
  PACKAGE_TYPE: monthly
---
# 匿名サインイン後に呼び出される共通購入サブフロー。
# PACKAGE_TYPE: monthly | annual | lifetime を受ける。
# shared/anonymous_sign_in.yaml の後段で runFlow するのを前提とする。

# 設定タブ → 「プレミアム会員」→ ペイウォール画面を開く
- tapOn:
    text: "設定.*"
    index: 0
- waitForAnimationToEnd
- tapOn: "プレミアム会員"
- extendedWaitUntil:
    visible: "プレミアムプラン"
    timeout: 15000

# 指定された PACKAGE_TYPE の購入ボタンをタップ (ElevatedButton に Key を付けている)
- tapOn:
    id: "paywall_subscribe_${PACKAGE_TYPE}"

# RC Test Store mock purchase modal を承認する
# NOTE: tapOn の対象 text/id は Phase E (maestro studio) で確定する。
# 暫定として "Subscribe" を想定（iOS / Android それぞれ要調査）。
- extendedWaitUntil:
    visible: "Subscribe"
    timeout: 30000
- tapOn: "Subscribe"

# 購入完了 SnackBar を確認する
- extendedWaitUntil:
    visible: "購入ありがとうございました"
    timeout: 30000

- takeScreenshot: screenshots/mock_purchase_${PACKAGE_TYPE}_completed
```

### G. `maestro/flows/iap_purchase_monthly.yaml`（新規）

```yaml
appId: com.bannzai.shoppinglist
---
# monthly パッケージ購入 E2E。
# 成功後に設定画面の「プレミアム会員」subtitle が「有効」になっていることを assert する。

- runFlow: shared/anonymous_sign_in.yaml

- runFlow:
    file: shared/mock_purchase.yaml
    env:
      PACKAGE_TYPE: monthly

# 設定画面に戻って premium 状態を確認
- tapOn:
    text: "設定.*"
    index: 0
- waitForAnimationToEnd
- assertVisible: "プレミアム会員"
- assertVisible: "有効"

- takeScreenshot: screenshots/iap_purchase_monthly_completed
```

`iap_purchase_annual.yaml` / `iap_purchase_lifetime.yaml` は `PACKAGE_TYPE` のみを差し替えた同構造。

### H. `maestro/flows/premium_{feature}.yaml`（各 10 本の骨格）

すべて「`anonymous_sign_in` → `mock_purchase (PACKAGE_TYPE=monthly)` → 対象機能の実操作」の構造。既存 `*_non_premium.yaml` の「ブロック UI で止まる」を反転し「assertNotVisible + 次画面遷移 + 機能実行」で assert する。

#### H-1. `premium_theme_color_setting.yaml`

```yaml
appId: com.bannzai.shoppinglist
---
- runFlow: shared/anonymous_sign_in.yaml
- runFlow:
    file: shared/mock_purchase.yaml
    env:
      PACKAGE_TYPE: monthly

# 設定 → テーマカラー
- tapOn:
    text: "設定.*"
    index: 0
- waitForAnimationToEnd
- tapOn: "テーマカラー"
- waitForAnimationToEnd

# non_premium 時の SnackBar が出ないことを確認（遷移成功の証左）
- assertNotVisible: "テーマカラーの変更はプレミアム機能です"
- assertVisible: "テーマカラー"  # 次画面のタイトル（要実機確認、変われば更新）

- takeScreenshot: screenshots/premium_theme_color_setting_unlocked
```

#### H-2. `premium_export_shopping_list.yaml`

```yaml
appId: com.bannzai.shoppinglist
---
- runFlow: shared/anonymous_sign_in.yaml
- runFlow:
    file: shared/mock_purchase.yaml
    env:
      PACKAGE_TYPE: monthly

# メニュー → リストをエクスポート
- tapOn: "メニュー"
- waitForAnimationToEnd
- tapOn: "リストをエクスポート"
- waitForAnimationToEnd

# non_premium 時の SnackBar が出ないこと
- assertNotVisible: "リストのエクスポートはプレミアム機能です"
# エクスポート ShareSheet が立ち上がる、または次画面遷移していること
# NOTE: iOS/Android のネイティブ ShareSheet は Maestro で安定操作できないため、
# SnackBar の非出現＋スクリーンショットで代替する（non_premium と同じ弱 assert 方針）
- takeScreenshot: screenshots/premium_export_shopping_list_unlocked
```

#### H-3. `premium_group_creation.yaml`

```yaml
appId: com.bannzai.shoppinglist
---
# 非プレミアムでは 2 つ目のグループで上限ブロックされる。premium では 2 つ目も作れる。

- runFlow: shared/anonymous_sign_in.yaml
- runFlow:
    file: shared/mock_purchase.yaml
    env:
      PACKAGE_TYPE: monthly

# 設定 → グループ管理
- tapOn:
    text: "設定.*"
    index: 0
- waitForAnimationToEnd
- tapOn: "グループ管理"
- waitForAnimationToEnd

# 2 つ目のグループ作成
- tapOn: "グループ作成"
- waitForAnimationToEnd
- tapOn: "グループ名"
- inputText: "Extra Group"  # ASCII
- tapOn:
    text: "作成"
    index: 0
- waitForAnimationToEnd

# 非 premium 時の SnackBar が出ないこと + 新グループが表示されること
- assertNotVisible: "無料プランではソログループ+1グループまで作成できます"
- assertVisible: "Extra Group"

- takeScreenshot: screenshots/premium_group_creation_unlocked
```

#### H-4. `premium_item_photo_attachment.yaml`

```yaml
appId: com.bannzai.shoppinglist
---
- runFlow: shared/anonymous_sign_in.yaml
- runFlow:
    file: shared/mock_purchase.yaml
    env:
      PACKAGE_TYPE: monthly

# アイテム追加 → 詳細
- tapOn: "アイテムを追加"
- inputText: "milk"  # ASCII
- pressKey: enter
- tapOn:
    point: "50%,6%"  # キーボード閉じる
- waitForAnimationToEnd
- tapOn: "milk"
- waitForAnimationToEnd
- tapOn: "写真を追加"
- waitForAnimationToEnd

# 非 premium 時の SnackBar が出ないこと + 画像選択 ActionSheet が開くこと
- assertNotVisible: "商品写真の添付はプレミアム機能です"
- assertVisible: "カメラで撮影"  # 画像ソース選択肢（要実機確認）

- takeScreenshot: screenshots/premium_item_photo_attachment_unlocked
```

#### H-5. `premium_location_reminder.yaml`

```yaml
appId: com.bannzai.shoppinglist
---
- runFlow: shared/anonymous_sign_in.yaml
- runFlow:
    file: shared/mock_purchase.yaml
    env:
      PACKAGE_TYPE: monthly

# 設定 → 位置情報リマインダー Switch を ON
- tapOn:
    text: "設定.*"
    index: 0
- waitForAnimationToEnd
- tapOn: "位置情報リマインダー"
- waitForAnimationToEnd

# 非 premium 時の SnackBar が出ないこと
- assertNotVisible: "位置情報リマインダーはプレミアム機能です"
# 位置情報権限ダイアログ吸収（初回のみ）
- runFlow:
    when:
      visible: "許可"
    commands:
      - tapOn: "許可"
      - waitForAnimationToEnd

- takeScreenshot: screenshots/premium_location_reminder_unlocked
```

#### H-6. `premium_shopping_list_display_period.yaml`

```yaml
appId: com.bannzai.shoppinglist
---
- runFlow: shared/anonymous_sign_in.yaml
- runFlow:
    file: shared/mock_purchase.yaml
    env:
      PACKAGE_TYPE: monthly

# リスト設定を開く
- tapOn: "リスト設定"
- waitForAnimationToEnd
- assertVisible: "買い物リスト設定"
- tapOn: "買い物リストの保存期間"
- waitForAnimationToEnd

# 非 premium 時の文言が出ないこと + premium 時の文言が出ること
- assertNotVisible: "作成から30日間表示されます"
- assertVisible: "プレミアム: 無制限"  # shopping_list_setting/page.dart:164

- takeScreenshot: screenshots/premium_shopping_list_display_period_unlocked
```

#### H-7. `premium_shopping_list_limit.yaml`

```yaml
appId: com.bannzai.shoppinglist
---
# 非 premium では 6 個目で上限 SnackBar。premium では 6 個目も作成できる。

- runFlow: shared/anonymous_sign_in.yaml
- runFlow:
    file: shared/mock_purchase.yaml
    env:
      PACKAGE_TYPE: monthly

# 5 個のリストを連続追加（既存 shopping_list_limit_non_premium.yaml と同じ手順）
- repeat:
    times: 6
    commands:
      - tapOn: "メニュー"
      - waitForAnimationToEnd
      - tapOn: "買い物リストを追加"
      - waitForAnimationToEnd
      - tapOn: "リスト名"
      - inputText: "List ${maestro.copies}"  # ASCII + インデックス
      - tapOn:
          text: "追加"
          index: 0
      - waitForAnimationToEnd

# 非 premium 時の SnackBar が出ないこと
- assertNotVisible: "無料プランでは1グループあたり5個までリストを作成できます"
- takeScreenshot: screenshots/premium_shopping_list_limit_unlocked
```

#### H-8. `premium_shopping_list_limit_duplicate.yaml`

```yaml
appId: com.bannzai.shoppinglist
---
# 5 個のリストを作成後、複製で 6 個目を作れる（premium のみ）。

- runFlow: shared/anonymous_sign_in.yaml
- runFlow:
    file: shared/mock_purchase.yaml
    env:
      PACKAGE_TYPE: monthly

- repeat:
    times: 5
    commands:
      - tapOn: "メニュー"
      - waitForAnimationToEnd
      - tapOn: "買い物リストを追加"
      - waitForAnimationToEnd
      - tapOn: "リスト名"
      - inputText: "List ${maestro.copies}"
      - tapOn:
          text: "追加"
          index: 0
      - waitForAnimationToEnd

# 現在のリストを複製（6 個目）
- tapOn: "メニュー"
- waitForAnimationToEnd
- tapOn: "現在の買い物リストを複製"
- waitForAnimationToEnd

- assertNotVisible: "無料プランでは1グループあたり5個までリストを作成できます"
- takeScreenshot: screenshots/premium_shopping_list_limit_duplicate_unlocked
```

#### H-9. `premium_ai_image_recognition.yaml`

```yaml
appId: com.bannzai.shoppinglist
---
# premium では月間利用回数が 50 に拡張される。文言の末尾「月50回まで利用できます」が消えることを確認する。

- runFlow: shared/anonymous_sign_in.yaml
- runFlow:
    file: shared/mock_purchase.yaml
    env:
      PACKAGE_TYPE: monthly

- tapOn:
    id: "popup_menu_button"
- waitForAnimationToEnd
- tapOn: "画像から追加"
- waitForAnimationToEnd

# premium では SnackBar は出ない（未達のとき）か、出ても上限は 50 になる
- assertNotVisible: "プレミアムにアップグレードすると月50回まで利用できます"

- takeScreenshot: screenshots/premium_ai_image_recognition_unlocked
```

#### H-10. `premium_ai_url_recognition.yaml`

```yaml
appId: com.bannzai.shoppinglist
---
- runFlow: shared/anonymous_sign_in.yaml
- runFlow:
    file: shared/mock_purchase.yaml
    env:
      PACKAGE_TYPE: monthly

- tapOn:
    id: "popup_menu_button"
- waitForAnimationToEnd
- tapOn: "URLから追加"
- waitForAnimationToEnd

- assertNotVisible: "プレミアムにアップグレードすると月50回まで利用できます"

- takeScreenshot: screenshots/premium_ai_url_recognition_unlocked
```

### K. `maestro/README.md`（新規）

```markdown
# Maestro E2E テスト手順

買い物リストアプリの E2E フロー群を iOS / Android で実行するためのローカル手順書。

## 前提

### 必須ツール
- Maestro CLI: https://docs.maestro.dev/ （`MAESTRO_DRIVER_STARTUP_TIMEOUT=120000` 既定）
- iOS: Xcode 15+ / iOS 18.x シミュレータ（iPhone 16 Plus 推奨）
  - **iOS 26.x beta は WebDriverAgent が不安定。iOS 18.x を使うこと**（`~/.claude/skills/maestro-flutter/SKILL.md`）
- Android: Android Studio + API 35 emulator（`test_device_api35` 推奨）

### RC Test Store API Key（IAP E2E 実行時のみ必須）
`iap_purchase_*.yaml` / `premium_*.yaml` / `shared/mock_purchase.yaml` を実行するには Test Store Key が必要:

1. Dashboard `https://app.revenuecat.com/projects/a9466f75/apps/appd627c59489` から `test_xxx` 形式の Key を取得
2. `.vscode/launch.json` の `shoppinglist(dev)` configuration の `REVENUECAT_TEST_STORE_API_KEY=test_xxx_replace_me` を実値に置換
3. CLI 実行時は `export REVENUECAT_TEST_STORE_API_KEY=test_xxx` してから `flutter build` を行う

**Debug ビルドで Test Store Key が空のまま起動すると assert で落ちる**（PR #233 設計）。

## iOS 実行

```bash
export REVENUECAT_TEST_STORE_API_KEY=test_xxx

bash ~/.claude/skills/sim-manager/scripts/create-and-boot-sim.sh "E2E-iPhone16Plus" "iPhone 16 Plus"
# 直前の出力から DEVICE_UDID を取得
DEVICE_UDID=$(xcrun simctl list devices booted -j | jq -r '.devices|to_entries[].value[0].udid')

flutter build ios --simulator --debug --dart-define=REVENUECAT_TEST_STORE_API_KEY=$REVENUECAT_TEST_STORE_API_KEY
xcrun simctl install $DEVICE_UDID build/ios/iphonesimulator/Runner.app

# 購入 E2E（3 本）
for pkg in monthly annual lifetime; do
  bash ~/.claude/skills/maestro-flutter/scripts/run-maestro-flow.sh maestro/flows/iap_purchase_${pkg}.yaml $DEVICE_UDID
done

# 機能解除確認 E2E（10 本）
for f in maestro/flows/premium_*.yaml; do
  bash ~/.claude/skills/maestro-flutter/scripts/run-maestro-flow.sh "$f" $DEVICE_UDID
done

bash ~/.claude/skills/maestro-flutter/scripts/collect-results.sh
```

## Android 実行

```bash
export REVENUECAT_TEST_STORE_API_KEY=test_xxx

emulator -avd test_device_api35 -no-snapshot-load &

flutter build apk --debug --dart-define=REVENUECAT_TEST_STORE_API_KEY=$REVENUECAT_TEST_STORE_API_KEY
adb install -r build/app/outputs/flutter-apk/app-debug.apk

for f in maestro/flows/iap_purchase_*.yaml maestro/flows/premium_*.yaml; do
  maestro --platform android test "$f" --debug-output tmp/maestro-android-results --flatten-debug-output
done
```

## トラブルシュート

- **iOS WDA 接続断**: `xcrun simctl erase $DEVICE_UDID` → boot → install → retry
- **Android ディスク不足**: 別 AVD に切り替え (`avdmanager list avd`) または `adb uninstall com.bannzai.shoppinglist` で空き確保
- **Android Unicode 入力エラー**: 該当 `inputText` を ASCII に置換（https://github.com/mobile-dev-inc/maestro/issues/146）
- **mock purchase modal で停止**: `maestro studio` で画面要素を再調査し、`shared/mock_purchase.yaml` の tapOn テキスト/id を更新
- **「REVENUECAT_TEST_STORE_API_KEY is required」で落ちる**: `--dart-define` を付けずにビルドしている。PR #233 の assert を参照
```

---

## 検証

### 自動テスト（Flutter）

```bash
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter build ios --simulator --debug --dart-define=REVENUECAT_TEST_STORE_API_KEY=$REVENUECAT_TEST_STORE_API_KEY
flutter build apk --debug --dart-define=REVENUECAT_TEST_STORE_API_KEY=$REVENUECAT_TEST_STORE_API_KEY
```

### 手動テスト（ペイウォール UI 目視確認）

前提: `export REVENUECAT_TEST_STORE_API_KEY=test_xxx`

```bash
flutter run --dart-define=REVENUECAT_TEST_STORE_API_KEY=$REVENUECAT_TEST_STORE_API_KEY
```

期待:
1. 匿名サインイン → 設定タブ → 「プレミアム会員」ListTile が表示され subtitle が「未加入」
2. タップ → PaywallPage が下から迫り出して遷移
3. `monthly` / `annual` / `lifetime` の 3 Package が Card で表示（title + price）
4. 各「購入」ボタンに Key `paywall_subscribe_{type}` が付いている（Flutter inspector で確認）
5. いずれか選択 → RC Test Store mock purchase modal が表示 → 承認 → 「購入ありがとうございました」SnackBar
6. PaywallPage が pop され、設定画面に戻ると subtitle が「有効」に変化
7. 他 premium gate（テーマカラー・エクスポート・位置リマインダー 等）をタップ → ブロック SnackBar が出ず、各機能が実行できる

### Phase E: mock purchase modal 要素調査手順

```bash
# アプリを起動してペイウォール → 購入ボタンを手動タップし modal を出した状態で
maestro hierarchy --output tmp/mock-purchase-modal-ios.xml
# （Android 側も同様に）
maestro --platform android hierarchy --output tmp/mock-purchase-modal-android.xml
```

出力を grep して `Subscribe` / `Buy` / `Confirm` 相当の text / resource-id を `shared/mock_purchase.yaml` の tapOn に反映する。iOS と Android で異なる場合は U-6 に従って platform 別サブフローに分離する。

### Maestro E2E（iOS）

```bash
for f in iap_purchase_monthly iap_purchase_annual iap_purchase_lifetime \
         premium_theme_color_setting premium_export_shopping_list premium_group_creation \
         premium_item_photo_attachment premium_location_reminder \
         premium_shopping_list_display_period premium_shopping_list_limit \
         premium_shopping_list_limit_duplicate premium_ai_image_recognition premium_ai_url_recognition; do
  bash ~/.claude/skills/maestro-flutter/scripts/run-maestro-flow.sh "maestro/flows/${f}.yaml" $DEVICE_UDID
done
bash ~/.claude/skills/maestro-flutter/scripts/collect-results.sh
```

### Maestro E2E（Android）

README 記載の手順で同じ 13 本を個別実行。

---

## 既知の不確実性

| # | 内容 | 対処 |
|---|---|---|
| U-1 | mock purchase modal の tapOn 対象要素（text / id）が iOS / Android で未確認 | Phase E で `maestro hierarchy` 取得後、`shared/mock_purchase.yaml` を確定させる |
| U-2 | 購入完了 SnackBar 「購入ありがとうございました」が extendedWaitUntil で拾える表示時間かどうか未検証 | 拾えない場合は PaywallPage の SnackBar `duration: Duration(seconds: 10)` 等に延長 |
| U-3 | Test Store 購入履歴が `launchApp.clearState + clearKeychain` で消えるか未検証 | 消えない場合、各 iap_purchase / premium フロー先頭で RC `resetCustomer` 相当の処理が必要。必要なら shared フロー追加 |
| U-4 | `PackageType.lifetime` は `PurchaseType.INAPP (non-consumable)` であり、RC Offering に attach できても `currentOfferingPackagesProvider` が返すかどうかは実機確認要 | Phase A 実装後、`flutter run` で PaywallPage を開き 3 Package が全て表示されるか確認 |
| U-5 | 既存 `maestro/flows/premium_category_location_order.yaml` は実態が非 premium 検証。ファイル名と矛盾 | 本 Issue スコープ外だが、別 Issue で `category_location_order_non_premium.yaml` にリネーム + 新規 premium 版を作成することを提案（本プランには含めない） |
| U-6 | mock purchase modal の UI が iOS / Android で異なる場合、shared/mock_purchase.yaml を platform 別に分岐する必要 | Phase E 調査で判明したら `shared/mock_purchase_ios.yaml` / `shared/mock_purchase_android.yaml` に分離し、iap_purchase / premium 各フローから OS ごとに runFlow を切り替える |
| U-7 | `premium_shopping_list_limit*.yaml` の `${maestro.copies}` 変数が実在するか未検証 | Maestro 公式 docs で確認済みだが、動かない場合は `repeat + 明示的なインデックス生成` に代替する |
| U-8 | Flutter 側の `purchaseProvider.call()` は `false` を返すケース（`mapToDisplayedException` が null を返すパス）がある。PaywallPage の後続処理が止まる懸念 | 現行実装を維持。`completed == false` の場合は SnackBar も Navigator.pop もせず、ユーザーが modal を閉じてから再操作できる状態に留める |

---

## チェックリスト

### 実装内容
- [ ] 変更対象ファイルごとに具体的なコード提案をコードブロックで記載している
- [ ] 既存コードのパターン・構成を確認し、同じパターンで実装している（`premium_category_location_order.yaml` / `monthlyPackage` Provider / 各 `*_non_premium.yaml` を参考）

### Flutter（lib/ に変更がある場合）
- [ ] コード生成: `dart run build_runner build` で `purchase.g.dart` の `annualPackageProvider` / `lifetimePackageProvider` を更新
- [ ] 静的解析: `flutter analyze` エラーなし
- [ ] テスト: `flutter test` 全件パス
- [ ] iOS ビルド: `flutter build ios --simulator --debug --dart-define=REVENUECAT_TEST_STORE_API_KEY=test_xxx` 成功
- [ ] Android ビルド: `flutter build apk --debug --dart-define=REVENUECAT_TEST_STORE_API_KEY=test_xxx` 成功
- [ ] 新規・変更機能に対するテストが存在する（PaywallPage の Widget test が困難な場合はユーザーに報告）
- [ ] Maestro E2E: 新規 14 本 + 更新 README が iOS / Android 両方で PASS する
- [ ] Entity命名: フィールド名が省略されていない（`annualPackage` / `lifetimePackage` 等）
- [ ] DB操作: Firestore操作は `call` クラスのProvider経由（本 Issue は Firestore 変更なし）
- [ ] 引数: 関数・コンストラクタの引数に `{required}` あり（`showPaywall({required context})`, `_PaywallPackageTile({required package})`）
- [ ] ref使い分け: `build` 内は `ref.watch(monthlyPackageProvider)` 等、onPressed 内は `ref.read(purchaseProvider)`
- [ ] サブコレクションEntityに親ドキュメントIDフィールドあり（該当なし）

### 共通
- [ ] エラーメッセージはそのまま表示（加工・プレフィックス除去なし）— `_PaywallPackageTile` の catch 内で `Text(e.toString())`
