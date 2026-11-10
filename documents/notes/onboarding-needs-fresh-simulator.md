---
scope: repository
recorded: 2026-11-10
---
# オンボーディングは、アプリを削除しても再表示されない。Keychain が空の新しい simulator で再現する

オンボーディング (`lib/features/onboarding/page.dart`) は、`AuthResolver` (`lib/features/resolver/auth.dart`) が「未サインイン」かつ `hasSeenOnboarding` が false の時だけ表示する。`xcrun simctl uninstall` でアプリを消して入れ直しても、オンボーディングは出ず本体の画面に入った (実測)。

**なぜ:** `lib/main.dart` が `FirebaseAuth.instance.setSettings(userAccessGroup: ...)` で Keychain の共有グループを使うため、アプリを削除しても認証の状態が Keychain に残り、起動時にサインイン済みと判定される。

**どう使う:**

- 新規ユーザーの状態 (オンボーディングの表示) を確かめる時は、アプリの削除ではなく、新しく作った simulator (Keychain が空) を使う
- 起動時に `FirebaseMessaging.requestPermission()` の通知の許可ダイアログが出るので、許可してから進む
- Maestro では `launchApp` に `clearState: true` と `clearKeychain: true` の両方を指定するとオンボーディングが出る。`maestro/flows/shared/anonymous_sign_in.yaml` が「スキップ」を待ってタップしている
