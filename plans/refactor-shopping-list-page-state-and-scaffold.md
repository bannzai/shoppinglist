# ShoppingListPage 状態の Provider 化 / Resolver 化 / Scaffold 集約

## 背景・ゴール
`lib/features/shopping_list/page.dart` のリファクタリング相談（#1・#2）への対応。

- **#1**: `HomePage` が `Scaffold` を持ち、その body に `ShoppingListPage` を置く二段構造をやめる。`HomePage` は `return const ShoppingListPage();` の薄いラッパにし、`ShoppingListPage` が単一 `Scaffold` を持つ。
- **#2**: `HomeWidgetSync` は `groupID`/`shoppingListID` を引数で受けず、Provider を内部で watch する形にして RootPage の Resolver chain に移す。

ユーザー承認済みの方針:
- `currentGroupID` / `currentShoppingListID` を**アプリ全体の Provider** で保持する
- `HomePage` は**薄く残す**（`return const ShoppingListPage();`）
- `Scaffold` は **1枚に集約**（`_Body` 内側 Scaffold を廃止、FAB を `ShoppingListPage` へ引き上げ）

## 設計の要点
- 選択状態 Provider（`currentGroupID` / `currentShoppingListID`）は**他の scoped provider を読まない素の Notifier** にする。これにより riverpod の scope 依存（`@Riverpod(dependencies: [...])`）を持ち込まず、どこから読んでも安全。
- 「選択 + リスト一覧 → 実際に表示するリストID」への解決ロジックは**純粋関数 `resolveShoppingListID`** に切り出し、`ShoppingListPage` と `HomeWidgetSync` で共有（provider 化しないことで scope 問題を回避）。
- `currentGroupID` の既定値（`appUser.defaultGroupID`）の流し込みは **`CurrentGroupResolver`（scope 内の Widget）** が担う。Notifier 内では `appUserProvider` を読まない。

## 変更後のツリー
```
RootPage
 └ AppResolvers
    └ AppUserCreateResolver
       └ ForceUpdateResolver
          └ AppEntityPrepareResolver        // ここで group 確定 + list 1件以上を保証
             └ CurrentGroupResolver         // currentGroupID 未設定なら defaultGroupID で初期化
                └ HomeWidgetSync            // provider を内部 watch（引数なし）
                   └ HomePage               // return const ShoppingListPage();
                      └ ShoppingListPage    // 単一 Scaffold（FAB 込み）
```

---

## 変更対象ファイルと実装コード

### 新規 `lib/provider/current_group_id.dart`
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_group_id.g.dart';

/// 現在表示中のグループID。アプリ全体で1つだけ保持する選択状態。
///
/// 既定値(appUser.defaultGroupID)の初期化は CurrentGroupResolver が行う。
/// ここで appUserProvider を読まないのは、appUser の更新ごとに build が再実行され
/// ユーザーの手動グループ切替がリセットされるのを避けるため(scope 依存も持ち込まない)。
@riverpod
class CurrentGroupID extends _$CurrentGroupID {
  @override
  String? build() => null;

  void update(String groupID) => state = groupID;
}
```

### 新規 `lib/provider/current_shopping_list_id.dart`
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shoppinglist/entity/group_shopping_list.dart';

part 'current_shopping_list_id.g.dart';

/// ユーザーが明示的に選択した買い物リストID。未選択(=先頭にフォールバック)なら null。
/// グループ切替時は null に戻す(切替先グループの先頭リストへフォールバックさせる)。
@riverpod
class CurrentShoppingListID extends _$CurrentShoppingListID {
  @override
  String? build() => null;

  void update(String? shoppingListID) => state = shoppingListID;
}

/// 選択IDとリスト一覧から、実際に表示すべき買い物リストIDを解決する。
/// 選択が null / 一覧に存在しない場合は先頭リストにフォールバックする。一覧が空なら null。
///
/// ShoppingListPage と HomeWidgetSync の双方で同じ解決ルールを共有するための純粋関数
/// (provider 化しないことで scope 依存を避ける)。
String? resolveShoppingListID({
  required String? selected,
  required List<GroupShoppingList> shoppingLists,
}) {
  if (shoppingLists.isEmpty) {
    return null;
  }
  if (selected != null && shoppingLists.any((e) => e.id == selected)) {
    return selected;
  }
  return shoppingLists.first.id;
}
```

### 新規 `lib/features/resolver/current_group_resolver.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/loading/loading.dart';
import 'package:shoppinglist/provider/app_user.dart';
import 'package:shoppinglist/provider/current_group_id.dart';

/// RootPage の Resolver パターンに倣い、currentGroupID を確定させてから子を描画する。
/// 親(AppEntityPrepareResolver)が defaultGroupID の存在を保証済みのため、ここでは
/// currentGroupID が未設定の間だけ appUser.defaultGroupID を流し込む初期化責務を持つ。
class CurrentGroupResolver extends HookConsumerWidget {
  final Widget Function(BuildContext context) builder;

  const CurrentGroupResolver({super.key, required this.builder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentGroupID = ref.watch(currentGroupIDProvider);
    final defaultGroupID =
        ref.watch(appUserProvider).valueOrNull?.defaultGroupID;

    // currentGroupID が未設定の時だけ defaultGroupID で初期化する。
    // build 中の state 変更を避けるため postFrame で反映する。手動切替後は
    // currentGroupID が非nullになるため、この初期化は上書きしない。
    // 依存配列は [currentGroupID, defaultGroupID] — どちらかが変わった時に再評価する。
    useEffect(() {
      if (currentGroupID == null && defaultGroupID != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(currentGroupIDProvider.notifier).update(defaultGroupID);
        });
      }
      return null;
    }, [currentGroupID, defaultGroupID]);

    if (currentGroupID == null) {
      return LaunchLoading.shared();
    }
    return builder(context);
  }
}
```

### 編集 `lib/root.dart`
`AppEntityPrepareResolver` の builder を `CurrentGroupResolver → HomeWidgetSync → HomePage` に置き換える。
```dart
return AppEntityPrepareResolver(builder: (context) {
  debugPrint('Resolved AppEntityPrepareResolver user: ${user.uid}');
  return CurrentGroupResolver(builder: (context) {
    return HomeWidgetSync(builder: (context) {
      return const HomePage();
    });
  });
});
```
import 追加: `current_group_resolver.dart`, `home_widget/home_widget_sync.dart`。

### 編集 `lib/features/home/page.dart`（薄く残す）
```dart
import 'package:flutter/material.dart';
import 'package:shoppinglist/features/shopping_list/page.dart';

/// アプリのホーム。状態(currentGroupID / currentShoppingListID)と表示は
/// それぞれ Provider と ShoppingListPage に分解済みのため、ここは入口名を保つだけの薄いラッパ。
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => const ShoppingListPage();
}
```

### 編集 `lib/features/shopping_list/page.dart`（単一 Scaffold へ集約・`_Body` を統合）
- コンストラクタを引数なし(`const ShoppingListPage({super.key})`)に変更。
- `groupID = ref.watch(currentGroupIDProvider)`、`currentShoppingListID = ref.watch(currentShoppingListIDProvider)` を読む。
- `showChecked` / `sortByCategory` の `useState`、変更検知 / 通知トースト / 自動通知の `useEffect` を `_Body` から本体へ移す。
- `resolvedShoppingListID` を build 上位で解決 → FAB と本文の双方へ供給。
- `Scaffold` は1枚。`backgroundColor` は paper、`ListTopBar` 帯の surface は `Container(color: surface)` で内側に再現、本文は `Container(color: card)`。
- グループ切替: `currentGroupIDProvider.update` + `currentShoppingListIDProvider.update(null)` + `defaultGroupUpdate`。
- リスト切替: `currentShoppingListIDProvider.update(newID)`。

（完全コードは実装時に反映。`_NoListYet` はそのまま流用。`_Body` クラスは削除し本文 Column を `ShoppingListPage.build` 内へ展開。）

### 編集 `lib/features/home_widget/home_widget_sync.dart`
- 引数 `groupID` / `shoppingListID` を削除。`currentGroupIDProvider` / `currentShoppingListIDProvider` を内部 watch し、`resolveShoppingListID` で現在リストを解決。
```dart
class HomeWidgetSync extends HookConsumerWidget {
  final Widget Function(BuildContext context) builder;
  const HomeWidgetSync({super.key, required this.builder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupID = ref.watch(currentGroupIDProvider);
    // CurrentGroupResolver 配下のため groupID は非nullだが、念のため早期 return。
    if (groupID == null) {
      return builder(context);
    }
    final firestoreIsPremium =
        ref.watch(firestoreIsPremiumProvider).asData?.value ?? false;
    final shoppingListsAsync = ref.watch(
        shoppingListsProvider(groupID: groupID, isPremium: firestoreIsPremium));
    final resolvedShoppingListID = resolveShoppingListID(
      selected: ref.watch(currentShoppingListIDProvider),
      shoppingLists: shoppingListsAsync.valueOrNull ?? [],
    );
    // ... theme / premium / lists の ref.listen は従来どおり
    // items の ref.listen は resolvedShoppingListID 非null時のみ意味を持つ
    return builder(context);
  }
}
```

### 編集 `lib/features/previews/screens/shopping_list_preview.dart`
```dart
import 'package:flutter/material.dart';
import 'package:shoppinglist/features/shopping_list/page.dart';

class ShoppingListPreview extends StatelessWidget {
  const ShoppingListPreview({super.key});

  @override
  Widget build(BuildContext context) => const ShoppingListPage();
}
```

### 編集 `lib/features/previews/mock/mock_provider_overrides.dart`
選択 Provider を mock 値に override（Notifier のサブクラスで build を差し替え）。
```dart
class _MockCurrentGroupID extends CurrentGroupID {
  @override
  String? build() => mockGroupID;
}

class _MockCurrentShoppingListID extends CurrentShoppingListID {
  @override
  String? build() => mockShoppingListID;
}

// previewProviderOverrides の返却リストに追加:
currentGroupIDProvider.overrideWith(() => _MockCurrentGroupID()),
currentShoppingListIDProvider.overrideWith(() => _MockCurrentShoppingListID()),
```

## 動作確認チェックリスト（手動）
- [ ] 通常起動でグループ→買い物リストが従来どおり表示される
- [ ] GroupChipsBar でグループ切替 → リストが切替先の先頭にフォールバックする
- [ ] ListTopBar のリスト切替シートでリスト変更 → 反映される
- [ ] FAB（追加・AI 抽出）が従来どおり動作する
- [ ] リスト 0 件のグループで `_NoListYet` が出る（実運用では AppEntityPrepareResolver が自動作成）
- [ ] ホームウィジェット同期（テーマ色・プレミアム・リスト・アイテム）が継続して動作
- [ ] Previews の HomePage / ShoppingListPage が表示できる
- [ ] 進捗ピル・通知トーストが従来どおり

---

## チェックリスト

### 実装内容
- [ ] 変更対象ファイルごとに具体的なコード提案をコードブロックで記載している
- [ ] 既存コードのパターン・構成を確認し、同じパターンで実装している（Resolver/Notifier/override）

### Flutter（lib/ に変更がある場合）
- [x] コード生成: `dart run build_runner build` で生成ファイル更新（current_group_id.g.dart / current_shopping_list_id.g.dart）
- [x] 静的解析: `flutter analyze lib/ test/` エラーなし（No issues found）
- [x] テスト: `flutter test` 全件パス（175件）
- [x] iOS ビルド: `flutter build ios --no-codesign` 成功（worktree の ios/.symlinks を deps file から再生成後）
- [ ] Android ビルド: AGP 不足の既存ブロッカーで未確認（Dart 変更とは無関係 / [[project_android_apk_build_agp_blocker]]）
- [x] 新規・変更機能に対するテスト: `resolveShoppingListID` のユニットテスト追加、metrics テストを関数版へ更新
- [ ] Maestro E2E: 既存 flow は design v2 へ未追従の既知状態で、本変更は UI 振る舞い・widget key を変えないため対象外（[[project_maestro_design_v2_stale_flows]]）
- [x] Entity命名: フィールド名が省略されていない
- [x] DB操作: Firestore 直接操作なし（defaultGroupUpdate は既存 call クラス Provider 経由のまま）
- [x] 引数: 関数・コンストラクタの引数に `{required}` あり
- [x] ref使い分け: build内は `ref.watch`、コールバック/操作（update・defaultGroupUpdate・invalidate）は `ref.read`
- [x] サブコレクションEntity: 本変更で新規 Entity なし（該当なし）

### 共通
- [ ] エラーメッセージはそのまま表示（加工・プレフィックス除去なし）
