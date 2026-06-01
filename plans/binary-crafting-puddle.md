# documents/ のルールを .claude/rules/ に移行

## Context

`documents/` 配下のルール系 Markdown 9ファイルを Claude Code の rules 機能（`.claude/rules/`）に移行する。

### 背景
- 現状、コーディング規約は `documents/`（ファイル参照頼み）と `.claude/rules/`（Claude Code rules 機能 = ファイルオープン時自動ロード）の **二重管理** になっている
- `.claude/rules/firestore-composite-id.md` は要約版で、詳細版は `documents/firestore-document-id-rules.md` に存在するなど、SSOT 違反
- `.claude/rules/` の Claude Code rules 機能（frontmatter `paths:` glob + 自動ロード）の方が、ファイル編集時に自動的に該当ルールが効くため、ルールの実効性が高い
- ユーザーは「Claude の rules 機能を使いたい」と希望しており、`documents/` から `.claude/rules/` への一元化が目的

### 検証済みの事項
- 9ファイルのうち **firebase-functions-call-rules.md 以外の8ファイル** は現状コードと整合（運用されていた）
- **firebase-functions-call-rules.md** は現状コード（`CreateGroup`/`CreateGroupInvitation` 等が Provider+Class でラップ）と矛盾。ユーザー判断: **documents 側が正しい**ので移行する。コード修正は別 issue 化
- **flutter-hooks-rules.md** は約60-70%しか準拠していない（resolver系で useEffect コメント未記載）。ユーザー判断: **そのまま移行**、コード修正は別タスク
- `documents/PROJECT.md` と `documents/adr/` は **ルールではない**ので移行対象外（documents/ に残す）

### Outcome
- ルール系ドキュメントは `.claude/rules/` に集約され、ファイル編集時に自動でロードされる
- `documents/` には `PROJECT.md` と `adr/` のみが残る
- 既存の `documents/` への参照（CLAUDE.md、.claude/skills/ 配下、`.claude/rules/` 内）は全て更新される
- 既存の重複（要約版 `firestore-composite-id.md`）は削除される
- firebase-functions-call-rules 違反コードの修正は GitHub issue として記録される

---

## ファイル移動マッピング

| documents/ | → .claude/rules/ | frontmatter `paths:` | 既存 .claude/rules/ への影響 |
|---|---|---|---|
| firestore-document-id-rules.md | firestore-document-id-rules.md | `lib/**/*.dart`, `firebase/functions/**/*.ts` | **firestore-composite-id.md を削除** |
| firestore-fieldvalue-rules.md | firestore-fieldvalue-rules.md | `lib/**/*.dart` | なし |
| firestore-timestamp-rules.md | firestore-timestamp-rules.md | `lib/**/*.dart`, `firebase/functions/**/*.ts` | なし |
| flutter-hooks-rules.md | flutter-hooks-rules.md | `lib/**/*.dart` | なし（hooks-and-consumer-widget.md は別トピック） |
| riverpod-rules.md | riverpod-rules.md | `lib/**/*.dart` | なし（hooks-and-consumer-widget.md は補完関係） |
| entity-parent-id-rules.md | entity-parent-id-rules.md | `lib/entity/**/*.dart` | coding-conventions.md の参照を更新 |
| typescript-rules.md | typescript-rules.md | `firebase/functions/**/*.ts` | なし |
| firebase-functions-call-rules.md | firebase-functions-call-rules.md | `lib/**/*.dart` | なし（firebase-functions.md は Functions 側のルール） |
| feature-readme-guideline.md | feature-readme-guideline.md | `lib/features/**/*.dart` | なし |

---

## 実装ステップ

### Step 1: 新ルールファイル9つを `.claude/rules/` に作成

各ファイルは documents/ の内容に frontmatter を付与する形で新規作成。documents/ の元ファイルは Step 4 で削除する。

#### 1-1. `.claude/rules/firestore-document-id-rules.md`

```markdown
---
paths:
  - "lib/**/*.dart"
  - "firebase/functions/**/*.ts"
---

# Firestore Document ID ルール

## 基本方針
基本的にはFirestoreの自動生成IDを使用する。

通常のサブコレクション（例: `/groups/{groupID}/shoppingLocations/{id}`、`/groups/{groupID}/shoppingLists/{id}`）ではFirestoreの自動生成IDで十分。

## Composite ID
Composite IDは、特定のリレーションを明示する必要がある場合にのみ使用する。

### 使用するケース
- Userと紐づく1:1の情報を、mapではなくcollection/documentとして格納したい場合
- 例: GroupUserProfileはUser:Group間で1:1の関係 → `GroupUserProfile_groups_{groupID}_users_{userID}`

### 使用しないケース
- 1:N の通常のサブコレクション（場所、買い物リスト、アイテム等）
- 親のパス自体で親子関係が明確な場合

### フォーマット
\`\`\`
{EntityName}_{parentCollectionName}_{parentDocID}[_{additionalCollectionName}_{additionalDocID}]
\`\`\`

- `{EntityName}`: PascalCaseのエンティティ名（先頭に来ることでIDの種類が一目で分かる）
- `{parentCollectionName}_{parentDocID}`: 親コレクション名とドキュメントIDのペア
- 複数キーが必要な場合は `_{collectionName}_{docID}` を連結

### 例
- `UserPrivate_users_{userID}` — `/users/{userID}/privates/` 内のシングルトン
- `GroupUserProfile_groups_{groupID}_users_{userID}` — `/groups/{groupID}/userProfiles/` 内のUser別ドキュメント

### 理由
- エンティティ名が先頭にあるため、IDだけで何のエンティティか判別できる
- collectionGroup queryでIDの衝突を防げる
- デバッグ時にIDから所属リソースを即座に判別できる

### 実装
Composite IDを使用する場合、エンティティクラスにstaticメソッドとしてID生成ロジックを集約する。

\`\`\`dart
class GroupUserProfile {
  static String documentID({required String groupID, required String userID}) =>
      'GroupUserProfile_groups_${groupID}_users_$userID';
}
\`\`\`

Firebase Functions側でも同じフォーマットを使用すること（`firebase/functions/src/entity/` 配下のヘルパー関数）。
```

> **Note**: 末尾の Firebase Functions の言及は元の document からの追記。既存の `.claude/rules/firestore-composite-id.md` に含まれていた「Firebase Functions側: `entity/` ディレクトリのヘルパー関数で定義」を吸収する。

#### 1-2. `.claude/rules/firestore-fieldvalue-rules.md`

```markdown
---
paths:
  - "lib/**/*.dart"
---

# Firestore FieldValue ルール

## FieldValue.delete() を使用しない

DartクライアントからFirestoreのフィールドを削除する場合、`FieldValue.delete()` は使用しない。

### 理由

- Dartには `undefined` と `null` の区別がない（JavaScriptとは異なる）
- DBのEntityは `undefined` / `null` を区別しないように設計すべき
- `FieldValue.delete()` を使うと `update` + マップリテラルによる更新が必要になり、`set` + `copyWith` と混在してコードが複雑になる

### 方針

- nullableフィールドの値を消したい場合は `null` をセットする
- Firestoreの更新は `set` + `copyWith` + `SetOptions(merge: true)` に統一する
- freezed 3.1.0 の `copyWith` は sentinel value パターンを採用しているため、`copyWith(field: null)` で明示的に `null` がセットされる

### 例

\`\`\`dart
// OK: null をセットして値を消す
docRef.set(
  entity.copyWith(
    color: null,
    description: null,
  ),
  SetOptions(merge: true),
);

// NG: FieldValue.delete() を使わない
docRef.update({
  'color': FieldValue.delete(),
  'description': FieldValue.delete(),
});
\`\`\`
```

#### 1-3. `.claude/rules/firestore-timestamp-rules.md`

```markdown
---
paths:
  - "lib/**/*.dart"
  - "firebase/functions/**/*.ts"
---

# Firestore タイムスタンプ更新ルール

## サーバータイムスタンプ
Firestoreのドキュメントを更新する際は、サーバー側のタイムスタンプフィールドを必ず付与する。

### フィールド一覧
| フィールド | 用途 | 付与タイミング |
|---|---|---|
| `serverCreatedDateTime` | サーバー側の作成日時 | ドキュメント新規作成時 |
| `serverUpdatedDateTime` | サーバー側の更新日時 | ドキュメント作成時・更新時の両方 |

### 理由
- クライアント側の `createdDateTime` / `updatedDateTime` はユーザー端末の時刻に依存する
- サーバータイムスタンプにより、正確な時系列の把握が可能になる

### 実装例

**Firebase Functions（TypeScript）:**
\`\`\`typescript
// 更新時
transaction.update(ref, {
  updatedDateTime: admin.firestore.FieldValue.serverTimestamp(),
  serverUpdatedDateTime: admin.firestore.FieldValue.serverTimestamp(),
});

// 新規作成時
transaction.set(ref, {
  createdDateTime: admin.firestore.FieldValue.serverTimestamp(),
  updatedDateTime: admin.firestore.FieldValue.serverTimestamp(),
  serverCreatedDateTime: admin.firestore.FieldValue.serverTimestamp(),
  serverUpdatedDateTime: admin.firestore.FieldValue.serverTimestamp(),
});
\`\`\`

**Flutter（Dart）:**
\`\`\`dart
// 更新時
await docRef.update({
  'updatedDateTime': FieldValue.serverTimestamp(),
  'serverUpdatedDateTime': FieldValue.serverTimestamp(),
});
\`\`\`
```

#### 1-4. `.claude/rules/flutter-hooks-rules.md`

```markdown
---
paths:
  - "lib/**/*.dart"
---

# Flutter Hooks 規約

## useEffect のコメント
`useEffect` を使用する際は、その直前に以下を明記するコメントを追加する:
1. **目的**: 何をするためのEffectか
2. **依存配列の意図**: なぜその依存配列にしたのか（特に、含めなかったものがある場合はその理由）

### 例
\`\`\`dart
// Firestoreからプロフィールデータが初回読み込みされた時にTextFieldへ反映する。
// displayNameController.textが空の場合のみ設定することで、ユーザーが入力中の値を上書きしない。
useEffect(() {
  if (myProfile != null && displayNameController.text.isEmpty) {
    displayNameController.text = myProfile.displayName ?? '';
  }
  return null;
}, [myProfile]);
\`\`\`

### 理由
- `useEffect` は依存配列の選択が副作用の挙動を大きく変える
- 意図が不明確だとレビュー時に「なぜこの依存配列？」という疑問が生じる
- コメントがあることで、将来の修正時に依存配列を安易に変更してしまうリスクを防げる
```

#### 1-5. `.claude/rules/riverpod-rules.md`

```markdown
---
paths:
  - "lib/**/*.dart"
---

# Riverpod 使用ルール

## ref.watch と ref.read の使い分け

### build メソッド内では `ref.watch` を使う
`ConsumerWidget` や `HookConsumerWidget` の `build` メソッド内でProviderの値を取得する場合は、必ず `ref.watch` を使用する。`ref.read` を使うとProviderの値が変化してもWidgetが再ビルドされず、UIに反映されない。

\`\`\`dart
// OK
@override
Widget build(BuildContext context, WidgetRef ref) {
  final myProvider = ref.watch(myProviderProvider);
  ...
}

// NG: build内でref.readを使ってはいけない
@override
Widget build(BuildContext context, WidgetRef ref) {
  final myProvider = ref.read(myProviderProvider);
  ...
}
\`\`\`

### `ref.read` を使うべき場面
`onPressed` などのコールバック内や非同期処理のクロージャ内など、build外で一度だけProviderの値を読み取りたい場合に使用する。

\`\`\`dart
onPressed: () {
  final value = ref.read(someProvider);
  value.doSomething();
}
\`\`\`

### firestoreのDBに書き込むProviderでの ref.read
firestoreのDBに書き込むProviderでは、`ref.read` を使用してクロージャの中で呼ぶ。
```

> **Note**: 既存の `hooks-and-consumer-widget.md` の section 3 と一部内容が重複するが、観点が違う（こちらは基本ルール、向こうは「データの流れの切断」という具体的な罠）ため両立可能。コーディング規約 `coding-conventions.md` の12行目（`ref.watch` / `ref.read`）と同じ内容だが、こちらの方がより詳しいのでそのまま並立させる。完全な統合は別タスクで検討。

#### 1-6. `.claude/rules/entity-parent-id-rules.md`

```markdown
---
paths:
  - "lib/entity/**/*.dart"
---

# Entity 親IDルール

## ルール
Firestoreのサブコレクションに保存されるEntityは、親ドキュメントのIDをフィールドとして保持する。

## 理由
- Firestoreのドキュメントパスからしか親IDを取得できない場合、ドキュメント単体で扱う際に親情報が失われる
- Entity単体で完結した情報を持つことで、UIやロジックでの取り回しが容易になる

## 例
`groups/{groupID}/categoryAxes/{axisID}` に保存される `GroupCategoryAxis` は `groupID` フィールドを持つ。

対象は `lib/entity/` 配下の各Entityを参照すること。
```

#### 1-7. `.claude/rules/typescript-rules.md`

```markdown
---
paths:
  - "firebase/functions/**/*.ts"
---

# TypeScript コーディング規約

## any 型の回避
Firestoreの `doc.data()` 等、`any` を返すAPIの戻り値はそのまま使用しない。`interface` を定義して `as` で型アサーションし、以降の処理で型安全にアクセスする。

\`\`\`typescript
// NG: any のまま使用
const data = doc.data();
const name = data?.name; // any

// OK: interface を定義して型アサーション
interface GroupData {
  memberUserIDs: string[];
  ownerUserID: string | null;
  name: string | null;
}
const data = doc.data() as GroupData | undefined;
const name = data?.name; // string | null | undefined
\`\`\`
```

#### 1-8. `.claude/rules/firebase-functions-call-rules.md`

```markdown
---
paths:
  - "lib/**/*.dart"
---

# Firebase Functions 呼び出しルール

## クライアント側の呼び出し方式

Firebase Functionsの呼び出しは、`lib/utils/functions/firebase_function.dart` に定義された `functions` インスタンスの拡張メソッドを直接呼ぶ。

### NG: Provider + Classでラップする
\`\`\`dart
// 不要なラッパー
class RemoveGroupMember {
  Future<void> call({required String groupID, required String targetUserID}) async {
    await functions.removeGroupMember(groupID: groupID, targetUserID: targetUserID);
  }
}

@Riverpod(dependencies: [])
RemoveGroupMember removeGroupMember(RemoveGroupMemberRef ref) {
  return RemoveGroupMember();
}

// 呼び出し
await ref.read(removeGroupMemberProvider).call(groupID: groupID, targetUserID: targetUserID);
\`\`\`

### OK: 直接呼ぶ
\`\`\`dart
import 'package:shoppinglist/utils/functions/firebase_function.dart';

await functions.removeGroupMember(groupID: groupID, targetUserID: targetUserID);
\`\`\`

### 理由
- Firebase Functions呼び出しは状態を持たないため、Riverpod Providerで管理する必要がない
- `functions` はグローバルインスタンスで、拡張メソッドとして定義済み
- 余分な間接層を排除し、コードをシンプルに保つ

### 例外
Firestoreへの直接読み書き（Functions経由でないもの）は、引き続き `call` メソッドを持つclassとProviderで定義する。これはDBアクセスに必要なコンテキスト（groupID等）を注入する必要があるため。
```

> **重要**: このルールは現状コードと矛盾している（Step 5 で issue 化）。だが「documents が正しい」というユーザー判断に従い、ルールはこのまま移行する。

#### 1-9. `.claude/rules/feature-readme-guideline.md`

```markdown
---
paths:
  - "lib/features/**/*.dart"
---

# Feature README ガイドライン

## ルール
各機能(Feature)ディレクトリには必ず `README.md` を作成し、以下の内容を記載する。

## 記載内容
- **概要**: 機能の説明
- **画面**: 画面名・表示条件・操作内容
- **フロー**: ユーザーの操作フロー（ステップバイステップ）
- **データ形式**: 関連するデータの形式や制約（該当する場合）
- **有効期限・制約**: 期限や制限事項（該当する場合）

## 配置場所
`lib/features/{feature_name}/README.md`

## 目的
- 機能の全体像を素早く把握できるようにする
- 新規開発者やAIアシスタントがコンテキストを得る際の入口にする
- コードを読まなくても機能の仕様を理解できるようにする
```

---

### Step 2: 既存 `.claude/rules/` ファイルの整理

#### 2-1. `.claude/rules/firestore-composite-id.md` を削除

理由: 内容が `firestore-document-id-rules.md` の要約版で、重複（SSOT 違反）。詳細版を新ルールとして配置するため、要約版は削除する。

```bash
# 実行コマンド（plan 実行時）
rm /Users/bannzai/worktrees/bannzai/shoppinglist/move-to-rules/.claude/rules/firestore-composite-id.md
```

#### 2-2. `.claude/rules/coding-conventions.md` の参照を更新

現在の14行目:
```markdown
- Firestoreのサブコレクションに保存されるEntityは、親ドキュメントのIDをフィールドとして保持する（詳細: `documents/entity-parent-id-rules.md`）
```

修正後（参照削除。新しい entity-parent-id-rules.md は同じ `.claude/rules/` 内に存在し、`lib/entity/**/*.dart` を編集する際に自動ロードされるため、参照不要）:

```markdown
- Firestoreのサブコレクションに保存されるEntityは、親ドキュメントのIDをフィールドとして保持する
```

Edit ツール使用例:
```
Edit({
  file_path: ".claude/rules/coding-conventions.md",
  old_string: "- Firestoreのサブコレクションに保存されるEntityは、親ドキュメントのIDをフィールドとして保持する（詳細: `documents/entity-parent-id-rules.md`）",
  new_string: "- Firestoreのサブコレクションに保存されるEntityは、親ドキュメントのIDをフィールドとして保持する"
})
```

---

### Step 3: 外部参照を全て更新

#### 3-1. `CLAUDE.md` の更新

**(a) 54行目 entity-parent-id-rules.md への参照を削除**

現在:
```markdown
- Firestoreのサブコレクションに保存されるEntityは、親ドキュメントのIDをフィールドとして保持する（詳細: `documents/entity-parent-id-rules.md`）
```

修正後:
```markdown
- Firestoreのサブコレクションに保存されるEntityは、親ドキュメントのIDをフィールドとして保持する
```

> 理由: `.claude/rules/entity-parent-id-rules.md` が `lib/entity/**/*.dart` を編集する際に自動ロードされるため、CLAUDE.md でわざわざ参照する必要がない。

**(b) 63行目の `documents/` ディレクトリ説明を更新**

現在:
```markdown
- その他、コーディング規約や機能に依存しない全体的な指示やドキュメント、メモは documents/ ディレクトリに配置する
```

修正後:
```markdown
- コーディング規約・ルールは `.claude/rules/` ディレクトリに配置する（Claude Code rules機能で自動ロード）
- プロジェクト仕様書・ADR等のドキュメントは `documents/` ディレクトリに配置する
```

#### 3-2. `.claude/rules/project-structure.md` の更新

現在の5行目:
```markdown
- その他、コーディング規約や機能に依存しない全体的な指示やドキュメント、メモは documents/ ディレクトリに配置する
```

修正後:
```markdown
- コーディング規約・ルールは `.claude/rules/` ディレクトリに配置する
- プロジェクト仕様書・ADR等のドキュメントは `documents/` ディレクトリに配置する
```

#### 3-3. `.claude/skills/check-coding-conventions/references/convention-checklist.md` の更新

現在の42-43行目:
```markdown
- [ ] `documents/firestore-timestamp-rules.md` の規約に従っているか
- [ ] `documents/firestore-fieldvalue-rules.md` の規約に従っているか
```

修正後:
```markdown
- [ ] `.claude/rules/firestore-timestamp-rules.md` の規約に従っているか
- [ ] `.claude/rules/firestore-fieldvalue-rules.md` の規約に従っているか
```

#### 3-4. `.claude/skills/check-coding-conventions/references/prompt_template.md` の更新

現在の12行目（推定）:
```markdown
2. `documents/` 配下の全 `.md` ファイルを読み込む
```

修正後:
```markdown
2. `.claude/rules/` 配下の全 `.md` ファイルを読み込む
```

#### 3-5. `.claude/skills/fix-pr-reviews/references/review-evaluation-guide.md` の更新

現在の10行目（推定）:
```markdown
`.claude/rules/` または `documents/` に明記された規約に違反している
```

修正後:
```markdown
`.claude/rules/` に明記された規約に違反している
```

#### 3-6. `.claude/skills/fix-pr-reviews/references/prompt_template.md` の更新

現在の15行目（推定）:
```markdown
5. `.claude/rules/` と `documents/` の規約ファイルを読み込む
```

修正後:
```markdown
5. `.claude/rules/` の規約ファイルを読み込む
```

#### 3-7. `.claude/skills/release-test/SKILL.md` の更新

現在の78行目（推定）:
```markdown
5. プロジェクトのCLAUDE.md、documents/ を参照
```

修正後:
```markdown
5. プロジェクトのCLAUDE.md、.claude/rules/、documents/ を参照
```

> 注: release-test は仕様書（PROJECT.md 等）も読むため `documents/` 参照は維持。

---

### Step 4: `documents/` 配下の元ファイル9個を削除

```bash
# 実行コマンド（plan 実行時）
rm /Users/bannzai/worktrees/bannzai/shoppinglist/move-to-rules/documents/firestore-document-id-rules.md
rm /Users/bannzai/worktrees/bannzai/shoppinglist/move-to-rules/documents/firestore-fieldvalue-rules.md
rm /Users/bannzai/worktrees/bannzai/shoppinglist/move-to-rules/documents/firestore-timestamp-rules.md
rm /Users/bannzai/worktrees/bannzai/shoppinglist/move-to-rules/documents/flutter-hooks-rules.md
rm /Users/bannzai/worktrees/bannzai/shoppinglist/move-to-rules/documents/riverpod-rules.md
rm /Users/bannzai/worktrees/bannzai/shoppinglist/move-to-rules/documents/entity-parent-id-rules.md
rm /Users/bannzai/worktrees/bannzai/shoppinglist/move-to-rules/documents/typescript-rules.md
rm /Users/bannzai/worktrees/bannzai/shoppinglist/move-to-rules/documents/firebase-functions-call-rules.md
rm /Users/bannzai/worktrees/bannzai/shoppinglist/move-to-rules/documents/feature-readme-guideline.md
```

削除後の `documents/` 配下に残るファイル:
- `documents/PROJECT.md`
- `documents/adr/` （8 ADRファイル）

---

### Step 5: コード違反 issue の作成

`firebase-functions-call-rules.md` のルール「Firebase Functions 呼び出しは Provider+Class でラップしない」に違反している既存コードを修正するための issue を作成する。

#### 違反箇所
- `lib/provider/group_create.dart:10-33` — `CreateGroup` クラスを Provider 経由で提供
- `lib/provider/group_invitation.dart:9-42` — `CreateGroupInvitation` と `AcceptGroupInvitation` クラスを Provider 経由

#### Issue 作成コマンド（plan 実行時）

```bash
gh issue create \
  --title "Firebase Functions 呼び出しから不要な Provider+Class ラッパーを削除" \
  --body "$(cat <<'EOF'
## 背景
\`.claude/rules/firebase-functions-call-rules.md\` に「Firebase Functions 呼び出しは \`functions\` インスタンスの拡張メソッドを直接呼ぶ。Provider+Class でラップしない」というルールがあるが、現状コードはこれに違反している。

## 違反箇所
- \`lib/provider/group_create.dart:10-33\` — \`CreateGroup\` クラスを Provider 経由で提供
- \`lib/provider/group_invitation.dart:9-42\` — \`CreateGroupInvitation\` と \`AcceptGroupInvitation\` クラスを Provider 経由

## 修正方針
1. 上記2ファイルから \`CreateGroup\`, \`CreateGroupInvitation\`, \`AcceptGroupInvitation\` クラスと Provider 定義を削除
2. 呼び出し元（\`ref.read(createGroupProvider).call(...)\` 等）を \`functions.createGroup(...)\` の直接呼び出しに変更
3. 関連するコード生成ファイル（\*.g.dart）を \`dart run build_runner build\` で更新
4. 既存テストが通ることを確認

## 注意
Firestoreへの直接読み書き（Functions経由でないもの）は、引き続き \`call\` メソッドを持つclassとProviderで定義する。今回の修正対象は **Firebase Functions 呼び出しのみ**。

## 検証
- \`flutter analyze\` エラーなし
- \`flutter test\` 全件パス
- iOS/Android ビルド成功
EOF
)" \
  --label "refactor"
```

> **重要**: ユーザー指示「issueを作成しておいて」に従い、plan 実行時に必ず gh issue create を実行する。

---

### Step 6: flutter-hooks-rules 未準拠箇所の TODO 化

flutter-hooks-rules.md の useEffect コメント規約に未準拠の箇所があるが、ユーザー判断によりコード修正は別タスク。issue として記録する。

#### 違反箇所
- `lib/features/resolver/force_update.dart:23` — コメント未記載
- `lib/features/resolver/auth.dart:35` — コメント未記載
- `lib/features/resolver/database.dart:302` — コメント未記載
- `lib/features/home/page.dart:40-46` — コメント不完全

#### Issue 作成コマンド（plan 実行時）

```bash
gh issue create \
  --title "useEffect に flutter-hooks-rules 準拠のコメント追加" \
  --body "$(cat <<'EOF'
## 背景
\`.claude/rules/flutter-hooks-rules.md\` で「\`useEffect\` には目的と依存配列の意図をコメントで明記する」というルールがあるが、以下の箇所で未対応・不完全。

## 対象ファイル
- \`lib/features/resolver/force_update.dart:23\` — コメント未記載
- \`lib/features/resolver/auth.dart:35\` — コメント未記載
- \`lib/features/resolver/database.dart:302\` — コメント未記載
- \`lib/features/home/page.dart:40-46\` — コメント不完全

## 修正方針
各 \`useEffect\` の直前に以下を追加:
1. **目的**: 何をするためのEffectか
2. **依存配列の意図**: なぜその依存配列にしたのか

## 検証
- \`flutter analyze\` エラーなし
EOF
)" \
  --label "refactor,documentation"
```

---

## 検証手順（plan 実行後）

### A. ファイル構造の検証

```bash
# .claude/rules/ に9個の新ファイルが存在することを確認
ls /Users/bannzai/worktrees/bannzai/shoppinglist/move-to-rules/.claude/rules/
# 期待値: firestore-document-id-rules.md, firestore-fieldvalue-rules.md, 
#         firestore-timestamp-rules.md, flutter-hooks-rules.md, riverpod-rules.md,
#         entity-parent-id-rules.md, typescript-rules.md, firebase-functions-call-rules.md,
#         feature-readme-guideline.md, analytics.md, plan-checklist.md, coding-conventions.md,
#         hooks-and-consumer-widget.md, firebase-functions.md, project-structure.md,
#         firestore-transaction.md
# 期待値（削除されたもの）: firestore-composite-id.md は **存在しない**

# documents/ に PROJECT.md と adr/ のみが残ることを確認
ls /Users/bannzai/worktrees/bannzai/shoppinglist/move-to-rules/documents/
# 期待値: PROJECT.md, adr/
```

### B. frontmatter の検証

新規作成した9ファイル全てに `paths:` フロントマターが付いていることを確認。

```bash
# 各ファイルの先頭5行を確認
for f in firestore-document-id-rules.md firestore-fieldvalue-rules.md firestore-timestamp-rules.md flutter-hooks-rules.md riverpod-rules.md entity-parent-id-rules.md typescript-rules.md firebase-functions-call-rules.md feature-readme-guideline.md; do
  echo "=== $f ==="
  head -5 "/Users/bannzai/worktrees/bannzai/shoppinglist/move-to-rules/.claude/rules/$f"
done
```

### C. 参照リンク切れの検証

```bash
# documents/ への参照が残っていないことを確認（PROJECT.md と adr/ への参照は除外）
grep -rn "documents/" /Users/bannzai/worktrees/bannzai/shoppinglist/move-to-rules/CLAUDE.md \
  /Users/bannzai/worktrees/bannzai/shoppinglist/move-to-rules/.claude/ \
  | grep -v "documents/PROJECT.md\|documents/adr"
# 期待値: 検出なし（または release-test のような documents/ 全体参照は許容）
```

### D. Claude Code rules 機能の動作確認

実際に Claude Code で `.dart` ファイルを開いた際にルールがロードされることを確認:

1. `lib/entity/group_user_profile.dart` を開く → `entity-parent-id-rules.md` がロードされる
2. `firebase/functions/src/functions/createGroup/function.ts` を開く → `firestore-document-id-rules.md`, `firestore-timestamp-rules.md`, `typescript-rules.md` がロードされる
3. `lib/features/shopping_list/page.dart` を開く → `flutter-hooks-rules.md`, `riverpod-rules.md`, `firebase-functions-call-rules.md`, `feature-readme-guideline.md` がロードされる

> **動作確認方法**: Claude Code のセッションで該当ファイルを Read した後、プロンプトでルール内容について尋ねて、ロードされたルールを参照していることを確認する。

### E. issue が作成されたことを確認

```bash
gh issue list --label "refactor" --limit 10
# 期待値: 上記2つの issue (Firebase Functions ラッパー削除, useEffect コメント追加) が表示される
```

### F. ビルド・テストの検証

`.claude/rules/` への移行はファイル移動のみでコード変更なしのため、コンパイル系の検証は **不要**（Step 5 / Step 6 の issue 化で実コード修正は別途）。ただし念のため:

```bash
# Flutter
cd /Users/bannzai/worktrees/bannzai/shoppinglist/move-to-rules && flutter analyze
# 期待値: コード変更なしのためエラーなし

# Firebase Functions
cd /Users/bannzai/worktrees/bannzai/shoppinglist/move-to-rules/firebase/functions/functions && npm run lint
# 期待値: コード変更なしのためエラーなし
```

---

## 影響を受けるファイル一覧

### 新規作成（9）
- `.claude/rules/firestore-document-id-rules.md`
- `.claude/rules/firestore-fieldvalue-rules.md`
- `.claude/rules/firestore-timestamp-rules.md`
- `.claude/rules/flutter-hooks-rules.md`
- `.claude/rules/riverpod-rules.md`
- `.claude/rules/entity-parent-id-rules.md`
- `.claude/rules/typescript-rules.md`
- `.claude/rules/firebase-functions-call-rules.md`
- `.claude/rules/feature-readme-guideline.md`

### 削除（10）
- `.claude/rules/firestore-composite-id.md` （要約版なので削除）
- `documents/firestore-document-id-rules.md`
- `documents/firestore-fieldvalue-rules.md`
- `documents/firestore-timestamp-rules.md`
- `documents/flutter-hooks-rules.md`
- `documents/riverpod-rules.md`
- `documents/entity-parent-id-rules.md`
- `documents/typescript-rules.md`
- `documents/firebase-functions-call-rules.md`
- `documents/feature-readme-guideline.md`

### 編集（7）
- `CLAUDE.md` （54行目, 63行目）
- `.claude/rules/coding-conventions.md` （14行目）
- `.claude/rules/project-structure.md` （5行目）
- `.claude/skills/check-coding-conventions/references/convention-checklist.md` （42-43行目）
- `.claude/skills/check-coding-conventions/references/prompt_template.md` （12行目）
- `.claude/skills/fix-pr-reviews/references/review-evaluation-guide.md` （10行目）
- `.claude/skills/fix-pr-reviews/references/prompt_template.md` （15行目）

### Issue 作成（2）
- Firebase Functions 呼び出し Provider+Class ラッパー削除
- useEffect コメント追加

---

## チェックリスト

### 実装内容
- [ ] 変更対象ファイルごとに具体的なコード提案をコードブロックで記載している
- [ ] 既存コードのパターン・構成を確認し、同じパターンで実装している
- [ ] 新規 rules ファイル9個に frontmatter `paths:` が付与されている
- [ ] `.claude/rules/firestore-composite-id.md` が削除されている
- [ ] documents/ には PROJECT.md と adr/ のみが残る
- [ ] CLAUDE.md と .claude/skills/ 配下の参照が全て更新されている
- [ ] firebase-functions-call-rules 違反コードの修正 issue が作成されている
- [ ] flutter-hooks-rules 未準拠の useEffect コメント追加 issue が作成されている

### Flutter（lib/ に変更がある場合）
- [ ] コード生成: `dart run build_runner build` で生成ファイル更新（コード変更なしのため不要）
- [ ] 静的解析: `flutter analyze` エラーなし
- [ ] テスト: `flutter test` 全件パス（コード変更なしのため不要）
- [ ] iOS ビルド: `flutter build ios` 成功（コード変更なしのため不要）
- [ ] Android ビルド: `flutter build apk` 成功（コード変更なしのため不要）
- [ ] 新規・変更機能に対するテストが存在する（該当なし）
- [ ] Maestro E2E: 該当する maestro flow があれば実行、なければ新規作成（該当なし）
- [ ] Entity命名: フィールド名が省略されていない（該当なし）
- [ ] DB操作: Firestore操作は `call` クラスのProvider経由（該当なし）
- [ ] 引数: 関数・コンストラクタの引数に `{required}` あり（該当なし）
- [ ] ref使い分け: build内は `ref.watch`、コールバック・操作は `ref.read`（該当なし）
- [ ] サブコレクションEntityに親ドキュメントIDフィールドあり（該当なし）

### Firebase（firebase/ に変更がある場合）
- [ ] Lint: `npm run lint` パス（コード変更なしのため不要）
- [ ] ビルド: `npm run build` 成功（コード変更なしのため不要）
- [ ] テスト: `npm test` 全件パス（コード変更なしのため不要）
- [ ] クライアント呼び出し関数はGenKitで定義（該当なし）
- [ ] onDocumentCreated/onDocumentUpdated トリガーを使っていない（該当なし）
- [ ] 新規・変更機能に対するテストが存在する（該当なし）

### 共通
- [ ] エラーメッセージはそのまま表示（加工・プレフィックス除去なし）（該当なし）
