# Plan: issue #297 design v2 残作業 A/B/C 実行

## Context

issue #297 は design v2 完全準拠 (#261) の引き継ぎドキュメント。前セッションで PR #272–#296 (25 件) を merge 済み。残作業 A〜D のうち、本プランは **A / B / C** を対象とする (D の main マージは別 PR で対応)。

issue 執筆時は Maestro 未インストールで A がブロックされていたが、現環境では **Maestro 2.2.0 がインストール済み** で実行可能。Web preview 側にも `tw.dark` toggle が存在 (`design_handoff_shoppinglist/preview/app.jsx:4` / `tweaks-panel.jsx`)、3 環境とも Light/Dark 比較可能。

調査で判明した重要事項:
- `tmp/screenshots/web/` は実在せず、issue 記載の「13 枚取得済み」も実ファイルとしては未配置 → **17 画面 × Light/Dark を全環境で取得し直す前提**
- `documents/design-handoff-v2-screenshot-comparison.md` には 12 画面の PASS 宣言のみ。残り 5 画面 (Category list/edit, Filter, List setting) は未記載
- `documents/design-handoff-v2-verification.md` の 17 画面 × Light/Dark マトリクスはほぼ 🟡/⏸️ 状態

## 目標

1. iOS (iPhone 16 Plus) / Android (Pixel_9_Pro) / Web preview の 3 環境で 17 画面 × Light/Dark = **102 枚** のスクショを `tmp/screenshots/` 配下に保存する
2. `documents/design-handoff-v2-screenshot-comparison.md` を 17 画面全てカバーする形に拡張し PASS/FAIL を file:line + 修正案で列挙する
3. `documents/design-handoff-v2-verification.md` のマトリクスを全 ✅ に昇格 (FAIL があれば修正→再撮 PASS まで反復)
4. FAIL 検出時は `plans/261-warm-engelbart.md:43-53` 運用ルール 3 手順 d-e に従い同 issue 内で完結

## 実行順序

```
[並列起動可]
  iOS Simulator boot + Preview install ─┐
  Android Emulator boot + Preview install ─┼─→ A. Maestro 実行 (iOS Light → iOS Dark → Android Light → Android Dark)
  python3 -m http.server 起動 ──────────┘
                                          ├─→ B. agent-browser で Web Light/Dark 撮影 (A と並列可)
                                          ↓
                                          C. 3 環境画像比較 → comparison.md / verification.md 更新 → (FAIL あれば修正→A 再走)
                                          ↓
                                          検証: flutter analyze / test / build ios / build apk
```

A.iOS / A.Android / B.Web は完全独立 → バックグラウンドジョブで並列実行可。

## 変更対象ファイル

### 1. 新規 ad-hoc YAML (作業中のみ存在、コミット対象外)
- `tmp/maestro/capture_single_screen.yaml` — FAIL 検出時の単画面再撮用

### 2. 既存 YAML (変更なし、保存先のみ後処理で移動)
- `maestro/preview_flows/capture_all_previews.yaml` (192 行) — そのまま使用、`screenshots/*.png` を出力先ごとに mv

### 3. 更新ドキュメント
- `documents/design-handoff-v2-screenshot-comparison.md` — 残り 5 画面の比較章追記 + 17 画面 × Light/Dark の表に拡張
- `documents/design-handoff-v2-verification.md` — マトリクスを ✅ に更新

### 4. FAIL 修正対象 (発生時のみ)
- `lib/features/**/*.dart` — UI 修正
- `lib/components/**/*.dart` — Frame Widget 修正
- 修正後は `flutter analyze` / `flutter test` 必須

### 5. スクショ保存先 (新規ディレクトリ)
```
tmp/screenshots/
├── ios/
│   ├── light/   # 17 PNG (00_onboarding_page.png 〜 16_invitation_verifying.png)
│   └── dark/    # 17 PNG
├── android/
│   ├── light/   # 17 PNG
│   └── dark/    # 17 PNG
└── web/
    ├── light/   # 17 PNG
    └── dark/    # 17 PNG
```

## 実装詳細

### 0. 環境準備

iOS Simulator boot + Preview build & install:
```bash
# iPhone 16 Plus (UUID: A440EFCF-F99F-473D-940C-6E0E52FF526C)
xcrun simctl boot A440EFCF-F99F-473D-940C-6E0E52FF526C 2>/dev/null || true
open -a Simulator
xcrun simctl bootstatus A440EFCF-F99F-473D-940C-6E0E52FF526C

flutter build ios --simulator -t lib/features/previews/main_preview.dart
xcrun simctl install booted build/ios/iphonesimulator/Runner.app
```

Android Emulator boot + Preview build & install (Pixel_9_Pro):
```bash
~/Library/Android/sdk/emulator/emulator -avd Pixel_9_Pro -no-snapshot-load &
adb wait-for-device
adb shell 'while [[ "$(getprop sys.boot_completed)" != "1" ]]; do sleep 1; done'

flutter build apk --debug -t lib/features/previews/main_preview.dart
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

Web preview server 起動:
```bash
cd design_handoff_shoppinglist/preview
python3 -m http.server 8765 &
PREVIEW_PID=$!
# 終了時に kill: kill $PREVIEW_PID
```

### A. Maestro スクショ取得 (iOS / Android × Light/Dark)

iOS Light:
```bash
xcrun simctl ui booted appearance light
rm -rf screenshots
maestro test maestro/preview_flows/capture_all_previews.yaml
mkdir -p tmp/screenshots/ios/light
mv screenshots/*.png tmp/screenshots/ios/light/
```

iOS Dark:
```bash
xcrun simctl ui booted appearance dark
rm -rf screenshots
maestro test maestro/preview_flows/capture_all_previews.yaml
mkdir -p tmp/screenshots/ios/dark
mv screenshots/*.png tmp/screenshots/ios/dark/
```

Android Light (Maestro はホスト OS の adb/simctl を直接叩くため、iOS と並列実行不可。iOS 完了後に切替):
```bash
xcrun simctl shutdown booted  # iOS 落とす (Maestro が iOS を優先するのを防ぐ)
adb shell "cmd uimode night no"
rm -rf screenshots
maestro test maestro/preview_flows/capture_all_previews.yaml
mkdir -p tmp/screenshots/android/light
mv screenshots/*.png tmp/screenshots/android/light/
```

Android Dark:
```bash
adb shell "cmd uimode night yes"
rm -rf screenshots
maestro test maestro/preview_flows/capture_all_previews.yaml
mkdir -p tmp/screenshots/android/dark
mv screenshots/*.png tmp/screenshots/android/dark/
```

design_v2_* flow 9 本の動作確認 (assert のみ、回帰検証として iOS Light で 1 周):
```bash
xcrun simctl boot A440EFCF-F99F-473D-940C-6E0E52FF526C
xcrun simctl ui booted appearance light
for f in maestro/flows/design_v2_*.yaml; do
  echo "== Running $f =="
  maestro test "$f" || { echo "FAIL: $f"; exit 1; }
done
```

### B. Web preview スクショ (Light/Dark × 17 画面)

Web preview の Dark 切替は `tw.dark` (`design_handoff_shoppinglist/preview/app.jsx:4`) で制御される。`tweaks-panel.jsx` の Dark toggle をクリックすると 17 アートボード全てが Dark 化する。

agent-browser で取得 (skill `/agent-browser` を使用):
```bash
# 1. preview を開く
agent-browser open "http://localhost:8765/買い物リスト UI再設計.html"
agent-browser wait --load networkidle

# 2. アートボード一覧の ref を取得
agent-browser snapshot -i | grep "data-dc-slot" | tee tmp/web_slots.txt

# 3. Light モードで 17 アートボード撮影
mkdir -p tmp/screenshots/web/light
# slot ref を順次スクロール → screenshot
# 想定 slot 名 (app.jsx:30-200):
#   01-onboarding-slide1/2/3, 02-auth, 02-auth-loading-apple, 02-auth-error
#   03-home-list, 03-home-settings, 04-shopping-list-*, 05-list-setting-*
#   06-filter, 06-filter-no-category, 07-group-list, 08-group-create
#   09-group-setting, 10-group-invitation-accept, 09-location, 11-cat-list
#   12-cat-edit, 13-ai-review, 14-sign-out, 15-invitation-verifying, etc.
for slot in $(cat tmp/web_slots.txt); do
  agent-browser scrollintoview "@e${slot}"
  agent-browser screenshot "tmp/screenshots/web/light/${slot}.png"
done

# 4. Dark mode toggle ON → 同 17 アートボード再撮影
agent-browser click "[role='switch'][aria-label*='Dark']" # tweaks-panel.jsx の dark toggle
mkdir -p tmp/screenshots/web/dark
for slot in $(cat tmp/web_slots.txt); do
  agent-browser scrollintoview "@e${slot}"
  agent-browser screenshot "tmp/screenshots/web/dark/${slot}.png"
done
```

実 slot 名は `tweaks-panel.jsx` で `__activate_edit_mode` postMessage 後に DOM スナップショット取得して確定する。

### C. 3 環境画像比較 → ドキュメント更新

#### C-1. comparison.md 拡張

既存 `documents/design-handoff-v2-screenshot-comparison.md` は 12 画面の PASS 宣言サマリ。これを拡張し:

1. 各画面ごとに 6 枚 (iOS-L / iOS-D / Android-L / Android-D / Web-L / Web-D) のパス参照表を作る
2. Read tool で画像を実際に開いて比較
3. PASS/FAIL を `**判定**: PASS` または `**FAIL**: file_path:line — 修正案: <内容>` 形式で記載

具体的な追記サンプル:
```markdown
## GroupCategoryPage 詳細

| 環境 | Light | Dark |
|---|---|---|
| iOS | `tmp/screenshots/ios/light/10_group_category_page.png` | `tmp/screenshots/ios/dark/10_group_category_page.png` |
| Android | `tmp/screenshots/android/light/10_group_category_page.png` | `tmp/screenshots/android/dark/10_group_category_page.png` |
| Web | `tmp/screenshots/web/light/11-cat-list.png` | `tmp/screenshots/web/dark/11-cat-list.png` |

**Web SSOT** (`11-cat-list`):
- カテゴリ行リスト (アイコン + 名前 + 「N 件」)
- 末尾「カテゴリを追加」AppCell

**Flutter 実装**: `lib/features/group/category/page.dart:XX`

**判定**: PASS / FAIL
（FAIL の場合）file_path:line — 修正案: <具体的な修正>
```

#### C-2. verification.md マトリクス更新

`documents/design-handoff-v2-verification.md:17-37` の表で各画面 × Light/Dark を ✅ に更新。FAIL のある画面のみ 🟡 のまま残し、対応 PR でクローズ。

### FAIL 検出時の修正ループ

`plans/261-warm-engelbart.md:43-53` 運用ルール 3 手順 d-e に従う:

1. 画像比較で `file_path:line — 修正案` 形式で FAIL を列挙
2. Flutter コード修正 (`lib/components/`, `lib/features/`)
3. `flutter analyze` / `flutter test` を即実行 (PASS まで)
4. **該当画面のみ単画面再撮**: ad-hoc YAML を作成
   ```yaml
   # tmp/maestro/capture_single_screen.yaml
   appId: com.bannzai.shoppinglist
   ---
   - launchApp:
       clearState: true
   - assertVisible: "Previews"
   - tapOn: "GroupCategoryPage"   # ← 修正画面に応じて変更
   - waitForAnimationToEnd
   - takeScreenshot: screenshots/refresh
   ```
   ```bash
   maestro test tmp/maestro/capture_single_screen.yaml
   mv screenshots/refresh.png tmp/screenshots/ios/light/10_group_category_page.png
   ```
5. 再度 C の画像比較に戻る
6. **PASS まで同 issue 内で完結** (運用ルール `:69`)

### 決定事項差分の PASS 扱い

`plans/261-warm-engelbart.md:54-65` 運用ルール 4 の項目は FAIL ではなく **PASS** 扱い:
- Onboarding コピー (JSX SSOT 採用)
- 5 色 canonical 固定
- Auth ゲストリンク無し
- AI アイコン生成タイル無し
- 担当者除外
- 画像素材 (Web placeholder vs 本物アセット)
- フォント差分許容
- Android Widget RemoteViews 制約
- i-N ID 表記
- Location 地図 PRO バッジ

これらは comparison.md 末尾に「決定事項差分一覧」として再掲し、各画面の判定では除外する。

## 検証

A/B/C 完了後に以下を実行 (FAIL 修正の有無に関わらず必須):

```bash
# Flutter コード品質
flutter analyze                                                             # → No issues found
flutter test                                                                # → 145/145 pass (or +N for new tests)

# Build 確認 (preview entry point)
flutter build ios --simulator -t lib/features/previews/main_preview.dart    # → 成功
flutter build apk --debug   -t lib/features/previews/main_preview.dart      # → 成功

# Maestro design_v2_* 9 本回帰
for f in maestro/flows/design_v2_*.yaml; do maestro test "$f"; done         # → 全 PASS

# Firebase 側は本作業で変更しないため省略可。念のため確認したい場合:
cd firebase/functions && npm run lint && npm run build && npm test
```

## 重要な参照ファイル

- 撮影フロー: `maestro/preview_flows/capture_all_previews.yaml`
- 回帰検証: `maestro/flows/design_v2_*.yaml` (9 ファイル)
- preview エントリ: `lib/features/previews/main_preview.dart`
- preview 一覧: `lib/features/previews/previews_page.dart:28-101` (17 エントリ)
- Web SSOT: `design_handoff_shoppinglist/preview/買い物リスト UI再設計.html`
- Web tweaks: `design_handoff_shoppinglist/preview/tweaks-panel.jsx`
- 運用ルール: `plans/261-warm-engelbart.md:43-53` (運用ルール 3 / 手順 d-e)
- 比較レポート: `documents/design-handoff-v2-screenshot-comparison.md`
- 検証マトリクス: `documents/design-handoff-v2-verification.md`

## 残作業 D (本プラン対象外)

`refactor/design-handoff-v2-round4` 全体を main に merge する最終 PR (600+ ファイル / 6,000+ 行) は別タスクで扱う。C 完了後に別 issue/PR を起こす想定。

---

## チェックリスト

### 実装内容
- [ ] 変更対象ファイルごとに具体的なコード提案をコードブロックで記載している
- [ ] 既存コードのパターン・構成を確認し、同じパターンで実装している (capture_all_previews.yaml / 261-warm-engelbart.md 運用ルール準拠)

### Flutter (lib/ に変更がある場合 — FAIL 修正時のみ)
- [ ] コード生成: `dart run build_runner build` で生成ファイル更新 (該当する場合)
- [ ] 静的解析: `flutter analyze` エラーなし
- [ ] テスト: `flutter test` 全件パス (現状 145 件)
- [ ] iOS ビルド: `flutter build ios --simulator -t lib/features/previews/main_preview.dart` 成功
- [ ] Android ビルド: `flutter build apk --debug -t lib/features/previews/main_preview.dart` 成功
- [ ] 新規・変更機能に対するテストが存在する (なければ新規作成)
- [ ] Maestro E2E: `capture_all_previews.yaml` + `design_v2_*.yaml` 9 本実行 PASS
- [ ] Entity 命名: フィールド名が省略されていない
- [ ] DB 操作: Firestore 操作は `call` クラスの Provider 経由
- [ ] 引数: 関数・コンストラクタの引数に `{required}` あり (timestamp 等メタデータ除く)
- [ ] ref 使い分け: build 内は `ref.watch`、コールバック・操作は `ref.read`
- [ ] サブコレクション Entity に親ドキュメント ID フィールドあり (該当する場合)

### Firebase (firebase/ に変更がある場合 — 本作業では原則変更なし)
- [ ] Lint: `npm run lint` パス (firebase/functions/functions/ で実行)
- [ ] ビルド: `npm run build` 成功
- [ ] テスト: `npm test` 全件パス
- [ ] クライアント呼び出し関数は GenKit で定義
- [ ] onDocumentCreated/onDocumentUpdated トリガーを使っていない
- [ ] 新規・変更機能に対するテストが存在する (なければ新規作成)

### 共通
- [ ] エラーメッセージはそのまま表示 (加工・プレフィックス除去なし)
- [ ] `documents/design-handoff-v2-screenshot-comparison.md` に 17 画面 × Light/Dark の比較章を追記
- [ ] `documents/design-handoff-v2-verification.md` のマトリクスを ✅ に更新 (FAIL ありの画面のみ 🟡 保持)
- [ ] tmp/screenshots/ 配下に 102 枚 (17 × 2 テーマ × 3 環境) 保存
- [ ] FAIL があれば修正→再撮 PASS まで同 issue 内で反復 (運用ルール 3 手順 d-e)
