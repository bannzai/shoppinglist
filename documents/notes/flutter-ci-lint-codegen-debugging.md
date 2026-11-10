---
scope: repository
recorded: 2026-11-10
---
# flutter-ci の lint・codegen の失敗は、ローカルの build_runner のキャッシュを消してから再現する

`.github/workflows/flutter-ci.yml` の lint・codegen のジョブが失敗した時に、原因の切り分けで時間を使った点。

- **`pull_request` の CI は、PR を最新の main にマージした状態で動く**。ブランチが main から遅れていると、main の側の失敗 (整形・生成物の差分) を巻き込んで失敗する。先に `gh run list --branch main --workflow flutter-ci.yml` で main が成功しているかを見る
- **codegen のジョブ** は `dart pub run build_runner build --delete-conflicting-outputs` の後に `git diff --quiet --exit-code` を実行する。生成物 (例: `lib/provider/*.g.dart` の Riverpod のハッシュ) が古いと差分が出て失敗する
- **build_runner の増分キャッシュ (`.dart_tool/build`) は git の管理外で、`git reset --hard` では消えない**。そのためローカルで `build_runner build` を実行しても再生成が省かれ、「差分なし」に見えて生成物の古さに気づけないことがあった (memory に記録した時点の実測。記録に日付と build_runner の版は無く、今の `pubspec.lock` の版で再現するかは確かめていない)
- **lint のジョブ** は `make secret` → `flutter analyze --no-pub --no-fatal-infos --fatal-warnings` → `dart format --set-exit-if-changed ./` の順に実行する
  - `make secret` を実行していないと、analyze が `Undefined name 'Secret'` で失敗する (`lib/secret/secret.dart` は `make secret` が作るファイルで git の管理外)
  - `--no-fatal-infos` のため、info は CI を失敗させない (失敗させるのは warning と error)
  - `dart format` はリポジトリ全体が対象

**なぜ:** CI は毎回キャッシュの無い状態でビルドするため、ローカルのキャッシュが隠した差分が CI でだけ出る。

**どう使う:** codegen の失敗をローカルで確かめる時は、`dart run build_runner clean` を実行してからビルドし、`git diff` で差分を見る。
