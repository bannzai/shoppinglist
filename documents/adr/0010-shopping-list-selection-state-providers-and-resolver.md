# 0010. 買い物リスト画面の選択状態を Provider 化し Resolver/単一 Scaffold へ再構成する

## Status
Accepted

## Context
`ShoppingListPage` 周辺は次の構造になっていた。

- `HomePage` が `currentGroupID` / `currentShoppingListID` を `useState`（ローカル状態）で保持し、`Scaffold` を宣言してその body に `ShoppingListPage` を置く。
- `ShoppingListPage` 内部の `_Body` がもう一枚 `Scaffold`（FAB 付き）を宣言し、`Scaffold` が二重になっていた。
- 「現在表示中のリスト」は `_Body` の `data:` コールバック内で `resolvedShoppingListID` として解決され、その値に依存する `HomeWidgetSync`（ホームウィジェット同期）も同コールバック内に builder としてネストされていた。

この構造には以下の課題があった。

- 表示中グループ/リストの選択がローカル状態のため、`HomeWidgetSync` のように「現在の選択」を知りたい別ツリーの要素へ渡すには、表示ツリーの深い位置までバケツリレーする必要があった。
- FAB が必要とする `resolvedShoppingListID` が `_Body` の `data:` 内でしか確定しないため、FAB を内側 `Scaffold` に置かざるを得ず、`Scaffold` が二重化していた。
- `HomePage` が状態保持・Scaffold・状態解決の責務を抱えており、入口 Widget としては過剰だった。

リファクタ相談の中で「currentGroup も currentShoppingList もアプリ全体で保持してよい」「`HomePage` は薄く残す」「`Scaffold` は 1 枚に集約」という方針が合意された。

## Decision
1. **選択状態を Riverpod の Notifier Provider へ昇格する。** `currentGroupIDProvider` / `currentShoppingListIDProvider`（ともに `@riverpod` の autoDispose Notifier、`build() => null` + `update()`）を新設し、`HomePage` のローカル `useState` を置き換える。autoDispose のため、サインアウト等で画面ツリーが外れて誰も購読しなくなれば破棄され、別アカウント再ログイン時に前ユーザーの選択が残らない。
2. **既定値の初期化を Resolver が担う。** `currentGroupID` の初期値（`appUser.defaultGroupID`）の流し込みは、RootPage の Resolver chain（`AppResolvers → AppUserCreateResolver → ForceUpdateResolver → AppEntityPrepareResolver`）に倣った `CurrentGroupResolver` が担当する。`currentGroupID == null` の間だけ `defaultGroupID` を流し込み、確定までは `LaunchLoading` を出す。Notifier 内では `appUserProvider` 等の scoped provider を読まない（scope 依存・appUser 更新による選択リセットを避けるため）。
3. **選択 → 実表示リストIDの解決は純粋関数で共有する。** 「選択IDが null/一覧に無ければ先頭にフォールバック」する解決ロジックを provider 化せず、純粋関数 `resolveShoppingListID({selected, shoppingLists})` として `ShoppingListPage` と `HomeWidgetSync` の双方で共有する。provider 化すると scoped provider 群（`shoppingListsProvider` 等）への依存を持ち込むため、純粋関数で scope 結合を回避する。
4. **Scaffold を 1 枚に集約する。** `HomePage` と `_Body` の二重 `Scaffold` を `ShoppingListPage` の単一 `Scaffold` に統合し、FAB を `resolvedShoppingListID` 経由でトップへ引き上げる。`ListTopBar` 帯の surface 背景は内側の `Container(color: surface)` で再現し、従来のハイブリッドサーフェスの見た目を維持する。
5. **`HomeWidgetSync` を引数なし化して chain 上位へ移す。** `groupID` / `shoppingListID` 引数を廃止し、上記 provider を内部 `watch` する。`CurrentGroupResolver` 配下（`AppEntityPrepareResolver` がリスト 1 件以上を保証する位置）に置くことで、表示ツリーの深さに依存せず同期できる。
6. **`HomePage` は薄いラッパとして残す。** `return const ShoppingListPage();` のみのラッパとし、ルーティング上の入口名を保つ。

## Consequences
### 良い点
- 「現在の選択」がアプリ全体の単一の真実になり、`HomeWidgetSync` をはじめ任意の位置から参照できる。バケツリレーが不要になった。
- `Scaffold` が 1 枚になり、FAB の所属が明快になった。`HomePage` の責務が無くなり構造が読みやすくなった。
- 選択状態の初期化責務が `CurrentGroupResolver` に集約され、既存の Resolver パターンと一貫した。
- 解決ロジックを純粋関数にしたことで、scope 問題を持ち込まずに `ShoppingListPage` と `HomeWidgetSync` で共有でき、ユニットテストも容易（`resolveShoppingListID` のテストを追加済み）。

### トレードオフ・注意点
- 選択状態がグローバル化したため、autoDispose による破棄タイミング（＝最後の購読者が外れた時）が「リセット」の境界になる。サインアウト→別アカウントの想定はこれで成立するが、将来 `keepAlive` 化する場合はリセット責務を別途設計する必要がある。
- `CurrentGroupResolver` は `currentGroupID` 未設定時に postFrame で初期化するため、初回に最大 1 フレーム `LaunchLoading` を挟む。親 Resolver も `LaunchLoading` 中のため体感上の追加フリッカーは無いが、初期化が build 中の同期処理ではない点は前提として持っておく。
- `ShoppingListPage` は `currentGroupIDProvider` が非null である前提（`CurrentGroupResolver` / preview override が保証）に依存する。hooks 数の一貫性のため、この不変条件が崩れない設計を維持する必要がある。
- Previews は `ShoppingListPage` が provider を読むようになったため、`currentGroupIDProvider` / `currentShoppingListIDProvider` の mock override が必要（`mock_provider_overrides.dart` に追加済み）。

### 検証
`flutter analyze` / `flutter test`（175 件）通過、`flutter build ios` 成功。iOS シミュレータ上で maestro（サインイン到達）＋ mobile-mcp（起動・アイテム追加・FAB タップ/長押し・リスト切替・グループチップ表示）の動作確認済み。
