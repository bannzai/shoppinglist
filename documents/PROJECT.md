# 買い物リスト

## アプリ概要

「買い物リスト」は、日常の買い物を効率化するモバイルアプリ。個人での利用はもちろん、家族やルームメイトなどグループでの買い物リスト共有に対応する。

### ターゲットユーザー

- 日常的に買い物をする個人
- 家族・同居人と買い物を分担している人
- 複数の店舗を使い分けている人

### 解決する課題

- 買い忘れの防止
- 「何を買うか」の共有コスト（LINEで聞く、メモを写真で送る等）の解消
- 店舗ごと・カテゴリごとの買い物の整理

## コンセプト

- **個人でもグループでも使える**: 初回利用時は自動で「ソログループ（個人用）」が作成され、個人用メモアプリのように使える。必要に応じてグループを作成し、家族や同居人と共有できる
- **シンプルさ**: 買い物リストの作成 → アイテム追加 → チェック という基本フローを最短で完了できる
- **繰り返し利用に最適化**: 過去のリストを複製して再利用可能。よく行く店舗・よく使うカテゴリを登録しておくことで、毎回の入力を最小化

## 技術スタック

| レイヤー | 技術 |
|---------|------|
| クライアント | Flutter (iOS / Android) |
| 認証 | Firebase Authentication |
| データベース | Cloud Firestore |
| バックエンドロジック | Firebase Functions (GenKit) |
| 状態管理 | Riverpod |
| コード生成 | Freezed / json_serializable / riverpod_generator |

## 機能一覧

### 基本機能（買い物リスト）

| 機能 | 説明 |
|------|------|
| リスト作成 | 買い物リストを作成する。名前・グループ・場所を指定可能 |
| アイテム追加 | テキストまたはリンクとしてアイテムを追加 |
| チェック | 買ったアイテムにチェックを入れる |
| 並べ替え | ドラッグ&ドロップでアイテムの順番を変更 |
| 複製 | 既存リストを複製して新しいリストを作成（チェック状態はリセット） |
| 補足説明 | アイテムに補足テキストを追加（例: 「低脂肪のやつ」） |
| 色分け | アイテムに色を設定して視覚的に区別 |
| TTL（自動期限） | 一定期間後にリストを非表示にする |

### グループ機能

| 機能 | 説明 |
|------|------|
| ソログループ | 初回ログイン時に自動作成される個人用グループ。削除不可 |
| グループ作成 | 任意のグループを作成し、名前を設定 |
| URL招待 | 招待URLを生成してグループにメンバーを追加 |
| メンバー管理 | メンバー一覧表示、オーナーによるメンバー削除 |
| デフォルトグループ | よく使うグループを既定に設定 |
| リストのグループ移動 | 買い物リストを別グループに移動、またはソログループに戻す |

### 整理機能

| 機能 | 説明 |
|------|------|
| 買い物する場所 | グループごとに店舗（スーパー・ドラッグストア等）を登録。リストに紐付けて管理 |
| 商品カテゴリ | グループごとにカテゴリ（野菜・肉・日用品等）を登録。アイテムに紐付けて管理 |
| カテゴリソート | カテゴリの並び順に基づいてアイテムを自動ソート。店内の動線に合わせた並びが可能 |

## データモデル（Firestore）

```
/users/{userID}
  - id
  - soloGroupID          # 個人用グループのID（自動作成、削除不可）
  - defaultGroupID?      # デフォルトグループのID
  - createdDateTime
  - updatedDateTime

/groups/{groupID}
  - id
  - name                 # グループ名
  - members: string[]    # メンバーのuserID一覧
  - ownerID              # オーナーのuserID
  - createdDateTime
  - updatedDateTime

/groups/{groupID}/shoppingLists/{shoppingListID}
  - id
  - groupID
  - name                              # リスト名
  - status                            # active / archived
  - groupShoppingLocationID?          # 紐付けられた場所
  - duplicatedFromGroupShoppingListID? # 複製元リストのID
  - ttlExpiresDateTime                # 自動非表示の期限
  - createdDateTime
  - updatedDateTime

/groups/{groupID}/shoppingLists/{shoppingListID}/items/{itemID}
  - id
  - groupShoppingListID
  - message              # アイテム名
  - description?         # 補足説明
  - color?               # 色（hex値）
  - groupShoppingListItemCategoryID?  # カテゴリID
  - order                # 並び順
  - status               # checked / unchecked
  - type                 # text / link
  - link?                # type=link の場合のURL
  - createdDateTime
  - updatedDateTime

/groups/{groupID}/shoppingLocations/{locationID}
  - id
  - name                 # 場所名（例: イオン、マツキヨ）
  - createdDateTime
  - updatedDateTime

/groups/{groupID}/categoryAxes/{axisID}
  - id
  - name                 # 軸名（例: 商品カテゴリ）
  - order                # 軸の並び順
  - createdDateTime
  - updatedDateTime

/groups/{groupID}/categoryAxes/{axisID}/categories/{categoryID}
  - id
  - categoryAxisID
  - name                 # カテゴリ名（例: 野菜、肉、日用品）
  - order                # カテゴリの並び順
  - createdDateTime
  - updatedDateTime

/groupInvitations/{invitationID}
  - id
  - groupID
  - inviterID            # 招待者のuserID
  - token                # 招待トークン
  - expiresDateTime      # 有効期限
  - status               # pending / accepted / expired
  - createdDateTime
  - updatedDateTime
```

## 画面構成

| 画面 | 役割 |
|------|------|
| ホーム | グループ切り替え + そのグループの買い物リスト一覧 |
| 買い物リスト詳細 | アイテム一覧、チェック、並べ替え、カテゴリソート切替 |
| アイテム編集 | アイテムの名前・補足説明・色・カテゴリの編集 |
| 買い物リスト設定 | リスト名・場所・グループ変更・複製・削除 |
| グループ一覧 | 所属グループの一覧、新規作成 |
| グループ詳細 | メンバー一覧、招待、メンバー削除、グループ名編集 |
| グループ設定 | カテゴリ管理・場所管理への導線 |
| カテゴリ管理 | カテゴリの一覧・追加・編集・削除・並べ替え |
| 場所管理 | 買い物場所の一覧・追加・編集・削除 |
| 招待受け入れ | Deep Linkから開く招待確認画面 |

## 開発ロードマップ

### Phase 1: 基盤（必須・順序依存）

| GitHub Issue | 内容 | サイズ |
|-------------|------|--------|
| #10 | Memo → ShoppingList リネーム & Group中心データモデル再設計 | XL |
| #11 | Group基盤 - Entity・CRUD・1人グループ自動作成 | L |

### Phase 2: 主要機能（Phase 1完了後、並行可能）

| GitHub Issue | 内容 | サイズ |
|-------------|------|--------|
| #12 | グループ招待機能（URL招待） | L |
| #13 | グループメンバー管理UI | M |
| #14 | 買い物する場所（GroupShoppingLocation） | M |
| #15 | 商品カテゴリ（CategoryAxis / Category） | L |
| #17 | ShoppingListItem 拡張 - 補足説明 & 色プロパティ | M |
| #18 | 買い物リスト複製のグループ引き継ぎ | S |
| #19 | グループからの買い物リスト紐付け解除 | S |

### Phase 3: UI統合 & 応用機能

| GitHub Issue | 内容 | サイズ |
|-------------|------|--------|
| #16 | カテゴリソート順による買い物リスト表示 | M |
| #20 | ホーム画面リファクタ - グループベース表示 | L |
| #21 | グループ管理画面 | M |
| #22 | グループ設定画面（カテゴリ・場所管理統合） | M |

### 依存関係

```
#10 (リネーム & データモデル)
├── #11 (Group基盤)
│   ├── #12 (招待機能)
│   ├── #13 (メンバー管理UI)
│   ├── #14 (買い物する場所)
│   ├── #15 (商品カテゴリ)
│   │   └── #16 (カテゴリソート)
│   ├── #18 (複製グループ引き継ぎ)
│   ├── #19 (紐付け解除)
│   ├── #20 (ホーム画面リファクタ)
│   └── #21 (グループ管理画面)
├── #17 (補足説明 & 色)
└── #22 (グループ設定画面) ← #14, #15 にも依存
```
