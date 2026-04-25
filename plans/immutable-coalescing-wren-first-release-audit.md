# First Release 残タスク監査

## Context

ユーザーが「first release 前に残っているタスクを教えてほしい」と依頼。`RELEASE_TEST_PLAN.md`・最近マージされたPR・open issue/PR・ADR・ASO分析issueを調査し、リリースまでに必要なタスクを洗い出した。

**本プランはコード実装ではなく、リリース準備の作業リスト（棚卸し）である**。承認後に各タスクを個別に着手する想定。

### スコープ判断（ユーザー確認済み）

- **広告機能（#77 + #150）**: first release **後**に延期。v1.1 以降で対応。
- **PR #97**（ボトムシートキーボード修正）: **Close**。現在の main で `item_detail_and_delete.yaml` が通る前提で不要。
- **ASO 分析結果（#194〜#205）**: first release **前に反映**。

---

## 現状サマリ（完了済み）

| 項目 | 状態 | 参照 |
|------|------|------|
| ファーストリリース QA テストプラン | CLOSED (2026-04-05) | bannzai/shoppinglist#116 |
| プレミアム機能11件一括実装 | MERGED (2026-04-09) | bannzai/shoppinglist#177 |
| Maestro E2Eフロー7件修正・全12フロー PASS | MERGED (2026-04-10) | bannzai/shoppinglist#212 |
| 開発用プレミアム付与 (`grantPromotionalPremium`) | 実装済み | ADR 0008 |
| 自動テスト / ビルド（Flutter + Functions） | 全PASS | `RELEASE_TEST_PLAN.md` §1, §13 |
| ASO 競合分析・キーワード調査（ja / en-US） | 完了（反映は未） | bannzai/shoppinglist#194〜#205 |

リリース済みフィーチャ:
- 基本機能（リスト作成・アイテムCRUD・複製・カテゴリ・場所）
- グループ共有（招待コード方式）
- プレミアム機能11件（テーマカラー、AI画像認識/URL、表示期間、リスト/グループ上限緩和、エクスポート、カテゴリ並び替え、写真添付、位置情報リマインダー、ホームウィジェット拡張）
- プッシュ通知（FCM）・ホーム画面ウィジェット

---

## 残タスク

優先度・依存順で整理。A→Dの順で実施する想定。

### [A] RELEASE_TEST_PLAN.md のプレミアム動作確認を完了

`RELEASE_TEST_PLAN.md` は PR #212 以前に作成されたため、Maestro 結果が古い。また `[Premium]` 項目（開発者オプションでプレミアム付与後のUI動作確認）が未消化。

#### A-1. Maestro 結果を PR #212 の成果で更新

`RELEASE_TEST_PLAN.md` の以下セクションを更新。該当 flow は PR #212 で全 PASS 済み:

| セクション | 対象 flow | 現在の記述 | 更新後 |
|---|---|---|---|
| §5 買い物リスト表示期間制限 | `shopping_list_display_period_non_premium.yaml` | FAIL | `- [x]` + PR #212 の更新内容に合わせた説明 |
| §6 リスト作成数の上限緩和 | `shopping_list_limit_non_premium.yaml`, `shopping_list_limit_duplicate_non_premium.yaml` | FAIL | `- [x]` |
| §7 グループ作成数の上限緩和 | `group_creation_limit_non_premium.yaml` | FAIL | `- [x]` |
| §8 リストのエクスポート | `export_shopping_list_non_premium.yaml` | FAIL | `- [x]` |
| §10 アイテムへの写真添付 | `item_photo_attachment_non_premium.yaml` | FAIL | `- [x]` |
| §11 位置情報リマインダー | `location_reminder_non_premium.yaml` | FAIL | `- [x]` |

**変更対象**: `RELEASE_TEST_PLAN.md` のみ。

**検証**: 更新前に `maestro test maestro/flows/` を一括実行して全12フローPASSを再確認。

#### A-2. `[Premium]` パス動作確認を実行

開発者オプション → `grantPromotionalPremium` でプレミアム付与後、mobile-mcp または手動で以下を確認。エビデンスは `gh-r2-image` で R2 にアップロードし `RELEASE_TEST_PLAN.md` に `<img src="..." width="320">` で貼付する。

| セクション | 未消化項目 |
|---|---|
| §2 テーマカラー | `[Premium]` 選択画面遷移 / カラー選択でUI全体に反映 |
| §5 表示期間 | 30日超過リストを Firestore dump で注入 → プレミアムで表示されること（困難な場合は unit test カバー済みとしてスキップ明記） |
| §6 リスト上限 | プレミアムで6個目以降も作成可能 |
| §7 グループ上限 | プレミアムで2個目以降のグループ作成可能 |
| §8 エクスポート | `[Premium]` 「リストをエクスポート」→ 共有シート表示 |
| §9 カテゴリ並び替え | `[Premium]` ロケーション選択 → ドラッグで並び替え |
| §10 写真添付 | `[Premium]` アイテム詳細 → 「写真を追加」 → 画像ソースダイアログ |
| §11 位置情報リマインダー | `[Premium]` トグルON → 位置情報権限ダイアログ表示（ジオフェンス実動作はスキップ継続） |

**実行フロー**:
1. iOS Simulator（iPhone 16 Plus）でデバッグビルド起動
2. 匿名サインイン → 開発者オプション → プレミアム付与
3. 上記各項目を順に確認 → スクショ → `gh-r2-image` → エビデンス記述

#### A-3. ホームウィジェット動作テスト

`§12 ホームウィジェット拡張` の「ウィジェット操作テスト」が未実施。`/write-test-mobile-mcp-home-widget` skill で実行し、結果を §12 に追記。

**変更対象**: `RELEASE_TEST_PLAN.md` §12 のみ。

---

### [B] Open PR #97 を Close

- **PR**: bannzai/shoppinglist#97 「ボトムシートのキーボード問題を修正してitem_detail_and_deleteテストを安定化」
- **作成**: 2026-03-14 / **最終更新**: 2026-03-31

#### 実施手順

1. 念のため現在の main で該当 Maestro テストが通ることを確認:
   ```
   maestro test maestro/flows/item_detail_and_delete.yaml
   ```
2. PASS なら PR #97 に close コメントを残して close:
   - コメント例: 「PR #177 以降の `item_detail_bottom_sheet` 改修で該当問題は解消済み。main で `item_detail_and_delete.yaml` が PASS することを確認したため close します。」
   - `gh pr close 97 --comment "..."` で close
3. FAIL だった場合は当該 PR の差分を現状の main に rebase するか、別途修正プランを立てる

---

### [C] ASO 最終最適化と反映

ASO分析の結果（#194〜#205）をストアリスティングに反映する。各issueは「分析レポート」であり、実際の反映作業は未実施。

#### C-1. メタデータ反映（app_store_metadata ディレクトリ/ストア設定）

bannzai/shoppinglist#195, #203 の分析結果を元に以下を更新:

| フィールド | 現状 | 改善案（#195 より） |
|---|---|---|
| name (ja) | 「買い物リスト」(6文字) | キーワード拡張（例: 「買い物リスト - 共有できるお買い物メモ」20文字程度） |
| subtitle (ja) | 「家族やルームメイトと共有できるお買い物メモ」(20文字) | nameと重複しないキーワード（「買い忘れ」「カテゴリ」等）で30文字枠を活用 |
| keywords (ja) | 55文字（重複含む） | 100文字枠を最適化。name/subtitle重複を排除し「ストック」「買い忘れ」「食料品」「シンプル」等を追加 |
| description | 整理済みだが冒頭3行の訴求力に改善余地 | 競合との差別化ポイント（家族共有・カテゴリ自動ソート・ウィジェット）を冒頭に |
| name/subtitle/keywords (en-US) | — | #202, #203 の分析を元に同様に最適化 |

#### C-2. スクリーンショット作成

現状、App Store スクリーンショットは未作成（#199, #205 の分析で判明）。

- **対応**: `/onboarding-design` や `/ui-screenshot-review` skillを活用し、competitorの訴求パターン（Familiar: ビジュアルリッチ / Komorebi: ミニマル+ウィジェット / Sky Nexus: 店舗別タブ）を参考にスクショ4〜5枚を作成
- **訴求軸**:
  - 1枚目: メイン機能（買い物リスト + カテゴリ自動ソート）
  - 2枚目: 家族共有（招待コード or 共有画面）
  - 3枚目: ウィジェット（ホーム画面ウィジェット）
  - 4枚目: プレミアム機能（テーマカラー、AI画像認識 等）
  - 5枚目: 店舗別管理
- **作成先**: `fastlane/metadata/ios/` などストア提出に使う場所（fastlane は未導入のため、手動 or 別ワークフローで）

#### C-3. レビュー分析からの機能確認（#196, #204）

レビュー分析で「広告への不満」「データ消失」が競合の弱点として浮上。自アプリが該当しないことを確認:

- [x] **広告**: 未実装（first release では広告なし）
- [ ] **データ消失**: Firestore を使用しているためリスクは低いが、アカウント削除→再ログイン時のデータ状態を `RELEASE_TEST_PLAN.md` の基本機能項目で再確認

---

### [D] リリース提出準備（コードベース外 / 各チェック必要）

リポジトリ内に release 専用ドキュメント（`documents/release*.md`, `fastlane/`）は未配置。以下はプラン範囲外だが、ユーザー側で漏れがないか確認が必要:

1. **App Store Connect**: バンドルID確認、ビルド提出、スクリーンショット、プライバシー、審査用アカウント
2. **Google Play Console**: アプリ署名、AAB 提出、ストアリスティング
3. **RevenueCat**: production の product/entitlement 設定、`REVENUECAT_SECRET_API_KEY` が Firebase Functions production に設定済みか
4. **プッシュ通知本番証明書**: APNs production key が Firebase に設定済みか
5. **Remote Config**: 強制アップデートチェックが production の Remote Config に設定済みか
6. **プライバシーポリシー / 利用規約 / 特定商取引法に基づく表記**: URL が生きているか（設定画面から実機確認）

このセクションは「チェック項目」のみ。作業はユーザー側で実施する想定。

---

## 延期事項（v1.1 以降）

ユーザー確認済み:

- **#77** 一覧の中にNative広告を表示
- **#150** プレミアム機能: 広告削除 (P0, 依存: #77)

→ これら2件は first release スコープ外。v1.1 計画時に再整理する。

---

## 推奨実施順

```
A-1: RELEASE_TEST_PLAN.md の Maestro 結果更新（数分）
 ↓
A-2, A-3: プレミアム動作確認 + ホームウィジェットテスト（1セッション）
 ↓
B: PR #97 close（数分）
 ↓
C-1: ASO メタデータ更新（name, subtitle, keywords, description）
 ↓
C-2: ASO スクリーンショット作成（最も時間がかかる）
 ↓
C-3: レビュー分析からの機能確認チェック
 ↓
D: リリース提出準備（ユーザー側チェック）
```

---

## 検証方法

| タスク | 完了条件 |
|---|---|
| A-1 | `RELEASE_TEST_PLAN.md` §5〜§11 の Maestro チェックボックスが `[x]`、記述が現状と一致 |
| A-2 | 全 `[Premium]` 項目が `[x]`、各項目に `<img src="R2 URL" width="320">` でスクショ添付 |
| A-3 | §12 の「ウィジェット操作テスト」が `[x]`、ウィジェット上のチェック操作とアプリ同期のスクショあり |
| B | PR #97 が closed、コメントに close 理由記載 |
| C-1 | App Store Connect の ja / en-US の name / subtitle / keywords / description が最適化案で更新済み |
| C-2 | スクショ4〜5枚が作成・App Store Connect にアップロード済み |
| C-3 | アカウント削除→再ログインでデータ状態が期待通り（この plan で実機確認し、結果をメモに残す） |
| D | ユーザーがチェック（この plan の範囲外） |

---

## 参照ファイル

| ファイル | 用途 |
|---|---|
| `RELEASE_TEST_PLAN.md` | プレミアム機能 QA テストプラン（A-1, A-2, A-3 の更新対象） |
| `plans/dazzling-tickling-sun.md` | PR #212 の Maestro 修正プラン（参考） |
| `documents/PROJECT.md` | プロジェクト全体の機能ロードマップ |
| `documents/adr/0008-grant-promotional-premium-via-revenuecat-api.md` | プレミアム付与の仕組み（A-2 で使用） |
| `lib/features/developer_options/` | `grantPromotionalPremium` 呼び出し画面（A-2 で使用） |
| `maestro/flows/` | 更新対象の Maestro フロー（A-1 で再実行） |

---

## チェックリスト

### 実装内容
- [x] 変更対象ファイルごとに具体的なコード提案をコードブロックで記載している（本プランは監査のため、更新対象は `RELEASE_TEST_PLAN.md` のチェックボックス状態とエビデンス貼付のみ。実装コードは該当しない）
- [x] 既存コードのパターン・構成を確認し、同じパターンで実装している（`RELEASE_TEST_PLAN.md` のフォーマットに従う）

### 共通
- [ ] エラーメッセージはそのまま表示（加工・プレフィックス除去なし）
