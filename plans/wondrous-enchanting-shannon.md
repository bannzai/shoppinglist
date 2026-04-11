# iOS AppIcon更新のコミット & PR作成

## Context

`/commit-create-pr` の実行リクエスト。現在のワーキングツリーには iOS の AppIcon に関する変更が未コミット状態で残っている:

- **Modified**: `ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json`
  - JSONのフォーマット正規化(`"key" :` → `"key":`)
  - `1024x1024` `ios-marketing` の `filename` を `Icon-App-1024x1024@1x.png` から `AppIcon.png` に変更
- **Untracked**: `ios/Runner/Assets.xcassets/AppIcon.appiconset/AppIcon.png` (1024x1024 PNG, 新規追加)

これらの変更は `/ios-app-icon-generator` スキルで生成された新アイコン (`AppIcon.png`) を Xcode の AppIcon Asset Catalog に登録する内容と思われる。

旧ファイル `Icon-App-1024x1024@1x.png` は本変更後どこからも参照されなくなる(grepで他参照なしを確認済み)。**ユーザー判断: 本PRで一緒に削除する**。

## ブランチ戦略

- 現在ブランチ: `docs/ios-fastlane-metadata`
- 既存PR #214 が main 向けに OPEN ⇒ ユーザールールに従い、現在ブランチをベースにした**新規ブランチ**を作成して新規PRを起こす
- 新ブランチ名: `chore/ios-app-icon-update`
- ベースブランチ: `docs/ios-fastlane-metadata`

## 実行手順 (step-by-step)

### 1. 新ブランチ作成

```bash
git checkout -b chore/ios-app-icon-update
```

### 2. 旧ファイル削除

```bash
git rm ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png
```

### 3. ステージング (2ファイル)

`git add` と `git commit` は別コマンドで実行する(ユーザールール)。

```bash
git add ios/Runner/Assets.xcassets/AppIcon.appiconset/AppIcon.png
git add ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json
```

### 4. コミット

AppIcon.png の追加 / Contents.json の参照更新 / 旧ファイル削除は不可分なので 1 コミットにまとめる。

```bash
git commit -m "chore(ios): AppIcon更新 — AppIcon.png追加・旧1024x1024削除・Contents.json参照更新

- AppIcon.appiconset/AppIcon.png (1024x1024) を新規追加
- Contents.json の ios-marketing 1024x1024 の filename を AppIcon.png に変更
- Contents.json の JSON フォーマットを正規化 (\"key\" : → \"key\":)
- 不要になった Icon-App-1024x1024@1x.png を削除"
```

### 5. ビルド検証 (push 前)

Asset Catalog の整合性を確認するため、push 前にローカルビルドを実行する。

```bash
flutter build ios --no-codesign
```

ビルドが失敗した場合は push せず原因調査に切り替える。

### 6. push

```bash
git push -u origin chore/ios-app-icon-update
```

### 7. PR作成 (open, not draft)

`.github/pull_request_template.md` は存在しないため、独自bodyで作成。

```bash
gh pr create \
  --base docs/ios-fastlane-metadata \
  --head chore/ios-app-icon-update \
  --title "chore(ios): AppIcon.png追加とContents.json更新" \
  --body "$(cat <<'EOF'
## 概要

iOS の AppIcon Asset Catalog を更新する。

## 変更内容

### `ios/Runner/Assets.xcassets/AppIcon.appiconset/AppIcon.png` (新規)

- 1024x1024 PNG (8-bit RGB, non-interlaced)
- App Store / ios-marketing 用のアイコン画像

### `ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json`

- \`ios-marketing\` 1024x1024 の \`filename\` を \`Icon-App-1024x1024@1x.png\` から \`AppIcon.png\` に変更
- 既存の各エントリの JSON フォーマットを Xcode の標準形式 (\`\"key\":\`) に正規化

### `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png` (削除)

- Contents.json から参照されなくなった旧アイコンファイルを削除

## 補足

- ベースブランチ \`docs/ios-fastlane-metadata\` には fastlane metadata 用 PR #214 が main に向けて open 中。本PRはその上に積む形。
- push 前にローカルで \`flutter build ios --no-codesign\` を実行し、Asset Catalog の整合性を確認する。

## 動作確認

- [ ] Xcode で \`Runner.xcworkspace\` を開き、Asset Catalog 上で AppIcon が新しい画像で表示されること
- [ ] \`flutter build ios\` が成功すること
- [ ] iOS Simulator にビルドして起動 → ホーム画面で新アイコンが反映されていること
EOF
)"
```

## 検証 (実行前後)

| 項目 | コマンド/手順 | 期待結果 |
|---|---|---|
| Asset Catalog の整合性 | `cat ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json` で 1024x1024 の filename を確認 | `"filename": "AppIcon.png"` |
| AppIcon.png 存在確認 | `ls ios/Runner/Assets.xcassets/AppIcon.appiconset/AppIcon.png` | ファイルあり |
| iOSビルド | `flutter build ios --no-codesign` | 成功 |
| Xcode上のアイコン表示 | Xcode で Assets.xcassets > AppIcon を開く | App Store スロットに新画像 |
| Simulator起動アイコン | `flutter run -d <ios sim>` → ホームに戻る | 新アイコン表示 |

> ※ ビルドが失敗する場合は push せず原因調査に切り替える。

## 注意事項

- コミットのauthor情報に Claude を含めない
- `git add && git commit` のように `&&` で繋がない
- PR は draft ではなく open で作成
- 本タスク完了後、追加の指示があるまで commit/push/gh pr create/comment は自動で行わない

---

## チェックリスト

### 実装内容
- [ ] 変更対象ファイルごとに具体的なコード提案をコードブロックで記載している
- [ ] 既存コードのパターン・構成を確認し、同じパターンで実装している (Asset Catalog の Contents.json 形式は Xcode 標準に準拠)

### Flutter（lib/ に変更がある場合）
- 該当なし(`lib/` に変更なし。iOS リソースのみ)

### Firebase（firebase/ に変更がある場合）
- 該当なし

### 共通
- [ ] エラーメッセージはそのまま表示（加工・プレフィックス除去なし） — 該当箇所なし

### コミット & PR 固有
- [ ] 新ブランチを `docs/ios-fastlane-metadata` から作成
- [ ] `git add` と `git commit` を別コマンドで実行
- [ ] コミット author に Claude を含めない
- [ ] PR は open (not draft) で作成
- [ ] PR base = `docs/ios-fastlane-metadata`
- [ ] `.github/pull_request_template.md` の有無を確認 (なし)
- [ ] PR body に Claude が author であることを記載しない
