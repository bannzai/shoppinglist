# 共通ルール

## 検証コマンド

### Flutter (lib/ に変更がある場合)
1. `dart run build_runner build`（freezed/riverpod_generator 対象の場合）
2. `flutter analyze`
3. `flutter test`
4. `flutter build ios`

### Firebase (firebase/ に変更がある場合)
`firebase/functions/functions/` ディレクトリで:
1. `npm run lint`
2. `npm run build`
3. `npm test`

検証でエラーが出た場合は修正して再検証する。

## コミット & PR

- `git add` で変更をステージング
- `git commit -m "fix: コーディング規約違反の修正 (PR #{{PR_NUMBER}})"`
- git add と git commit は別コマンドで実行
- commit メッセージに Claude が author であることは書かない
- `git push -u origin fix/coding-conventions-pr-{{PR_NUMBER}}`
- fix PR を作成:
  ```
  gh pr create \
    --base {{BASE_BRANCH}} \
    --head fix/coding-conventions-pr-{{PR_NUMBER}} \
    --title "fix: コーディング規約違反の修正 (PR #{{PR_NUMBER}})" \
    --body "..."
  ```
  - body に対象 PR へのリンク `#{{PR_NUMBER}}` を含める
  - body に違反一覧と修正内容を記載
  - body に Claude が author であることは書かない

## CI 確認 & マージ

- `gh pr checks` で CI の状態を確認。失敗していれば修正して再 push
- CI が通ったら: `gh pr merge --squash --delete-branch`
- マージ後: `git checkout {{BASE_BRANCH}}` && `git pull origin {{BASE_BRANCH}}`

## ベースブランチ PR の更新

- `gh pr list --base main --head {{BASE_BRANCH}} --json number --jq '.[0].number'` でベースブランチの PR 番号を取得
- PR 番号が取得できた場合、`/update-pr-body {ベースブランチPR番号}` を実行

## エラーハンドリング

- PR が見つからない場合: エラーを報告して終了
- 規約違反がない場合: 「規約違反なし」と報告して終了
- 検証が失敗し修正不能な場合: 現状を報告して終了（fix PR は作成しない）
- マージ競合が発生した場合: 競合を解消して再 push
