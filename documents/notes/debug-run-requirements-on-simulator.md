---
scope: repository
recorded: 2026-11-10
---
# simulator で debug ビルドを動かす時は dart-define が要る。無いと起動直後の白い画面で止まる

ローカルの simulator で実測した (2026-06)。

- **dart-define が無いと白い画面で止まる**: debug ビルドは `--dart-define=REVENUECAT_TEST_STORE_API_KEY=...` が無いと、`lib/utils/purchase/purchase.dart` の assert (`REVENUECAT_TEST_STORE_API_KEY is required in debug builds`) で `main()` が失敗し、起動画面の後に白い画面のままになる。開発者オプションのプレミアム付与などには `--dart-define=SHOPPINGLIST_DEVELOPER_TOKEN=...` も要る。渡す引数の正は `.vscode/launch.json` の `toolArgs` (値は環境変数から取る)
- **`--flavor dev` は付けない**: Xcode の scheme は `Runner` と `ShoppingListWidgetExtension` で、`dev` の scheme は無い。`.dev` の bundle ID は Debug の構成から決まる
- **`flutter run` を止めた後の debug ビルドは、アイコンから起動し直すと起動画面で止まる**。`flutter run` につないだ状態で操作する
- **`flutter build ios --simulator` の成果物は、単独で起動できる**。Maestro の E2E はこのビルドを `simctl install` して `launchApp` で起動すれば動き、`flutter run` は要らない
- **`flutter build ios --debug` の出力は実機向け** (`build/ios/iphoneos/Runner.app`)。simulator 向けの成果物は `build/ios/iphonesimulator/` に出ないため、`simctl install` は `No such file` で失敗する
- **「Running Xcode build...」が長く続いても止まっていない**。Firebase とウィジェットの拡張を含む最初のビルドは 10〜15 分かかった。2 回目以降の `flutter run` は約 30 秒でつながった

**なぜ:** 白い画面や長いビルドを「アプリの不具合」「ビルドが止まった」と取り違えて、原因の切り分けに時間を使った。

**どう使う:** ローカルで `flutter run` する時は `.vscode/launch.json` と同じ `--dart-define` を渡す。白い画面で止まったら、まず dart-define が渡っているかを確かめる。最初のビルドは `xcodebuild` のプロセスが動いている間は止めない。
