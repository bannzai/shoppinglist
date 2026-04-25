# 0009. Android ビルド環境の版一新と minSdk 26 への引き上げ

## Status
Accepted

## Context

Issue #232 で `flutter build apk` / `flutter build appbundle` が下記エラーで失敗していた。

```
Execution failed for task ':app:checkDebugAarMetadata'.
> Dependency ':flutter_local_notifications' requires core library desugaring to be enabled for :app.
```

`flutter_local_notifications` 21.0.0 が AAR メタデータで core library desugaring と Java 17 を要求しているが、プロジェクト側は未設定・Java 1.8 ターゲットのままだった。

加えて、desugaring を有効化してビルドを進めると次のエラーが出た。

```
kotlin-stdlib-2.3.10.jar ... The binary version of its metadata is 2.3.0, expected version is 2.1.0.
```

Gradle の依存解析で、`androidx.collection:collection-jvm:1.5.0`（AGP/Flutter 標準で引き込まれる）が `org.jetbrains.kotlin:kotlin-stdlib:2.3.10` を要求していたのに対し、プロジェクト側は Kotlin plugin 2.1.0 だったため版不整合で Kotlin コンパイラが内部エラーになっていた。これは Issue #232 のビルド失敗とは別の潜在的問題だが、desugaring 有効化でこちらが露出した。

さらに、Issue #232 の「決定していないこと」として minSdk 引き上げ案があった。本プロジェクトは位置情報リマインダーやホームウィジェットなど Android 8.0 以上の API を活用する機能が増えつつあり、Android 5.0-7.1 をサポートしつづけるモチベーションは低い。

## Decision

1. **`android/app/build.gradle` に core library desugaring を有効化**
   - `compileOptions.coreLibraryDesugaringEnabled = true`
   - `sourceCompatibility` / `targetCompatibility` / `kotlinOptions.jvmTarget` を `VERSION_17` に引き上げ
   - `dependencies` に `coreLibraryDesugaring "com.android.tools:desugar_jdk_libs:2.1.4"` を追加
   - `flutter_local_notifications` 21.0.0 の公式要件に合わせる

2. **`android/app/build.gradle` の `minSdk` を 26 に引き上げ**
   - これまでの `flutter.minSdkVersion`（Flutter デフォルト 21）を 26 に変更
   - サポート対象を Android 8.0 (Oreo) 以上に限定し、Android 5.0-7.1 は切り捨てる
   - `multiDexEnabled` は minSdk 21+ で既定有効のため追加不要

3. **`android/settings.gradle` でビルドプラグインをまとめて版一新**
   - `com.android.application` (AGP): 8.9.1 → 8.11.1
   - `org.jetbrains.kotlin.android`: 2.1.0 → 2.3.10
   - `com.google.gms.google-services` (4.4.2) は据え置き

4. **`android/gradle/wrapper/gradle-wrapper.properties` で Gradle wrapper を更新**
   - Gradle 8.11.1 → 8.13（AGP 8.11.1 の要求）

### 採用しなかった選択肢

- **Kotlin plugin 2.1.0 維持 + `androidx.collection` を 1.5.0 未満に pin**: resolutionStrategy で個別 pin する手はあるが、Firebase BOM 等から間接的に新しい androidx を引き込まれるたびに追従が必要になり、保守コストが高い。
- **Issue #232 と切り離して minSdk 現状維持 + desugaring のみ**: desugaring と AGP/Kotlin 更新までが最小の通る組合せで、minSdk 引き上げは任意。だが位置情報・ウィジェットの機能要件と近い将来の Android 9+ でのみ動く API 追加を見据え、ここで一緒に切り上げる判断とした。
- **AGP/Kotlin を更に新しい 8.13 系 / 2.4 系に**: 更新幅を必要最小に抑え、今回必要な下限（AGP 8.11.1 / Kotlin 2.3.10）にとどめた。

## Consequences

### Positive
- `flutter_local_notifications` 21.0.0 が正常にビルドされるようになり、Android でローカル通知と位置情報リマインダーが動作可能になる
- Kotlin plugin 2.3.10 により `androidx.collection` 1.5.0 など Kotlin 2.3 でビルドされた依存との版整合が取れ、Kotlin コンパイラ内部エラーが解消
- minSdk 26 により `java.time` など Oreo 以降の API をネイティブで扱いやすくなり、将来の新機能導入時に desugaring 対象を減らせる
- ビルドツールチェイン（AGP / Gradle / Kotlin）が比較的新しい組合せに揃い、以後の Flutter/依存パッケージ更新に追従しやすい

### Negative / Trade-off
- **Android 5.0-7.1 端末のサポート終了**。該当 OS のシェアは 2026 時点で国内だと数%以下と見込まれるが、ゼロではないため既存インストールユーザーの一部が更新を受け取れなくなる
- Java 17 / Kotlin 2.3 への引き上げにより、ビルドに必要な JDK が Java 17+ に事実上固定される（Flutter 3.24+ 同梱 JDK は 17 系なので通常は問題ない）
- `signingConfigs.debug` を release に流用している TODO 状態は本 ADR では解消していない（別 Issue 対応予定）

### Follow-up
- Android 12L+ で desugaring 有効時のクラッシュが観測されたら、`androidx.window:window` を追加する（`flutter_local_notifications` 公式 README 記載の推奨）
- Release 署名の正式化（現在 debug 鍵流用）は別 Issue で対応する
