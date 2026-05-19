# iOS Simulator での APNs token 取得エラー修正

## Context

iOS Simulator 実行中に以下のエラーが継続的に出ている。

```
flutter: [SL:DEBUG] [FCM] トークン取得エラー: [firebase_messaging/apns-token-not-set]
APNS token has not been received on the device yet.
Please ensure the APNS token is available before calling `getAPNSToken()`.
```

### 原因

`lib/provider/fcm_token.dart:22` の `FirebaseMessaging.instance.getToken()` 呼び出し内部で APNs token を要求するが、iOS native 側で **Push Notifications capability (`aps-environment` entitlement) が未設定**のため `registerForRemoteNotifications` が成功せず APNs token が永久に届かない。

調査で確定した状態:

- `ios/Runner/Runner.entitlements` に `aps-environment` キー無し
- `ios/Runner.xcodeproj/project.pbxproj` に `com.apple.Push` の SystemCapability 記述無し
- `ios/Runner/Info.plist` の `UIBackgroundModes` に `remote-notification` は **あり**（OK）
- `AppDelegate.swift` は FCM の Method Swizzling に任せた構成（OK、native での override 不要）
- 依存: `firebase_messaging: 16.1.1`, `FirebaseMessaging (iOS): 12.8.0`, iOS deployment target `16.0`

### Simulator 動作の前提知識

Xcode 14 + iOS 16 + macOS 13 Ventura 以降の Simulator は、Push Notifications capability があれば APNs token を取得できる。本プロジェクトは iOS deployment target 16.0 / firebase_messaging 16.1.1 で要件を満たすため、capability さえ追加すれば Simulator でも実機でも token 取得可能になる。

### 通知機能の現状

ユーザー確認済み: **通知機能はまだ未使用**。FCM token の Firestore 登録はしているが送信側は未実装。今回の修正は「Simulator デバッグ中のエラーログ解消」と「将来の通知実装の前提整備」が目的。

## 修正方針

**Push Notifications capability の追加のみ**（root cause 修正）。リトライ等のタイミング対策は今回は入れず、動作確認で必要性を見極める。

実施手順は 2 通り。**Xcode GUI 操作を推奨**。

### 推奨手順: Xcode GUI から追加

1. `open ios/Runner.xcworkspace` で Xcode を起動
2. プロジェクトナビゲータで `Runner` プロジェクト → `Runner` ターゲット
3. `Signing & Capabilities` タブ
4. `+ Capability` → `Push Notifications` をダブルクリックして追加
5. 保存（Xcode を閉じる、または `⌘S`）

この操作で以下 2 ファイルが自動更新される。差分は git で確認する。

### 代替手順: 手動編集（GUI が使えない場合）

Xcode GUI が使えない場合は下記コード提案の通り 2 ファイルを直接編集する。ただし `project.pbxproj` の SystemCapabilities セクションは Xcode のメタデータで、ビルド・APNs 登録自体は `entitlements` の `aps-environment` だけで成立する。最低限 `entitlements` だけ編集すれば Simulator/実機での APNs token 取得は動作する。

## 変更ファイル

### 1. `ios/Runner/Runner.entitlements`

`aps-environment` キーを追加する。値は development（Debug/Release で同一でも Apple 側がプロビジョニングプロファイルで切り替えるため `development` 固定で問題ない。Xcode GUI 経由で追加した場合も `development` が入る）。

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>aps-environment</key>
    <string>development</string>
    <key>com.apple.developer.applesignin</key>
    <array>
        <string>Default</string>
    </array>
    <key>com.apple.security.application-groups</key>
    <array>
        <string>group.com.bannzai.shoppinglist</string>
    </array>
    <key>keychain-access-groups</key>
    <array>
        <string>$(AppIdentifierPrefix)com.bannzai.shoppinglist</string>
    </array>
</dict>
</plist>
```

### 2. `ios/Runner.xcodeproj/project.pbxproj`（Xcode GUI 追加時に自動更新される箇所）

Xcode で capability を追加すると `PBXProject` セクションの `TargetAttributes` 内 `Runner` ターゲットに `SystemCapabilities` が記述される。手動編集の場合は該当ターゲット属性に以下を追記する。

```
TargetAttributes = {
  <RunnerTargetUUID> = {
    CreatedOnToolsVersion = ...;
    SystemCapabilities = {
      com.apple.Push = {
        enabled = 1;
      };
    };
  };
};
```

注: 既に `TargetAttributes` が存在する場合は `SystemCapabilities` のみマージする。git diff で Xcode が生成した形に合わせるのが最も確実なので、迷ったら **Xcode GUI で追加する**。

### 3. 他のターゲット（`RunnerTests` 等）について

`project.pbxproj` の `CODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements;` は 668, 853, 878 行目に複数記載されている（Debug/Release/Profile 構成）。entitlements ファイル自体を共有しているため、上記 1. の変更のみで全構成に反映される。

## 動作確認

### 自動チェック

```bash
# 静的解析
flutter analyze

# iOS ビルド（Simulator 向け）
flutter build ios --debug --simulator --no-codesign

# ユニットテスト
flutter test
```

### Simulator での手動動作確認

事前準備: iPhone 16 Plus を起動（個人ルール: E2E は iPhone 16 Plus 固定）。

```bash
# Simulator 起動
xcrun simctl boot "iPhone 16 Plus"
open -a Simulator

# 実行
flutter run -d "iPhone 16 Plus"
```

確認項目:

- [ ] アプリ起動 → 通知許可ダイアログで「許可」を選択
- [ ] ログイン or 既ログイン状態で `appUser` が確定する
- [ ] **`[SL:DEBUG] [FCM] トークン取得エラー` が出ないこと**
- [ ] FCM token が Firestore `users/{uid}/privates/{id}.fcmTokens` に書き込まれること（Firebase Console で確認）

### タイミング問題が残った場合の追加対応（保険・実施は判断後）

capability 追加後も `apns-token-not-set` が断続的に出る場合は、`getToken()` の前に `getAPNSToken()` を短時間ループで待機させる。**今回は実施せず、動作確認で問題が出た場合のみ別タスクとして対応**。

参考実装（実施時）:

```dart
// lib/provider/fcm_token.dart
Future<void> registerToken() async {
  try {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      // APNs token が AppDelegate Swizzling 経由で FCM SDK に届くまで待機
      String? apns;
      for (int i = 0; i < 10; i++) {
        apns = await FirebaseMessaging.instance.getAPNSToken();
        if (apns != null) break;
        await Future.delayed(const Duration(milliseconds: 500));
      }
      if (apns == null) {
        debugPrint('[FCM] APNs token 未取得のため FCM token 取得をスキップ');
        return;
      }
    }
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await _saveToken(token);
    }
  } catch (e) {
    debugPrint('[FCM] トークン取得エラー: $e');
  }
}
```

## 参考

- 既存 ADR: `documents/adr/0004-fcm-push-notification-architecture.md`（iOS capability に関する記述は無いため、必要なら追記検討）
- エラー発生箇所: `lib/provider/fcm_token.dart:15-24`
- 呼び出しトリガ: `lib/features/resolver/app_entntiy_prepare.dart:46`（`appUser` 確定後の `useEffect`）
- permission request 箇所: `lib/main.dart:53`

---

## チェックリスト

### 実装内容
- [ ] 変更対象ファイルごとに具体的なコード提案をコードブロックで記載している
- [ ] 既存コードのパターン・構成を確認し、同じパターンで実装している

### Flutter（lib/ に変更がある場合）
- 該当なし（本プランで `lib/` は変更しない）

### Firebase（firebase/ に変更がある場合）
- 該当なし（本プランで `firebase/` は変更しない）

### iOS native（ios/ に変更がある場合）
- [ ] `ios/Runner/Runner.entitlements` に `aps-environment` キー追加
- [ ] `ios/Runner.xcodeproj/project.pbxproj` の SystemCapabilities に `com.apple.Push = { enabled = 1; }` 追加（Xcode GUI 経由で追加した場合は自動反映）
- [ ] `flutter build ios --debug --simulator --no-codesign` 成功
- [ ] Simulator (iPhone 16 Plus) で `flutter run` → `[FCM] トークン取得エラー` が出ない
- [ ] Firestore `users/{uid}/privates/{id}.fcmTokens` に FCM token が書き込まれている

### 共通
- [ ] エラーメッセージはそのまま表示（加工・プレフィックス除去なし）
