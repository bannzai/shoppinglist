# Issue #232: Android core library desugaring 未設定ビルド失敗の修正

## Context

Flutter の Android ビルド（`flutter build apk` / `flutter build appbundle`）が `flutter_local_notifications` 21.0.0 の core library desugaring 要求で失敗している。

```
Execution failed for task ':app:checkDebugAarMetadata'.
> Dependency ':flutter_local_notifications' requires core library desugaring to be enabled for :app.
```

このエラーは AAR メタデータチェック由来で、minSdk を変えても回避できず、`coreLibraryDesugaringEnabled` の有効化と `desugar_jdk_libs` 依存追加が必須。iOS ビルドは通っているため本件は Android のみのビルド構成不備。Issue #229（RC Test Store API Key 切替）の検証中に発覚した pre-existing 問題として分離済み。

### 決定事項（ユーザー確認済み）
- **Java バージョン**: `VERSION_17` に引き上げ（flutter_local_notifications 21 公式要件）
- **AGP**: `8.9.1` → `8.11.1` に更新（公式要件を満たす）
- **Gradle wrapper**: `8.11.1` → `8.13` に更新（AGP 8.11.1 の要求）
- **Kotlin plugin**: `2.1.0` → `2.3.10` に更新（androidx.collection 1.5.0 が Kotlin 2.3.10 stdlib を持ち込むため版整合が必要）
- **minSdk**: Flutter デフォルト（21）→ `26` に引き上げ（Android 8.0+ のみサポート。desugaring 自体は必須のままだが将来 API 利用幅を広げる）
- **Release ビルド検証**: 本 PR で `flutter build appbundle --release` も試行（debug signing 流用のまま）
- **multiDexEnabled**: 追加不要（minSdk 21+ でデフォルト有効）

---

## 変更対象ファイル

### 1. `android/app/build.gradle`

**変更箇所**: `compileOptions`, `kotlinOptions`, `defaultConfig.minSdk`, `dependencies`

```groovy
plugins {
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
    id "com.google.gms.google-services"
}

android {
    namespace = "com.bannzai.shoppinglist"
    compileSdk = Math.max(flutter.compileSdkVersion, 36)
    ndkVersion = flutter.ndkVersion

    // flutter_local_notifications 21.0.0 は Java 17 + core library desugaring を要求
    compileOptions {
        coreLibraryDesugaringEnabled true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.bannzai.shoppinglist"
        // Android 8.0 以上のみサポート（Issue #232 決定事項）
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["GOOGLE_MAPS_API_KEY"] =
            project.findProperty("GOOGLE_MAPS_API_KEY") ?: ""
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.debug
        }
    }
}

dependencies {
    implementation platform("com.google.firebase:firebase-bom:34.9.0")
    implementation "com.google.firebase:firebase-common"
    implementation "com.google.firebase:firebase-auth"
    implementation "com.google.firebase:firebase-firestore"

    // flutter_local_notifications 21.0.0 要求: desugar_jdk_libs 2.1.4+
    coreLibraryDesugaring "com.android.tools:desugar_jdk_libs:2.1.4"
}

flutter {
    source = "../.."
}
```

### 2. `android/settings.gradle`

**変更箇所**: `com.android.application` と `org.jetbrains.kotlin.android` のバージョン

```groovy
// before
id "com.android.application" version "8.9.1" apply false
id "org.jetbrains.kotlin.android" version "2.1.0" apply false
// after
id "com.android.application" version "8.11.1" apply false
id "org.jetbrains.kotlin.android" version "2.3.10" apply false
```

`com.google.gms.google-services` (4.4.2) は据え置き。

### 3. `android/gradle/wrapper/gradle-wrapper.properties`

**変更必要**。AGP 8.11.1 は Gradle 8.13+ を要求する。

```
// before
distributionUrl=https\://services.gradle.org/distributions/gradle-8.11.1-all.zip
// after
distributionUrl=https\://services.gradle.org/distributions/gradle-8.13-all.zip
```

### 4. `android/gradle.properties`

**変更不要**。

### 5. `AndroidManifest.xml`

**変更不要**。`tools:replace` 等の競合はない。

---

## 実装手順

1. `origin/main` から新ブランチ作成: `fix/issue-232-core-library-desugaring`
2. 上記 `android/app/build.gradle` と `android/settings.gradle` を編集
3. `flutter clean`
4. 検証（下記「検証手順」）
5. コミット・PR 作成（本文に `Fixes #232` と Issue #229 への参照を記載）

---

## 検証手順

### Flutter 標準チェック
```bash
flutter clean
flutter pub get
flutter analyze
flutter test
```

### Android ビルド（メインゴール）
```bash
flutter build apk --debug
flutter build appbundle --release
```
※ release は debug signing 流用のため署名の正当性までは担保しない（Issue #229 の範囲外）。

### iOS ビルド（リグレッション確認）
```bash
flutter build ios --debug --no-codesign
```

### 実機/エミュレータ動作確認
- Android エミュレータ（API 34 推奨）で `flutter run`
- 設定画面 → 通知トグル ON/OFF が反映される
- 買い物リストアイテムに位置情報リマインダーを付与し、geofence 擬似トリガーでローカル通知を受信する（`lib/features/location_reminder/geofence_service.dart` / `lib/provider/local_notification.dart` 経路）

### Maestro E2E（該当フローのみ）
```bash
maestro test maestro/flows/add_and_check_item.yaml
maestro test maestro/flows/home_page_test.yaml
maestro test maestro/flows/location_reminder_non_premium.yaml
```
新規フローは不要（ビルド構成のみの変更）。

---

## チェックリスト

### 実装内容
- [ ] 変更対象ファイルごとに具体的なコード提案をコードブロックで記載している
- [ ] 既存コードのパターン・構成を確認し、同じパターンで実装している

### Flutter（lib/ に変更がある場合）
- [ ] コード生成: `dart run build_runner build` で生成ファイル更新（※本件は Android 側のみの変更で lib/ 変更なしのため不要、念のため実行は可）
- [ ] 静的解析: `flutter analyze` エラーなし
- [ ] テスト: `flutter test` 全件パス
- [ ] iOS ビルド: `flutter build ios` 成功
- [ ] Android ビルド: `flutter build apk` 成功
- [ ] 新規・変更機能に対するテストが存在する（なければ新規作成）※本件はビルド構成のみの変更
- [ ] Maestro E2E: 該当する maestro flow があれば実行、なければ新規作成
- [ ] Entity命名: フィールド名が省略されていない（※対象外）
- [ ] DB操作: Firestore操作は `call` クラスのProvider経由（※対象外）
- [ ] 引数: 関数・コンストラクタの引数に `{required}` あり（※対象外）
- [ ] ref使い分け: build内は `ref.watch`、コールバック・操作は `ref.read`（※対象外）
- [ ] サブコレクションEntityに親ドキュメントIDフィールドあり（※対象外）

### Android ビルド構成（本件固有）
- [ ] `android/app/build.gradle` で `coreLibraryDesugaringEnabled true` 設定
- [ ] `sourceCompatibility` / `targetCompatibility` / `jvmTarget` を `VERSION_17` に引き上げ
- [ ] `coreLibraryDesugaring "com.android.tools:desugar_jdk_libs:2.1.4"` 依存追加
- [ ] `minSdk = 26` 設定
- [ ] `android/settings.gradle` の AGP を `8.11.1` に更新
- [ ] `flutter build apk --debug` がエラーなし完走
- [ ] `flutter build appbundle --release` がエラーなし完走（debug signing 流用）
- [ ] Android エミュで起動確認、通知・位置情報リマインダーが動作

### 共通
- [ ] エラーメッセージはそのまま表示（加工・プレフィックス除去なし）（※対象外）
