---
feature: onboarding
verification: mobile-mcp, maestro
last_verified_commit: 2d72174fa713d1fc25d91c862113470193694a22
last_verified_at: 2026-07-05
---

# onboarding QA

## 1. スライド表示

- [x] **スライド枚数**: 現行リリース（`shoppingLocationFeatureEnabled` = false）では2枚（「家族と作る、買い物リスト」「同じリストを同時に編集」）のみ表示され、店舗近接通知の訴求スライドは表示されない（issue #465）
- [x] **スライド内容表示**: 各スライドにタイトル・本文・イラスト（画像またはフォールバック描画）・ページ番号「01/02」形式が表示される
- [ ] **画像読み込み失敗時のフォールバック**: `images/onboarding/slide_*.png` の読み込みに失敗した場合、Flutter描画のフォールバックアート（傾いたリストカード／アバターオービット）が代わりに表示される
- [x] **ドットインジケーター**: 現在のスライド位置に応じてアクティブなドットのみ横長表示になる

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **スライド枚数**: 現行リリース（`shoppingLocationFeatureEnabled` = false）では2枚（「家族と作る、買い物リスト」「同じリストを同時に編集」）のみ表示され、店舗近接通知の訴求スライドは表示されない（issue #465）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

サインアウト→アプリ再インストール（`hasSeenOnboarding`/認証状態をクリア）した状態で起動。スライド1・スライド2ともにドットインジケーターは2個のみで、ページ番号も最大「02/02」までしか出ないことを確認した（`shoppingLocationFeatureEnabled = false` によりスライド3は生成されない）。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/fe4c6e8a-794c-4599-8b7c-1f2140fc18cf.png" width="320">
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/ab6efd21-96ff-4bec-8a1d-3d4f425b1686.png" width="320">

</details>

### **スライド内容表示**: 各スライドにタイトル・本文・イラスト（画像またはフォールバック描画）・ページ番号「01/02」形式が表示される

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

スライド1「01/02 家族と作る、買い物リスト」＋チェックリスト画像、スライド2「02/02 同じリストを同時に編集」＋アバターオービット画像。タイトル・本文・イラスト・ページ番号がいずれも表示されることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/fe4c6e8a-794c-4599-8b7c-1f2140fc18cf.png" width="320">
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/ab6efd21-96ff-4bec-8a1d-3d4f425b1686.png" width="320">

</details>

### **画像読み込み失敗時のフォールバック**: `images/onboarding/slide_*.png` の読み込みに失敗した場合、Flutter描画のフォールバックアート（傾いたリストカード／アバターオービット）が代わりに表示される

<details><summary>動作確認スクショ</summary>

（未実行）

⏭️ スキップ: 実機トリガーには `images/onboarding/slide_*.png` を読み込み失敗させる必要がある。インストール済みアプリのバンドル内アセット（`Runner.app/Frameworks/App.framework/flutter_assets/images/onboarding/`）はこのセッションの作業ディレクトリ外にあり、サンドボックス制約でリネーム・削除ができない。リポジトリ側のアセットファイルを一時的に退避する方法は可能だが、`flutter run` の再ビルドが往復2回必要な上、セッション中断時にリポジトリのアセットが欠落した状態で残るリスクがあるため見送った。ロジックは静的検証で確認済み: `lib/features/onboarding/page.dart` の `_OnboardingSlide.build()` で `Image.asset(data.assetPath, errorBuilder: (context, error, stackTrace) => data.fallbackBuilder(tokens))` と実装されており、読み込み失敗時にスライド1は `_TiltedListArt`、スライド2は `_AvatarOrbitArt` を描画する。実機での動作確認は、別セッションでリポジトリのアセットを一時退避のうえ単独実行することを推奨する。

</details>

### **ドットインジケーター**: 現在のスライド位置に応じてアクティブなドットのみ横長表示になる

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

スライド1では1個目のドットが横長（accent色）、2個目が小さい丸。スワイプでスライド2に切り替えると、1個目が小さい丸、2個目が横長に切り替わることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/fe4c6e8a-794c-4599-8b7c-1f2140fc18cf.png" width="320">
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/ab6efd21-96ff-4bec-8a1d-3d4f425b1686.png" width="320">

</details>

</details>

---

## 2. スライド操作

- [x] **スワイプでスライド送り**: 左右スワイプでスライドが切り替わり、ドットインジケーターとページ番号が連動して更新される
- [x] **「次へ」ボタンでスライド送り**: 最終スライド以外では下部ボタンが「次へ」と表示され、タップで次のスライドにアニメーション遷移する
- [x] **最終スライドで「はじめる」表示**: 最終スライドではボタンラベルが「はじめる」に変わる

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **スワイプでスライド送り**: 左右スワイプでスライドが切り替わり、ドットインジケーターとページ番号が連動して更新される

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

スライド1で左スワイプするとスライド2（02/02、ドット2個目がアクティブ）へ切り替わり、右スワイプで戻ることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/ab6efd21-96ff-4bec-8a1d-3d4f425b1686.png" width="320">

</details>

### **「次へ」ボタンでスライド送り**: 最終スライド以外では下部ボタンが「次へ」と表示され、タップで次のスライドにアニメーション遷移する

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

スライド1で「次へ」ボタンをタップし、アニメーション遷移でスライド2（02/02）に切り替わることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/2dca8d9d-1cce-492d-bfe1-68beb888a0df.png" width="320">

</details>

### **最終スライドで「はじめる」表示**: 最終スライドではボタンラベルが「はじめる」に変わる

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

最終スライド（02/02）で下部ボタンラベルが「はじめる」に変わることを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/2dca8d9d-1cce-492d-bfe1-68beb888a0df.png" width="320">

</details>

</details>

---

## 3. オンボーディング終了

- [x] **スキップで終了**: 右上「スキップ」タップで `hasSeenOnboarding` がtrueに保存され、認証画面（AuthPage）に遷移する。maestro/flows/group_join_or_create.yaml の冒頭で「スキップ」タップによる遷移を確認できる（オンボーディング専用フローではなく他機能フローの前段として使用されている点に注意）
- [x] **「はじめる」で完走終了**: 最終スライドで「はじめる」タップで `hasSeenOnboarding` がtrueに保存され、認証画面に遷移する
- [x] **再表示されないこと**: 一度スキップ／完走した後にアプリを再起動しても、オンボーディングは再表示されず認証画面（未サインインの場合）またはホーム（サインイン済みの場合）が表示される

#### 動作確認
<details>
<summary>動作確認エビデンス</summary>

### **スキップで終了**: 右上「スキップ」タップで `hasSeenOnboarding` がtrueに保存され、認証画面（AuthPage）に遷移する。maestro/flows/group_join_or_create.yaml の冒頭で「スキップ」タップによる遷移を確認できる（オンボーディング専用フローではなく他機能フローの前段として使用されている点に注意）

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

未サインイン・`hasSeenOnboarding=false` の状態でオンボーディングを起動し、右上「スキップ」をタップすると認証画面（AuthPage）に遷移することを確認した。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/70c673d1-f0c9-42e7-bbd0-57bbbc490135.png" width="320">

</details>

### **「はじめる」で完走終了**: 最終スライドで「はじめる」タップで `hasSeenOnboarding` がtrueに保存され、認証画面に遷移する

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

最終スライド（02/02）で「はじめる」をタップすると `finish_onboarding`（reason: complete）が記録され、認証画面（AuthPage）に遷移することを確認した（`flutter run` の stdout でも `logEvent name: finish_onboarding, parameters: {reason: complete, lastIndex: 1}` を確認済み）。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/ad91ff7f-8fec-4e7d-8e1d-f63614c1468d.png" width="320">

</details>

### **再表示されないこと**: 一度スキップ／完走した後にアプリを再起動しても、オンボーディングは再表示されず認証画面（未サインインの場合）またはホーム（サインイン済みの場合）が表示される

<details><summary>動作確認スクショ</summary>

**確認日: 2026-07-05**

「はじめる」で完走した直後にアプリを終了→再起動しても認証画面が直接表示され、オンボーディングは再表示されないことを確認した。同様に、別途アプリを再インストールして `hasSeenOnboarding=false` に戻した状態で「スキップ」を実行→再起動した場合も認証画面が直接表示されることを確認した（いずれも未サインイン状態のケース）。

<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/76577e16-6c52-4935-a467-5eae71bed5c6.png" width="320">
<img src="https://pub-7f3469dd3e2e445b9b8ec2d1381b5ea8.r2.dev/bannzai/shoppinglist/20260705/ec6bb5ac-4279-4392-b215-97a71ef486c4.png" width="320">

</details>

</details>
