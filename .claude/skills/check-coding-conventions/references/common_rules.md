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

## エラーハンドリング

- PR が見つからない場合: エラーを報告して終了
- 検証が失敗し修正不能な場合: 現状を報告して終了（fix PR は作成しない）
- マージ競合が発生した場合: 競合を解消して再 push
- commit メッセージに Claude が author であることは書かない
- PR body に Claude が author であることは書かない
