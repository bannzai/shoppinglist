---
scope: repository
recorded: 2026-11-10
---
# `flutter pub get` の前に `.dart` を編集すると、hook の `dart format ./` がリポジトリ全体を書き換える

`.claude/settings.json` の PostToolUse の hook は、`.dart` のファイルを編集するたびに `dart format ./` (リポジトリ全体) を実行する。

worktree を作った直後など `.dart_tool/package_config.json` が無い状態では、formatter がパッケージの設定を読めず、コミット済みのファイルを別の形に整形する。2026-11-10 に `.dart_tool` が無い worktree で `dart format --output=none --set-exit-if-changed ./` (書き込まない確認) を実行すると、`Failed to resolve package URI "package:flutter_lints/flutter.yaml"` の警告とともに多数のファイルが `Changed` と出て exit 1 になった。

過去に起きた例:

- 2026-06-11: 新しい worktree で `pub get` の前に `.dart` を編集し、コミットの直前に約 200 ファイルの差分に気づいた。`pub get` の後は差分が 0 になった
- 2026-09-17: `flutter pub get` が失敗した直後に `dart format ./` を実行し、130 ファイルが整形された

**なぜ:** この整形は末尾のカンマを足すため、後から正しい設定で整形し直しても元に戻らない。CI の lint は `dart format --set-exit-if-changed ./` で検査するため、そのままコミットすると失敗する。

**どう使う:**

- 新しい worktree では、`.dart` を編集する前に `flutter pub get` を実行する
- `flutter pub get` が失敗した状態で `dart format` を実行しない
- 全体が整形されてしまったら、自分の変更を消さないよう、先に `mkdir -p tmp` の後に `git diff > tmp/before-revert.patch` で差分を保存し、ファイルができて中身があることを確かめる (保存に失敗したら、戻す操作に進まない)。その後、自分が編集していないファイルだけを `git checkout -- <パス>` で戻す。自分が編集したファイルは整形の差分と変更が混ざっているため、戻してから `flutter pub get` の後に変更を当て直す (`git checkout -- .` は未コミットの変更をすべて捨てるので、差分を保存する前に実行しない)
- コミットの前に `git status` と `dart format --output=none --set-exit-if-changed ./` で確かめる
