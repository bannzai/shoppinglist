---
scope: repository
recorded: 2026-11-10
---
# このアプリの Maestro flow を書く時に、要素が見つからない・操作が効かない原因になる点

2026-06 に既存の flow を現行の UI に合わせ直した時に実測した。それぞれ、現行の flow に実例がある。

- **`text` は全体一致の正規表現**。部分一致しない。「サインアウトしますか?」のように末尾に `?` がある文言は `"サインアウトしますか.*"` と書く (`?` をそのまま書くと直前の文字を省略可能にする指定になる)。実例: `maestro/flows/auth_sign_out.yaml`
- **複数行が 1 つの要素にまとまる行は `(?s)` を付ける**。グループの行 (「名前未設定」を含む行)、カテゴリ管理のタイル、リストのセクションの見出し (「未分類」と件数) は、改行を含む 1 要素になる。`".*名前未設定.*"` では改行をまたげないため `"(?s).*名前未設定.*"` と書く。実例: `maestro/flows/category_select_from_item.yaml`
- **起動直後の待ち時間は長く取る**。`clearState` の後は Firebase の初期化で、オンボーディング・認証画面・リストの表示までに時間がかかる。`maestro/flows/shared/anonymous_sign_in.yaml` は 60000〜180000 ms を指定している
- **空のリストへの入力は「タップで入力開始」の行から始める**。以前の「アイテムを追加」ボタンは無い
- **アイテムを追加した後のキーボードは「Enter を 2 回 + `hideKeyboard`」で閉じる**。入力行はフォーカスを保つ作りのため、画面のタップでは閉じない。1 回目の Enter で確定し、2 回目の Enter で空の入力行が消える。実例: `maestro/flows/item_detail_and_delete.yaml`
- **チェックの切り替えは行の左端を座標でタップする**。`text: "牛乳"` でタップすると TextField にフォーカスが当たるだけになる。実例: `maestro/flows/add_and_check_item.yaml` (`point: "7%,23%"`)
- **左スワイプでの削除は、始点と終点を座標で書く**。`swipe` の `from: <文言>` と `direction: LEFT` では、行の文言が左寄りのため移動量が足りず削除にならない。右スワイプはチェックの切り替え、左スワイプは削除。実例: `maestro/flows/swipe_delete_item.yaml`
- **設定画面は、リストの上部のアイコン (`lib/features/shopping_list/components/list_top_bar.dart` の `app_settings_button`) から開く**。タブではない。`maestro/flows/settings_profile.yaml` などに残る「NavigationBar の 2 番目のタブ」というコメントは古い
- **「サインアウト」は設定画面の最下部にある**。タップの前に `scrollUntilVisible` が要る。確認ダイアログの確定ボタンも同じ文言のため、`rightOf` で「キャンセル」の右にあるボタンを指定する。実例: `maestro/flows/auth_sign_out.yaml`
- **設定の表示名は、フォーカスが外れた時に保存される** (保存ボタンは無い)。背景のタップではフォーカスが外れないため、`pressKey: enter` で保存する

**なぜ:** UI を作り直した後、既存の flow の多くが「要素が見つからない」で失敗した。原因はアプリの不具合ではなく flow の書き方で、上の点を 1 つずつ実測して直した。

**どう使う:** flow を新しく書く時・失敗した flow を直す時は、アプリの不具合を疑う前に上の点を確かめる。流した後は、各手順が COMPLETED になっていることを確かめる。
