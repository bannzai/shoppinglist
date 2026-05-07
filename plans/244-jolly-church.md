# Issue #244: 開発者トークン認証で dev only Cloud Functions をガード

## Context

`grantPromotionalPremium` / `revokePromotionalPremium` / `setupTestCategoryLocationOrder` の dev only Cloud Functions は、現状 `appEnv() !== "dev"` というプロジェクト全体の `APP_ENV` 環境変数で本番ユーザーから守られている。

Issue #242 ではこれを安全にするために Firebase dev/prod project 完全分離（iOS Bundle ID / Android applicationId / Flutter エントリポイント分離まで含む）を計画していたが、本来の目的（dev only Functions を本番ユーザーから守る）に対して工数が大きすぎた。

そこで方針を変更し、**user 単位の "開発者トークン" で識別する**方式に切り替える。dart-define で開発者ビルドにのみトークンを注入し、`users/{userID}.developerToken` に upsert、Cloud Functions 側は Firebase Secret Manager の `SHOPPINGLIST_DEVELOPER_TOKEN` と一致比較して認可する。これで dev project 不要、Bundle ID 分離不要、Flutter エントリポイント分離不要で目的を達成できる。

副次的に、`firebase/functions/.env.shopping-list-prod-a615c` の `APP_ENV=dev`（prod プロジェクトの env なのに dev 値）という Issue #242 が指摘していた潜在バグも、本 Issue 内で `core/env.ts` ごと削除する形で完全解消する。

## 環境変数命名

3 階層で名前を分ける（ローカルは衝突回避のため prefix、dart-define / secret はスコープ局所化のため短く）:

| レイヤー | 名前 |
|---|---|
| ローカル環境変数（direnv `.envrc`） | `SHOPPINGLIST_DEVELOPER_TOKEN` |
| Flutter dart-define key | `SHOPPINGLIST_DEVELOPER_TOKEN` |
| Firebase Secret Manager secret name | `SHOPPINGLIST_DEVELOPER_TOKEN` |

`.vscode/launch.json` で `--dart-define=SHOPPINGLIST_DEVELOPER_TOKEN=${env:SHOPPINGLIST_DEVELOPER_TOKEN}` で bridge する（既存 `REVENUECAT_TEST_STORE_API_KEY` と同パターン）。

`.envrc` には既に `SHOPPINGLIST_DEVELOPER_TOKEN=<REDACTED-ROTATE-IN-SECRET-MANAGER>`（uuid v4）が設定済み。Secret Manager にもこの値をそのまま登録する。

## 実装順序と Phase 構成

実装中に prod 環境が無防備な瞬間を作らないように Phase A の暫定 fail-safe を最初に配置する。最終 Phase で `env.ts` ごと削除する。

| Phase | 内容 | 依存 |
|---|---|---|
| A | `firebase/functions/.env.shopping-list-prod-a615c` の `APP_ENV=dev` → `APP_ENV=prod`（fail-safe） | なし |
| B | `firebase/functions/src/core/developer.ts` 新規 + tests | A |
| B' | ユーザー手動: `firebase functions:secrets:set SHOPPINGLIST_DEVELOPER_TOKEN` | B |
| C | 3 関数の `appEnv()` → `isDeveloper()` 置換 + tests 修正 | B' |
| D | Flutter 側: `Environment.developerToken` / `AppUser.developerToken` / `UserDeveloperTokenSync` / `launch.json` | A（並列可） |
| E | `firebase/functions/src/core/env.ts` 削除 + `authPolicy.ts` の `appEnv` 参照削除 + `.env.shopping-list-prod-a615c` から `APP_ENV` 行削除 | C |
| F | `firebase/firestore.rules` に `developerToken` の説明コメント追記 | なし |

## 変更対象ファイルと具体的なコード提案

### Phase A: `firebase/functions/.env.shopping-list-prod-a615c`

```diff
 GOOGLE_GENAI_API_KEY=<REDACTED>
-APP_ENV=dev
+APP_ENV=prod
 REVENUECAT_SECRET_API_KEY=<REDACTED>
```

Phase E で `APP_ENV` 行ごと削除するので、Phase A は中間状態の安全弁。

### Phase B: `firebase/functions/src/core/developer.ts`（新規）

```typescript
import admin from "firebase-admin";
import { defineSecret } from "firebase-functions/params";

/// 開発者識別用トークン。
/// `firebase functions:secrets:set SHOPPINGLIST_DEVELOPER_TOKEN` で値を設定する。
/// クライアント側 (Environment.developerToken) が users/{uid}.developerToken に
/// upsert した値と一致するかで Cloud Functions の dev only 関数を認可する。
export const developerToken = defineSecret("SHOPPINGLIST_DEVELOPER_TOKEN");

/** users コレクションのドキュメントスキーマ（開発者判定に必要なフィールドのみ）。 */
interface AppUserData {
  developerToken?: string;
}

/// 指定された userID が登録された開発者かを判定する。
/// users/{userID}.developerToken が Secret Manager の SHOPPINGLIST_DEVELOPER_TOKEN と
/// 一致する場合のみ true を返す。Secret 側が空文字／未設定の場合は常に false。
export async function isDeveloper(userID: string): Promise<boolean> {
  const expected = developerToken.value();
  if (!expected) {
    return false;
  }
  const userTokenValue = (
    await admin.firestore().collection("users").doc(userID).get()
  ).data() as AppUserData | undefined;
  return (
    typeof userTokenValue?.developerToken === "string" &&
    userTokenValue.developerToken === expected
  );
}
```

### Phase B: `firebase/functions/src/core/developer.test.ts`（新規）

```typescript
const mockGet = jest.fn();
const mockDoc = jest.fn(() => ({ get: mockGet }));
const mockCollection = jest.fn(() => ({ doc: mockDoc }));

jest.mock("firebase-admin", () => ({
  __esModule: true,
  default: {
    firestore: jest.fn(() => ({ collection: mockCollection })),
    initializeApp: jest.fn(),
  },
}));

const mockSecretValue = jest.fn();
jest.mock("firebase-functions/params", () => ({
  defineSecret: jest.fn(() => ({ value: () => mockSecretValue() })),
}));

import { isDeveloper } from "./developer";

beforeEach(() => {
  jest.clearAllMocks();
});

describe("isDeveloper", () => {
  test("Secret 未設定なら false", async () => {
    mockSecretValue.mockReturnValue("");
    mockGet.mockResolvedValue({ data: () => ({ developerToken: "token-1" }) });
    expect(await isDeveloper("user-1")).toBe(false);
  });

  test("Secret と user.developerToken が一致したら true", async () => {
    mockSecretValue.mockReturnValue("token-1");
    mockGet.mockResolvedValue({ data: () => ({ developerToken: "token-1" }) });
    expect(await isDeveloper("user-1")).toBe(true);
    expect(mockCollection).toHaveBeenCalledWith("users");
    expect(mockDoc).toHaveBeenCalledWith("user-1");
  });

  test("Secret と user.developerToken が異なれば false", async () => {
    mockSecretValue.mockReturnValue("token-1");
    mockGet.mockResolvedValue({ data: () => ({ developerToken: "token-2" }) });
    expect(await isDeveloper("user-1")).toBe(false);
  });

  test("user.developerToken 未設定なら false", async () => {
    mockSecretValue.mockReturnValue("token-1");
    mockGet.mockResolvedValue({ data: () => ({}) });
    expect(await isDeveloper("user-1")).toBe(false);
  });

  test("user ドキュメントが存在しなくても false", async () => {
    mockSecretValue.mockReturnValue("token-1");
    mockGet.mockResolvedValue({ data: () => undefined });
    expect(await isDeveloper("user-1")).toBe(false);
  });

  test("user.developerToken が string 以外なら false", async () => {
    mockSecretValue.mockReturnValue("token-1");
    mockGet.mockResolvedValue({ data: () => ({ developerToken: 123 }) });
    expect(await isDeveloper("user-1")).toBe(false);
  });
});
```

### Phase B': Secret 設定（ユーザー手動）

`.envrc` に既存の値をそのまま Secret Manager に登録。

```bash
cd /Users/bannzai/ghq/github.com/bannzai/shoppinglist/firebase
echo -n "$SHOPPINGLIST_DEVELOPER_TOKEN" | firebase functions:secrets:set SHOPPINGLIST_DEVELOPER_TOKEN --data-file=-
firebase functions:secrets:access SHOPPINGLIST_DEVELOPER_TOKEN  # → <REDACTED-ROTATE-IN-SECRET-MANAGER> 確認
```

Phase C のデプロイより先に必須。

### Phase C-1: `firebase/functions/src/functions/grantPromotionalPremium/function.ts`

```diff
@@ -1,10 +1,10 @@
 import { logger } from "firebase-functions";
 import { onCallGenkit } from "firebase-functions/https";
 import { defineString } from "firebase-functions/params";
 import * as z from "zod";
 import { ai } from "../utils/genkit";
 import { appAuthPolicy } from "../utils/authPolicy";
-import { appEnv } from "../../core/env";
+import { developerToken, isDeveloper } from "../../core/developer";
 import {
   DataResponseSchema,
   ErrorResponseSchema,
@@ -60,17 +60,8 @@
   async ({ duration }) => {
     try {
-      // 開発環境でのみ実行可能。本番環境での課金バイパスを防止する。
-      if (appEnv() !== "dev") {
-        return {
-          result: "NG" as const,
-          error: {
-            message: "この機能は開発環境でのみ使用できます",
-          },
-        };
-      }
-
       const context = ai.currentContext();
       const uid = context?.auth?.uid;
       if (!uid) {
         return {
           result: "NG" as const,
           error: { message: "認証されていません" },
         };
       }
+      // 登録された開発者本人のみ実行可能。本番ユーザーが叩いても NG を返す。
+      if (!(await isDeveloper(uid))) {
+        return {
+          result: "NG" as const,
+          error: { message: "この機能は開発者のみ使用できます" },
+        };
+      }
@@ -133,6 +124,7 @@
 module.exports = onCallGenkit(
   {
     authPolicy: appAuthPolicy("grantPromotionalPremium"),
+    secrets: [developerToken],
   },
   grantPromotionalPremiumFlow
 );
```

### Phase C-2: `firebase/functions/src/functions/revokePromotionalPremium/function.ts`

```diff
-import { appEnv } from "../../core/env";
+import { developerToken, isDeveloper } from "../../core/developer";
@@ -34,17 +34,8 @@
   async () => {
     try {
-      if (appEnv() !== "dev") {
-        return {
-          result: "NG" as const,
-          error: { message: "この機能は開発環境でのみ使用できます" },
-        };
-      }
-
       const context = ai.currentContext();
       const uid = context?.auth?.uid;
       if (!uid) {
         return {
           result: "NG" as const,
           error: { message: "認証されていません" },
         };
       }
+      if (!(await isDeveloper(uid))) {
+        return {
+          result: "NG" as const,
+          error: { message: "この機能は開発者のみ使用できます" },
+        };
+      }
@@ -105,6 +96,7 @@
 module.exports = onCallGenkit(
   {
     authPolicy: appAuthPolicy("revokePromotionalPremium"),
+    secrets: [developerToken],
   },
   revokePromotionalPremiumFlow
 );
```

### Phase C-3: `firebase/functions/src/functions/setupTestCategoryLocationOrder/function.ts`

```diff
-import { appEnv } from "../../core/env";
+import { developerToken, isDeveloper } from "../../core/developer";
@@ -42,15 +42,7 @@
   async ({ groupID, locationName, firstCategoryName, secondCategoryName }) => {
     try {
-      if (appEnv() !== "dev") {
-        return {
-          result: "NG" as const,
-          error: { message: "この機能は開発環境でのみ使用できます" },
-        };
-      }
-
       const context = ai.currentContext();
       const uid = context?.auth?.uid;
       if (!uid) {
         return {
           result: "NG" as const,
           error: { message: "認証されていません" },
         };
       }
+      if (!(await isDeveloper(uid))) {
+        return {
+          result: "NG" as const,
+          error: { message: "この機能は開発者のみ使用できます" },
+        };
+      }
@@ -161,6 +153,7 @@
 module.exports = onCallGenkit(
   {
     authPolicy: appAuthPolicy("setupTestCategoryLocationOrder"),
+    secrets: [developerToken],
   },
   setupTestCategoryLocationOrderFlow
 );
```

### Phase C-4: 3 つの `function.test.ts` 修正

各テストは `mockAppEnv` を `mockIsDeveloper` に置換する。

`grantPromotionalPremium/function.test.ts` の例:

```diff
-const mockAppEnv = jest.fn();
-jest.mock("../../core/env", () => ({
-  appEnv: () => mockAppEnv(),
-}));
+const mockIsDeveloper = jest.fn();
+jest.mock("../../core/developer", () => ({
+  developerToken: { value: () => "test-secret-key" },
+  isDeveloper: (...args: any[]) => mockIsDeveloper(...args),
+}));

 beforeEach(() => {
   jest.clearAllMocks();
-  mockAppEnv.mockReturnValue("dev");
+  mockIsDeveloper.mockResolvedValue(true);
   (global as any).fetch = mockFetch;
 });
```

各テストケース修正例:

```diff
-  test("正常系: dev 環境で認証済みユーザーに付与できる", async () => {
+  test("正常系: 開発者として認証されたユーザーに付与できる", async () => {
     mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });
     mockFetch.mockResolvedValue({ ok: true, status: 200, text: async () => "" });
     const result = await capturedFlowFn({ duration: "daily" });
     expect(result.result).toBe("OK");
+    expect(mockIsDeveloper).toHaveBeenCalledWith("user-1");
   });

-  test("異常系: prod 環境では実行できない", async () => {
-    mockAppEnv.mockReturnValue("prod");
+  test("異常系: 開発者ではないユーザーは実行できない", async () => {
+    mockIsDeveloper.mockResolvedValue(false);
     mockCurrentContext.mockReturnValue({ auth: { uid: "user-1" } });
     const result = await capturedFlowFn({ duration: "daily" });
     expect(result.result).toBe("NG");
-    expect(result.error.message).toContain("開発環境でのみ");
+    expect(result.error.message).toContain("開発者のみ");
     expect(mockFetch).not.toHaveBeenCalled();
   });
```

`revokePromotionalPremium/function.test.ts` / `setupTestCategoryLocationOrder/function.test.ts` も同様の置換。

### Phase D-1: `lib/utils/config/environment.dart`（既存ファイル拡張）

`Secret` クラス（`lib/secret/secret.dart`）ではなく `Environment` クラスに置く。`Secret` は「外部サービスの公開キー（RevenueCat / 広告 SDK 等）」が責務で、`developerToken` は「環境別の挙動切替フラグ」のため `Environment.siwaServiceIdentifier` 等と同カテゴリ。

```diff
   static const siwaServiceIdentifier =
       String.fromEnvironment('SIWA_SERVICE_IDENTIFIIER');
   static const androidSiwaRedirectURL =
       String.fromEnvironment('ANDROID_SIWA_REDIRECT_URL');
+
+  /// ローカル開発用の開発者識別トークン。
+  /// dart-define `SHOPPINGLIST_DEVELOPER_TOKEN` から注入される。値が設定されている場合のみ
+  /// users/{userID}.developerToken に upsert され、Cloud Functions
+  /// (grantPromotionalPremium 等の dev only 関数) でユーザー単位の認可に使われる。
+  /// 空文字の場合は本番ユーザービルド扱いで何もしない。
+  static const developerToken = String.fromEnvironment('SHOPPINGLIST_DEVELOPER_TOKEN');

   static Function()? deleteUser;
   static Function()? signOutUser;
```

### Phase D-2: `lib/entity/app_user.dart`（既存ファイル拡張）

`AppUser` に `developerToken` フィールドを追加。`themeColorHex` の直下、タイムスタンプ群の前に置く。

```diff
     // NOTE: テーマカラーのHEX値。プレミアムユーザーのみ変更可能。nullの場合はデフォルト(deepPurple=#673AB7)を使用する
     String? themeColorHex,
+    /// 開発者識別用トークン。dart-define `SHOPPINGLIST_DEVELOPER_TOKEN` を持つビルドが起動時に
+    /// upsert する。Cloud Functions (grantPromotionalPremium 等) で
+    /// Secret Manager の SHOPPINGLIST_DEVELOPER_TOKEN と一致比較し、ユーザー単位の認可に使う。
+    /// 本番ユーザービルドでは null のまま。
+    String? developerToken,
     @ClientCreatedTimestamp() DateTime? createdDateTime,
```

コード生成: `dart run build_runner build --delete-conflicting-outputs`

### Phase D-3: `lib/features/user/user_developer_token_sync.dart`（新規）

`.claude/rules/coding-conventions.md` の「DB 変更操作は call メソッドを持った class を提供する Provider を用意する」に従う。既存 `AppUserCreate` は Provider 化されていないが、これは規約制定前の負債で新規ファイルでは規約に従う。

```dart
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:shoppinglist/utils/config/environment.dart';

part 'user_developer_token_sync.g.dart';

/// dart-define で注入された [Environment.developerToken] を
/// users/{userID}.developerToken に同期する操作を提供する。
///
/// Cloud Functions の dev only 関数 (grantPromotionalPremium 等) は
/// Secret Manager の SHOPPINGLIST_DEVELOPER_TOKEN と users/{uid}.developerToken の一致比較で
/// 認可するため、開発者ビルドの起動時にこの同期を行う必要がある。
class UserDeveloperTokenSync {
  /// users/{userID} ドキュメントへの参照を提供する Database wrapper。
  final UserDatabase userDatabase;

  UserDeveloperTokenSync({required this.userDatabase});

  /// [Environment.developerToken] が空でなく、現在の users/{userID}.developerToken
  /// と異なる場合のみ Firestore を更新する。
  ///
  /// - dart-define が空文字（本番ユーザービルド）→ 何もしない
  /// - 既存値が一致 → 書き込みスキップ（無駄な write を避ける）
  /// - 不一致 / 未設定 → update する
  Future<void> call() async {
    if (Environment.developerToken.isEmpty) {
      return;
    }
    final appUserDocumentSnapshot = await userDatabase.userReference().get();
    if (appUserDocumentSnapshot.data()?.developerToken ==
        Environment.developerToken) {
      return;
    }
    await userDatabase.userReference().update({
      'developerToken': Environment.developerToken,
    });
  }
}

/// [UserDeveloperTokenSync] を提供する Provider。
@Riverpod(dependencies: [userDatabase])
UserDeveloperTokenSync userDeveloperTokenSync(Ref ref) {
  return UserDeveloperTokenSync(
    userDatabase: ref.watch(userDatabaseProvider),
  );
}
```

コード生成: `dart run build_runner build` で `user_developer_token_sync.g.dart` を生成。

### Phase D-4: `lib/features/resolver/app_user_create.dart`（既存ファイル拡張）

呼び出しタイミング判断: `AuthResolver` の useEffect は `userDatabaseProvider` のスコープ外（`UserDatabaseResolver` が override する前）のため使えない。`AppUserCreateResolver` の useEffect は既に `userDatabaseProvider` のスコープ内で「サインイン後に一度だけ」走るため、ここに併設する。

```diff
 import 'package:shoppinglist/features/resolver/database.dart';
+import 'package:shoppinglist/features/user/user_developer_token_sync.dart';
 import 'package:shoppinglist/provider/app_user.dart';

@@ -62,11 +63,16 @@
   @override
   Widget build(BuildContext context, WidgetRef ref) {
     final optionalAppUser = ref.watch(optionalAppUserProvider);
     final appUserCreate =
         AppUserCreate(userDatabase: ref.watch(userDatabaseProvider));
+    final userDeveloperTokenSync = ref.watch(userDeveloperTokenSyncProvider);

     // 初回ログイン時にFirestoreにAppUserドキュメントが存在しない場合、ここで作成する。
     // この処理はユーザーごとに一度だけ実行されればよいため、依存配列は空にする。
+    // AppUser ドキュメント作成後に dart-define の developerToken を upsert する。
+    // 既存ユーザーでもサインイン直後に差分があれば同期される。
     useEffect(() {
-      appUserCreate(firebaseUser: firebaseUser);
+      () async {
+        await appUserCreate(firebaseUser: firebaseUser);
+        await userDeveloperTokenSync();
+      }();
       return null;
     }, []);
```

順序の保証が重要: `AppUserCreate` は `set(merge: true)` で初回作成、`UserDeveloperTokenSync` は `update()` を使うため、AppUser ドキュメントが存在しない状態で先に走ると `update()` が失敗する。await で逐次処理する。

冪等性: `AppUserCreate` は `document.exists` 早期 return、`UserDeveloperTokenSync` は値比較で write スキップ。dart-define 未設定なら `UserDeveloperTokenSync` は早期 return で書き込みなし。

### Phase D-5: `.vscode/launch.json`（既存ファイル拡張）

```diff
       "args": [
         "--debug",
+        "--dart-define=SHOPPINGLIST_DEVELOPER_TOKEN=${env:SHOPPINGLIST_DEVELOPER_TOKEN}",
         "--dart-define=REVENUECAT_TEST_STORE_API_KEY=${env:REVENUECAT_TEST_STORE_API_KEY}"
       ]
```

`.envrc` に既に `SHOPPINGLIST_DEVELOPER_TOKEN=<REDACTED-ROTATE-IN-SECRET-MANAGER>` が設定済み。direnv 環境下から `code .` で VSCode を起動すれば `${env:SHOPPINGLIST_DEVELOPER_TOKEN}` が解決される。

### Phase D-6: Flutter テスト（任意・現実的範囲）

`Environment.developerToken` は `String.fromEnvironment` の `const` のためテスト上書き不可。`UserDeveloperTokenSync.call()` のロジック（dart-define 空判定 / 既存値一致判定 / update 呼び出し）の単体テストを書くには Firestore モック (`fake_cloud_firestore`) が必要だが、現状 `pubspec.yaml` に該当依存はなく、既存 Flutter テストは純関数中心。

→ 単体テストは追加しない。Maestro E2E `grant_premium_via_debug.yaml` の再実行で「dart-define 値が Functions まで届いて認可成功」を検証する。これでロジックの end-to-end カバーは十分。

### Phase E-1: `firebase/functions/src/functions/utils/authPolicy.ts`

`appEnv() === "dev"` の dev デバッグログを `process.env.FUNCTIONS_EMULATOR === "true"` に置換し、`appEnv` import を削除する。これにより `core/env.ts` への依存が完全に消える。

```diff
-import { appEnv } from "../../core/env";
-
 type AuthPolicy = (auth: any, data: any) => boolean | Promise<boolean>;

 export function appAuthPolicy(fn: string): AuthPolicy {
   if (process.env.ENV === "local") {
     return () => true;
   }
   if (process.env.FUNCTION_NAME !== fn) {
     return () => true;
   }
   return (auth) => {
     if (!auth) {
       throw new Error("Unauthenticated");
     }
     if (auth.token?.exp * 1000 < Date.now()) {
       throw new Error("User token is expired");
     }

-    if (appEnv() === "dev") {
+    if (process.env.FUNCTIONS_EMULATOR === "true") {
       console.log("[DEBUG] User ID: ", auth.uid);
     }
     return true;
   };
 }
```

### Phase E-2: `firebase/functions/src/core/env.ts` 削除

ファイル全体を削除（7行）。`grep -r "core/env" firebase/functions/src/` で参照が 0 件であることを確認してから削除。

### Phase E-3: `firebase/functions/.env.shopping-list-prod-a615c` から `APP_ENV` 行削除

```diff
 GOOGLE_GENAI_API_KEY=<REDACTED>
-APP_ENV=prod
 REVENUECAT_SECRET_API_KEY=<REDACTED>
```

`firebase/functions/.envrc` の `export APP_ENV=dev` も同様に削除（Phase E-2 で `appEnv()` 関数自体が消えるため、参照されない値を残しても無意味）。

### Phase F: `firebase/firestore.rules`

既存ルール（19-33行目）で `users/{userID}` は本人 (or デバッグユーザー) のみ read/write 可能なため、`developerToken` フィールドの保護は既に成立済み。コメント追記のみ行う。

```diff
     match /users/{userID} {
+      // developerToken フィールドは Cloud Functions の dev only 関数 (grantPromotionalPremium 等)
+      // のユーザー単位ガードに使われる。dart-define SHOPPINGLIST_DEVELOPER_TOKEN を持つ開発者ビルドでのみ
+      // クライアント (UserDeveloperTokenSync) が upsert する。本人以外のアクセスは下記の
+      // isUserAuth(userID) || isDebugUserOf(userID) で既に拒否されている。
       allow read: if isUserAuth(userID) || isDebugUserOf(userID);
       allow create, update: if isUserAuth(userID) || isDebugUserOf(userID);
       allow delete: if isDebugUserOf(userID);
```

## 検証方法

### Functions
```bash
cd firebase/functions
npm run lint
npm run build
npm test                                        # developer.test.ts 含めて全件パス
firebase functions:secrets:access SHOPPINGLIST_DEVELOPER_TOKEN  # → <REDACTED> 確認
```

### Flutter
```bash
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter build ios
flutter build apk
```

### E2E（既存 Maestro flow を再実行）
```bash
# direnv 効くシェルから VSCode を起動 → shoppinglist(dev) で iOS Simulator 起動
# (内部で --dart-define=SHOPPINGLIST_DEVELOPER_TOKEN が渡る)
maestro test maestro/flows/shared/grant_premium_via_debug.yaml
```

期待: Functions 切替後も従来同様「プレミアム付与 完了」表示まで到達する（flow ファイル自体に変更不要）。

### 手動動作確認

- 開発者ビルド（dart-define あり）でサインイン → Firestore Console で `users/{uid}.developerToken` に `<REDACTED>` が書き込まれている
- 既存ユーザー（`developerToken` 未保存）で開発者ビルド起動 → 自動 upsert で書き込まれる
- 本番ユーザービルド（`flutter run --release` で dart-define なし）で起動 → `users/{uid}.developerToken` に書き込みなし
- 開発者ビルドで `grantPromotionalPremium` / `revokePromotionalPremium` / `setupTestCategoryLocationOrder` 全成功
- 別ユーザー（他人）の `users/{otherUID}.developerToken` を Firestore Console / Rules tester で読み取り → DENIED
- Secret Manager の `SHOPPINGLIST_DEVELOPER_TOKEN` を別値に更新 → 開発者ビルド再起動 → 自動 upsert で再同期 → Functions 認可成功

## やらないこと（明示）

- Firebase dev project 作成（Issue #242 から方針変更）
- iOS Bundle ID `.dev` suffix 分離
- Android applicationId 分離
- Flutter エントリポイント分離（`main_dev.dart` 等）
- `.envrc` の `SHOPPINGLIST_DEVELOPER_TOKEN` の uuid 再生成（既存値を流用）
- `AppUserCreate` を Provider 化する大規模リファクタ（既存負債は本 Issue スコープ外）
- Maestro flow の新規追加（既存 `grant_premium_via_debug.yaml` の再実行で end-to-end カバー可能）

## 関連 Issue

- Issue #242（dev/prod project 分離計画 → 本 Issue で方針変更、Close 済み）
- Issue #241 Task 3（元の動機）
- Issue #239（Promotional Entitlement 移行で発生した検証運用問題）

---

## チェックリスト

### 実装内容
- [x] 変更対象ファイルごとに具体的なコード提案をコードブロックで記載している
- [x] 既存コードのパターン・構成を確認し、同じパターンで実装している（`generateShoppingListItemsFromURL` の `defineSecret` パターン、既存 `function.test.ts` の jest mock パターン、`Environment.siwaServiceIdentifier` の `String.fromEnvironment` パターン、`launch.json` の `${env:...}` パターン）

### Flutter（lib/ に変更がある場合）
- [ ] コード生成: `dart run build_runner build --delete-conflicting-outputs` で `app_user.freezed.dart` / `app_user.g.dart` / `user_developer_token_sync.g.dart` 更新
- [ ] 静的解析: `flutter analyze` エラーなし
- [ ] テスト: `flutter test` 全件パス
- [ ] iOS ビルド: `flutter build ios` 成功
- [ ] Android ビルド: `flutter build apk` 成功
- [ ] 新規・変更機能に対するテストが存在する（純関数テストは追加しない方針 / E2E でカバー）
- [ ] Maestro E2E: `maestro/flows/shared/grant_premium_via_debug.yaml` を `shoppinglist(dev)` ビルドで実行しパス
- [ ] Entity命名: `developerToken` フィールドが省略されていない
- [ ] DB操作: `UserDeveloperTokenSync` は call クラス + Provider（`userDeveloperTokenSyncProvider`）経由で Firestore 操作
- [ ] 引数: `UserDeveloperTokenSync({required this.userDatabase})` に `required` あり
- [ ] ref使い分け: `AppUserCreateResolver` build 内で `ref.watch(userDeveloperTokenSyncProvider)`、コールバックでは watch から取得した instance を await（既存 `appUserCreate` と同パターン）
- [ ] サブコレクションEntityに親ドキュメントIDフィールドあり（`AppUser` はサブコレクションではないため該当なし）

### Firebase（firebase/ に変更がある場合）
- [ ] Lint: `cd firebase/functions && npm run lint` パス
- [ ] ビルド: `cd firebase/functions && npm run build` 成功
- [ ] テスト: `cd firebase/functions && npm test` 全件パス（`developer.test.ts` 6 ケース + 既存 3 関数の test 修正後）
- [ ] クライアント呼び出し関数はGenKitで定義（既存維持、`onCallGenkit({ secrets: [developerToken] }, flow)` で secret 配列に登録）
- [ ] onDocumentCreated/onDocumentUpdated トリガーを使っていない
- [ ] 新規・変更機能に対するテストが存在する（`isDeveloper` ヘルパー）
- [ ] `firebase functions:secrets:set SHOPPINGLIST_DEVELOPER_TOKEN` で値設定済み（Phase B' のユーザー手動作業）
- [ ] Firestore Security Rules で `users/{userID}.developerToken` 保護確認（既存ルールでカバー、コメント追記のみ）
- [ ] `firebase/functions/src/core/env.ts` 削除済み、`grep -r "core/env" firebase/functions/src/` が 0 件
- [ ] `firebase/functions/.env.shopping-list-prod-a615c` から `APP_ENV` 行削除済み
- [ ] `firebase/functions/.envrc` から `export APP_ENV=dev` 行削除済み

### 共通
- [ ] エラーメッセージはそのまま表示（加工・プレフィックス除去なし、`"この機能は開発者のみ使用できます"` をそのまま返す）
- [ ] 開発者本人のアカウントで `grantPromotionalPremium` / `revokePromotionalPremium` / `setupTestCategoryLocationOrder` が動作する
- [ ] 開発者トークン無しのアカウントで上記 3 関数が NG `"この機能は開発者のみ使用できます"` を返す
- [ ] Phase A の `.env.shopping-list-prod-a615c` の `APP_ENV=dev` → `prod` 修正がプロセス中の安全弁として最初のコミットに含まれている
- [ ] Phase E で `core/env.ts` ごと削除し、`appEnv` 参照が 0 件になっている

---

# 追加対応 Phase G: 全 secret を defineSecret (gcloud Secret Manager) に統一

## Context

PR #245 のレビュー対応で `addf02c` (`chore: plans を更新`) から 3 つの secret 値が漏洩していた:
- `SHOPPINGLIST_DEVELOPER_TOKEN` (uuid)
- `GOOGLE_GENAI_API_KEY` (Gemini)
- `REVENUECAT_SECRET_API_KEY` (RevenueCat)

`a990ad2` で plan ファイルからは redact 済みだが git history には残るため、ユーザーが 3 つの値を rotate した上で **すべて GCP Secret Manager (= Firebase の `defineSecret`) で一元管理** に切り替え。これにより:
- `.env.<projectId>` ファイルから secret 値を全廃して PR の git history に永久露出するリスクを除去
- Firebase Functions v2 の公式推奨パスに統一 (`defineSecret` + `onCall*({ secrets: [...] }, ...)`)
- 既存の `defineString("...")` で `.env.<projectId>` 由来だった旧方式を廃止

`SHOPPINGLIST_DEVELOPER_TOKEN` は既に Phase B-C で `defineSecret` 化済み。残りの secret と関連デッドコードを整理する。

## 変更対象ファイルとコード提案

### G-1. `firebase/functions/src/index.ts`

`defineString("GOOGLE_GENAI_API_KEY")` の登録呼び出し（副作用のみ、Issue #1567 workaround 由来）と `defineString` import を削除。各関数側で `defineSecret` するため index.ts での登録は不要。

```diff
 import admin = require("firebase-admin");
-import { defineString } from "firebase-functions/params";

 console.log("THIS IS NOT TEST ENVIRONMENT");
 if (process.env.ENV === "local") {
   console.log("THIS IS LOCAL ENVIRONMENT");
   admin.initializeApp({
     storageBucket: "gs://shopping-list-prod-a615c.firebasestorage.app",
   });
 } else {
   admin.initializeApp({
     storageBucket: "gs://shopping-list-prod-a615c.firebasestorage.app",
   });
 }

-// https://github.com/firebase/firebase-functions/issues/1567#issue-2303336877
-// 本当はdefineSecretを使いたい
-// defineSecret("GOOGLE_GENAI_API_KEY");
-defineString("GOOGLE_GENAI_API_KEY");
-
 admin.firestore().settings({ ignoreUndefinedProperties: true });
```

### G-2. `firebase/functions/src/functions/utils/openai.ts`

ファイルごと削除（`git rm`）。`grep` で `openai()` の呼び出し元なし、`utils/openai.ts:6` の `defineString("OPENAI_API_KEY")` も副作用登録のみのデッドコード。SSOT 原則に従いスキップさせる。

```bash
git rm firebase/functions/src/functions/utils/openai.ts
```

### G-3. `firebase/functions/src/functions/grantPromotionalPremium/function.ts`

`REVENUECAT_SECRET_API_KEY` を `defineSecret` 化、`secrets:` 配列に追加。

```diff
-import { defineString } from "firebase-functions/params";
+import { defineSecret } from "firebase-functions/params";
 ...
-/// RevenueCat Secret API Key。Promotions APIの呼び出しに使用する。
-const REVENUECAT_SECRET_API_KEY = defineString("REVENUECAT_SECRET_API_KEY");
+/// RevenueCat Secret API Key。Promotions APIの呼び出しに使用する。Secret Manager 経由で取得。
+const revenueCatSecretApiKey = defineSecret("REVENUECAT_SECRET_API_KEY");
 ...
       const revenueCatResponse = await fetch(
         `https://api.revenuecat.com/v1/subscribers/${uid}/entitlements/${PREMIUM_ENTITLEMENT_IDENTIFIER}/promotional`,
         {
           method: "POST",
           headers: {
-            Authorization: `Bearer ${REVENUECAT_SECRET_API_KEY.value()}`,
+            Authorization: `Bearer ${revenueCatSecretApiKey.value()}`,
             "Content-Type": "application/json",
           },
 ...
 module.exports = onCallGenkit(
   {
     authPolicy: appAuthPolicy("grantPromotionalPremium"),
-    secrets: [developerToken],
+    secrets: [developerToken, revenueCatSecretApiKey],
   },
   grantPromotionalPremiumFlow
 );
```

### G-4. `firebase/functions/src/functions/revokePromotionalPremium/function.ts`

G-3 と同じパターン（同名 secret を使うため定義名のみ揃え、識別子は同じ `revenueCatSecretApiKey`）。

### G-5. `firebase/functions/src/functions/generateShoppingListItemsFromImage/function.ts`

モジュールトップレベルでの `defineString().value()` 呼び出しは `defineSecret` では動かない（`secrets:` バインドが効くのは関数実行時のみ）ため、API クライアント初期化をハンドラ内に移動。

```diff
-import { defineString } from "firebase-functions/params";
+import { defineSecret } from "firebase-functions/params";
 ...
+const googleAIApiKey = defineSecret("GOOGLE_GENAI_API_KEY");
+
 const generateShoppingListItemsFromImageFlow = ai.defineFlow(
   { ... },
   async ({ ... }) => {
+    const apiKey = googleAIApiKey.value();
+    const genAI = new GoogleGenerativeAI(apiKey);
+    const fileManager = new GoogleAIFileManager(apiKey);
+    const model = genAI.getGenerativeModel({ model: "gemini-2.0-flash" });
+    // ...既存処理（genAI / fileManager / model はハンドラ内のローカル変数として参照）
   }
 );

 module.exports = onCallGenkit(
   {
     authPolicy: appAuthPolicy("generateShoppingListItemsFromImage"),
+    secrets: [googleAIApiKey],
   },
   generateShoppingListItemsFromImageFlow
 );

-const apiKey = defineString("GOOGLE_GENAI_API_KEY").value();
-const genAI = new GoogleGenerativeAI(apiKey);
-const fileManager = new GoogleAIFileManager(apiKey);
-const model = genAI.getGenerativeModel({ ... });
```

実装時に注意: モジュールトップレベルで定義されていた `genAI` / `fileManager` / `model` / `generationConfig` などをハンドラ内のローカル変数に再配置し、参照箇所もすべてハンドラ内に閉じ込める。1 関数 1 リクエストの cold start 影響は許容（Gemini 公式 SDK は軽量）。

### G-6. テストファイル修正

3 つの test ファイルで `jest.mock("firebase-functions/params", ...)` を `defineString` mock から `defineSecret` mock に切り替え。既存の `developer.test.ts` のパターンを踏襲。

対象:
- `grantPromotionalPremium/function.test.ts`
- `revokePromotionalPremium/function.test.ts`
- `generateShoppingListItemsFromImage/function.test.ts`

例（`grantPromotionalPremium/function.test.ts`）:

```diff
 jest.mock("firebase-functions/params", () => ({
-  defineString: jest.fn(() => ({ value: () => "test-secret-key" })),
+  defineSecret: jest.fn(() => ({ value: () => "test-secret-key" })),
 }));
```

`developer.ts` を import する関数 (`grantPromotionalPremium`, `revokePromotionalPremium`, `setupTestCategoryLocationOrder`) は既に `defineSecret` mock 経由で `developerToken: { value: () => "test-secret-key" }` をパッチしているので、`secret-key` 値は使い回し OK。

無関係な test ファイル (`createGroup`, `acceptGroupInvitation`, `removeGroupMember`, `createGroupInvitation`, `createShoppingList`, `updateGroupName`, `setupTestCategoryLocationOrder`) は `defineString` mock がデフォルト残留しても import チェーンで Resolve されないため触らない (= 動作影響なし)。

## ユーザー手動

### `firebase/functions/.env.shopping-list-prod-a615c`

3 つの値を全削除。`APP_ENV=prod` のみ残す（GenKit Web UI 認証 / `appEnv() === "dev"` デバッグログ用）。

```diff
-GOOGLE_GENAI_API_KEY=<旧値>
 APP_ENV=prod
-REVENUECAT_SECRET_API_KEY=<旧値>
```

### `firebase/functions/.envrc`

`OPEN_AI_KEY` / `OPENAI_API_KEY` の export 行を削除（openai.ts 削除に伴いデッドコード化）。`GOOGLE_GENAI_API_KEY` / `REVENUECAT_SECRET_API_KEY` の export も genkit dev / emulator では gcloud secret manager 経由になるため削除可能。`GENKIT_ENV=dev` / `APP_ENV=dev` / `GOOGLE_APPLICATION_CREDENTIALS` / `SHOPPINGLIST_DEVELOPER_TOKEN` (uuid、Flutter dart-define 用) は維持。

### gcloud 登録確認

```bash
gcloud secrets list --project=shopping-list-prod-a615c
# 期待される secret 一覧:
# - SHOPPINGLIST_DEVELOPER_TOKEN
# - GOOGLE_GENAI_API_KEY
# - REVENUECAT_SECRET_API_KEY
```

## 検証

```bash
cd firebase/functions
npm run lint            # eslint クリア
npm run build           # tsc クリア
npm test                # 全 suite pass
```

## main vs HEAD で deploy が必要なもの

`git diff --name-only origin/main...HEAD -- firebase/`:

```
firebase/firestore.rules                                              → firestore:rules
firebase/functions/src/core/developer.ts                              → functions
firebase/functions/src/core/developer.test.ts                         → (test only)
firebase/functions/src/core/env.ts                                    → functions
firebase/functions/src/functions/grantPromotionalPremium/function.ts  → functions:grantPromotionalPremium
firebase/functions/src/functions/grantPromotionalPremium/function.test.ts → (test only)
firebase/functions/src/functions/revokePromotionalPremium/function.ts → functions:revokePromotionalPremium
firebase/functions/src/functions/revokePromotionalPremium/function.test.ts → (test only)
firebase/functions/src/functions/setupTestCategoryLocationOrder/function.ts → functions:setupTestCategoryLocationOrder
firebase/functions/src/functions/setupTestCategoryLocationOrder/function.test.ts → (test only)
firebase/functions/src/functions/utils/authPolicy.ts                  → functions (全関数の共通 import)
firebase/functions/src/index.ts                                       → functions
+ Phase G で追加変更:
firebase/functions/src/functions/utils/openai.ts                      → 削除（依存なし、deploy 不要）
firebase/functions/src/functions/generateShoppingListItemsFromImage/function.ts → functions:generateShoppingListItemsFromImage
```

### Deploy コマンド

`authPolicy.ts` は全関数の共通 import なので、念のため全関数を再 deploy する形が安全:

```bash
cd /Users/bannzai/ghq/github.com/bannzai/shoppinglist/firebase
firebase deploy --only functions,firestore:rules
```

個別を指定するなら（`authPolicy.ts` の変更が小さいため許容できれば）:

```bash
cd /Users/bannzai/ghq/github.com/bannzai/shoppinglist/firebase
firebase deploy --only firestore:rules
firebase deploy --only \
  functions:grantPromotionalPremium,\
functions:revokePromotionalPremium,\
functions:setupTestCategoryLocationOrder,\
functions:generateShoppingListItemsFromImage
```

`generateShoppingListItemsFromURL` は変更なし、deploy 不要。

### Phase G チェックリスト

- [ ] `firebase/functions/src/index.ts` から `defineString` import と `defineString("GOOGLE_GENAI_API_KEY")` 行を削除
- [ ] `firebase/functions/src/functions/utils/openai.ts` を `git rm`
- [ ] `grantPromotionalPremium/function.ts`: `defineString("REVENUECAT_SECRET_API_KEY")` → `defineSecret(...)` + `secrets: [developerToken, revenueCatSecretApiKey]`
- [ ] `revokePromotionalPremium/function.ts`: 同上
- [ ] `generateShoppingListItemsFromImage/function.ts`: `defineString("GOOGLE_GENAI_API_KEY")` → `defineSecret(...)` + `secrets: [googleAIApiKey]` + 初期化ハンドラ内移動
- [ ] 3 つの test ファイルで `defineString` mock を `defineSecret` mock に変更
- [ ] `cd firebase/functions && npm run lint && npm run build && npm test` 全件 pass
- [ ] ユーザー手動: `.env.shopping-list-prod-a615c` から secret 値削除（`APP_ENV=prod` のみ残す）
- [ ] ユーザー手動: `.envrc` から `OPEN_AI_KEY` / `GOOGLE_GENAI_API_KEY` / `REVENUECAT_SECRET_API_KEY` 削除
- [ ] ユーザー手動: `gcloud secrets list` で 3 つの secret 登録確認
- [ ] ユーザー手動: `firebase deploy --only functions,firestore:rules`
