# 買い物リスト UX 再編 — FAB / Header / Settings 入口

## Context

買い物リスト画面の主要 UX を以下の方向に整理する:

- **FAB の主操作を「空行を追加」に集約**: 最頻操作（テキスト直接入力で買い物アイテムを追加）を 1 タップで完了させ、写真/URL/テキスト貼り付けは長押し展開メニューに退避する。
- **不要な装飾の削除**: 「写真から追加」「URL から追加」の AI バッジ、リスト名入力欄下の「確定キーで保存されます」ヘルプテキスト。情報量を絞り視覚ノイズを減らす。
- **設定動線の整理**: 下部タブの「設定」を廃止して買い物リスト画面の右上に移動。1 タブだけ残す TabBar は意味がないため `AppBottomTabBar` ごと削除。
- **リスト設定アイコンの差別化**: アプリ全体設定（歯車）と被らないよう、買い物リスト個別設定（リスト設定）は `Icons.more_horiz` に変更。

## 要件サマリ（ユーザー承認済み）

1. FAB タップ＝空行追加（直接）、FAB 長押し＝展開メニュー（写真/URL/テキスト貼り付け）
2. 展開メニュー内「写真から追加」「URL から追加」横の AI バッジ削除
3. GroupChipsBar は現状維持（既に「2 つ以上で表示」実装済み）
4. `AppBottomTabBar` 完全削除、`HomePage` を `ShoppingListPage` 直配置に簡素化
5. リスト設定アイコン `Icons.settings_outlined` → `Icons.more_horiz`
6. アプリ全体設定への入口を `ListTopBar` 右端に新設（`Icons.settings_outlined`、`Navigator.push(SettingPage)`）
7. `shopping_list_setting/page.dart` の「確定キーで保存されます」Padding+Text 削除

## 変更ファイル一覧

| # | パス | 変更概要 |
|---|---|---|
| 1 | `lib/components/frame/app_bottom_tab_bar.dart` | ファイル削除 |
| 2 | `lib/features/home/page.dart` | TabController / HomePageTabType / AppBottomTabBar 撤去、ShoppingListPage 直配置 |
| 3 | `lib/features/settings/page.dart` | AppBar 追加、body 内 `Padding+Text('設定')` 削除 |
| 4 | `lib/features/shopping_list/components/list_top_bar.dart` | リスト設定 → `Icons.more_horiz` 変更、アプリ設定 IconButton 追加 |
| 5 | `lib/features/shopping_list/components/expandable_fab.dart` | FAB 動作変更（タップ=空行追加 / 長押し=展開）、空行追加メニュー項目削除、AI バッジ削除 |
| 6 | `lib/features/shopping_list_setting/page.dart` | 「確定キーで保存されます」削除 |
| 7 | `test/components/frame/frame_widgets_test.dart` | `AppBottomTabBar` テスト削除 |
| 8 | `maestro/flows/home_page_test.yaml` | タブ遷移検証 → ヘッダー右上設定遷移検証に書き換え |
| 9 | `maestro/flows/design_v2_list_settings.yaml` | 「確定キーで保存されます」アサート削除 |

---

## 詳細実装

### 1. `lib/components/frame/app_bottom_tab_bar.dart` 削除

ファイル全削除。他参照は `home/page.dart` と `frame_widgets_test.dart` のみ（grep 確認済み）。

### 2. `lib/features/home/page.dart` 簡素化

全置換:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/loading/loading.dart';
import 'package:shoppinglist/features/shopping_list/page.dart';
import 'package:shoppinglist/provider/app_user.dart';
import 'package:shoppinglist/provider/default_group_update.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appUserAsync = ref.watch(appUserProvider);
    final appUser = appUserAsync.asData?.value;
    final currentGroupID = useState<String?>(appUser?.defaultGroupID);

    useEffect(() {
      if (appUser?.defaultGroupID != null && currentGroupID.value == null) {
        currentGroupID.value = appUser!.defaultGroupID;
      }
      return null;
    }, [appUser?.defaultGroupID]);

    useEffect(() {
      analytics.setCurrentScreen(screenName: 'ShoppingListPage');
      return null;
    }, const []);

    final groupID = currentGroupID.value;
    if (groupID == null) {
      return const Loading();
    }

    final currentShoppingListID = useState<String?>(null);

    return Scaffold(
      backgroundColor: context.tokens.neutral.paper,
      body: ShoppingListPage(
        groupID: groupID,
        currentShoppingListID: currentShoppingListID,
        onGroupChanged: (newGroupID) {
          currentGroupID.value = newGroupID;
          currentShoppingListID.value = null;
          ref.read(defaultGroupUpdateProvider).call(groupID: newGroupID);
        },
      ),
    );
  }
}
```

- `HomePageTabType` enum / `HomePageTabFunctions` extension は削除
- `_screenTracking` は `useEffect` で初回 1 回だけ呼ぶ
- `DefaultTabController` / `TabBarView` / `useTabController` / `useSingleTickerProvider` / `tabIndex` / `AppBottomTabBar` / `SettingPage` import を全廃

### 3. `lib/features/settings/page.dart` AppBar 追加

L65-79 の Scaffold + 「設定」テキスト Padding を以下に置換:

```dart
return Scaffold(
  backgroundColor: tokens.neutral.paper,
  appBar: AppBar(
    title: const Text('設定'),
    backgroundColor: tokens.neutral.paper,
    leading: IconButton(
      icon: const Icon(Icons.close),
      onPressed: () {
        analytics.logEvent(name: 'tap_close_app_setting');
        Navigator.pop(context);
      },
    ),
  ),
  body: SafeArea(
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ↓ Padding+Text('設定') ブロックを削除
          SettingSectionTitle(text: 'プロフィール', children: [
            // ...既存のまま
```

- `appBar: null` → `appBar: AppBar(...)` に変更
- L73-79 の Padding+Text('設定') を削除（AppBar.title が見出しの役割を担う）
- `Icons.close` を leading に置く（既存 `ShoppingListSettingPage` と統一）

### 4. `lib/features/shopping_list/components/list_top_bar.dart` 右側 IconButton 追加

L97-132 の `IconButton(Icons.settings_outlined, 'リスト設定', ...)` を以下に置換:

```dart
            IconButton(
              key: const Key('list_setting_button'),
              icon: Icon(
                Icons.more_horiz,
                size: 22,
                color: tokens.neutral.ink2,
              ),
              tooltip: 'リスト設定',
              onPressed: shoppingList == null
                  ? null
                  : () {
                      analytics.logEvent(
                        name: 'tap_open_list_setting',
                        parameters: {
                          'groupID': groupID,
                          'shoppingListID': shoppingListID,
                        },
                      );
                      FocusScope.of(context).unfocus();
                      appShowModalBottomSheet(
                        context: context,
                        builder: (sheetContext) => ShoppingListSettingPage(
                          groupID: groupID,
                          shoppingListID: shoppingListID,
                          shoppingList: shoppingList!,
                          onDelete: () {
                            ref
                                .read(shoppingListDeleteProvider(
                                    groupID: groupID))
                                .call(shoppingListID: shoppingListID);
                            Navigator.of(sheetContext)
                                .popUntil((route) => route.isFirst);
                          },
                        ),
                      );
                    },
            ),
            IconButton(
              key: const Key('app_settings_button'),
              icon: Icon(
                Icons.settings_outlined,
                size: 22,
                color: tokens.neutral.ink2,
              ),
              tooltip: '設定',
              onPressed: () {
                analytics.logEvent(name: 'tap_open_app_setting');
                FocusScope.of(context).unfocus();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SettingPage(),
                  ),
                );
              },
            ),
```

import 追加:

```dart
import 'package:shoppinglist/features/settings/page.dart';
```

- リスト設定のアイコンを `Icons.more_horiz` に変更（key 付き Maestro 識別用）
- アプリ設定への IconButton を直後に追加（key 付き Maestro 識別用）
- 左タイトル領域は既に `Expanded(Text(maxLines:1, overflow: ellipsis))` のため、IconButton 増加でも長いリスト名は省略表示で吸収できる

### 5. `lib/features/shopping_list/components/expandable_fab.dart` FAB 動作変更

#### 5-1. import 追加

```dart
import 'package:flutter/services.dart';  // 既に import 済み（Clipboard 用）→ HapticFeedback はここに含まれる
```

`HapticFeedback` は既存の `services.dart` import で利用可能。

#### 5-2. クラスドキュメントコメント更新（L22-27）

```dart
/// `ShoppingListPage` の右下に配置する展開式 FAB。
/// タップ: 空行を直接追加。長押し: 写真 / URL / テキスト貼り付け の 3 メニューを上方向に展開。
```

#### 5-3. `actions` から「空行を追加」項目削除 + AI バッジ無効化（L68-115）

```dart
    final actions = <_FabAction>[
      _FabAction(
        icon: Icons.photo_camera_outlined,
        label: '写真から追加',
        onTap: () {
          close();
          _showImagePicker(context, ref);
        },
      ),
      _FabAction(
        icon: Icons.link,
        label: 'URL から追加',
        onTap: () {
          close();
          _showURLInputDialog(context, ref);
        },
      ),
      _FabAction(
        icon: Icons.content_paste_go_outlined,
        label: 'テキスト貼り付け',
        onTap: () {
          close();
          _pasteFromClipboard(context, ref);
        },
      ),
    ];
```

- `ai: true` フィールドを写真/URL から削除
- 空行追加（最後の `_FabAction`）を削除（FAB タップで実行されるため）

#### 5-4. `FloatingActionButton` の onPressed / onLongPress 変更（L134-153）

```dart
        AnimatedBuilder(
          animation: controller,
          builder: (_, __) => Transform.rotate(
            angle: controller.value * 0.785,
            child: FloatingActionButton(
              backgroundColor: tokens.accent,
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              onPressed: () {
                analytics.logEvent(name: 'tap_add_item_fab', parameters: {
                  'groupID': groupID,
                  'shoppingListID': shoppingListID,
                });
                ref.read(addShoppingListItemProvider(groupID: groupID)).call(
                      shoppingListID: shoppingListID,
                      userID: ref.read(currentUserIDProvider)!,
                      message: '',
                      order: shoppingListItems.nextOrder,
                      description: null,
                      color: null,
                    );
              },
              onLongPress: () {
                HapticFeedback.mediumImpact();
                analytics.logEvent(
                  name: 'long_press_open_fab_menu',
                  parameters: {
                    'groupID': groupID,
                    'shoppingListID': shoppingListID,
                  },
                );
                open.value = true;
              },
              child: const Icon(Icons.add, size: 26),
            ),
          ),
        ),
```

- `onPressed` を空行追加に直結（`addShoppingListItemProvider.call(message: '', ...)`）
- `onLongPress` で `HapticFeedback.mediumImpact()` + `open.value = true` でメニュー展開
- 既存 `tap_toggle_fab` analytics は廃止、`tap_add_item_fab` は流用、`long_press_open_fab_menu` を新規追加

#### 5-5. `_FabAction` クラスから `ai` / `primary` フィールド削除（L359-372）

```dart
class _FabAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  _FabAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}
```

#### 5-6. `_ActionRow` の primary 分岐削除（L411-425）

`primary` フラグがなくなるため、全アイテムを secondary 表示（44x44 / surface2 背景）に統一:

```dart
            Material(
              color: tokens.neutral.surface2,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: action.onTap,
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(
                    action.icon,
                    size: 20,
                    color: tokens.neutral.ink,
                  ),
                ),
              ),
            ),
```

#### 5-7. `_ActionLabel` の `ai` バッジ削除（L435-481）

```dart
class _ActionLabel extends StatelessWidget {
  final String label;
  const _ActionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: tokens.neutral.ink,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: tokens.neutral.surface,
            ),
      ),
    );
  }
}
```

- `ai` フィールドと `if (ai) ...` ブロックを完全削除
- `Row` でラップする必要がなくなったので単純な `Text` に
- `_ActionRow` での呼び出しも `_ActionLabel(label: action.label)` だけになる

### 6. `lib/features/shopping_list_setting/page.dart` 確定キー文言削除

L123-132 を削除:

```dart
              // 削除 ↓
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                child: Text(
                  '確定キーで保存されます',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: neutral.ink3,
                        fontSize: 11,
                      ),
                ),
              ),
              // 削除 ↑
              const SizedBox(height: 14),  // ← この行は残す（次のセクションラベルへの間隔として必要）
```

### 7. `test/components/frame/frame_widgets_test.dart` AppBottomTabBar テスト削除

L143-161 の `testWidgets('AppBottomTabBar: ...')` ブロック全削除。ファイル冒頭の `import 'package:shoppinglist/components/frame/app_bottom_tab_bar.dart';` も削除。

### 8. `maestro/flows/home_page_test.yaml` 書き換え

タブ機能検証を「右上設定アイコン経由の設定画面遷移」検証に置換:

```yaml
appId: com.bannzai.shoppinglist
---
- launchApp:
    clearState: true
    clearKeychain: true

- runFlow:
    when:
      visible: "許可"
    commands:
      - tapOn:
          text: "許可"
          retryTapIfNoChange: false
      - waitForAnimationToEnd

- extendedWaitUntil:
    visible: "サインイン"
    timeout: 30000
- tapOn: "匿名サインイン（デバッグ用）"
- waitForAnimationToEnd
- runFlow:
    when:
      visible: "Retry"
    commands:
      - tapOn: "Retry"
      - waitForAnimationToEnd
- runFlow:
    when:
      visible: "Retry"
    commands:
      - tapOn: "Retry"
      - waitForAnimationToEnd
- extendedWaitUntil:
    visible: "アイテムを追加"
    timeout: 30000

# 確認1: 起動時に ShoppingListPage が表示される（下部タブは無くなった）
- assertVisible: "アイテムを追加"
- takeScreenshot: screenshots/home_01_shopping_list_only

# 確認2: ヘッダー右上の設定アイコンタップで SettingPage 遷移
- tapOn:
    id: "app_settings_button"
- extendedWaitUntil:
    visible: "プロフィール"
    timeout: 5000
- takeScreenshot: screenshots/home_02_app_settings_pushed

# 確認3: 閉じる(×)で買い物リスト画面に戻る
- tapOn:
    id: "close"
- extendedWaitUntil:
    visible: "アイテムを追加"
    timeout: 5000
- takeScreenshot: screenshots/home_03_back_to_shopping_list
```

### 9. `maestro/flows/design_v2_list_settings.yaml` の文言アサート削除

L26-27 周辺の以下を削除:

```yaml
- assertVisible:
    text: "確定キーで保存されます"
```

### Maestro フロー他箇所への影響注意

21 個のフローが `tapOn: text: "設定.*"` で SettingPage に遷移している（grep 結果）。新しい `Icons.settings_outlined` IconButton は `tooltip: '設定'` を持つため Semantics label として公開され、多くのフローは引き続き動作する見込み。ただし、`home_page_test.yaml` の `point: "25%,93%"` のような座標タップは確実に破綻する → 上記書き換えで対処。

他フローは Maestro 実行時に問題が出たら個別に `tapOn: id: "app_settings_button"` への置換を検討（最小修正方針）。

---

## 動作確認

### 手動テスト（iOS Simulator）

`/maestro-flutter` ではなく、まず手動で UI 確認:

1. `flutter run` でアプリ起動
2. 起動直後に下部タブが消えていることを確認、買い物リスト画面のみ表示
3. ヘッダー右上に IconButton が 2 つ（`more_horiz` と歯車）並んでいることを確認
4. 歯車タップ → SettingPage が push 遷移、× で閉じる
5. `more_horiz` タップ → ShoppingListSettingPage モーダル表示
6. ShoppingListSettingPage のリスト名入力欄下に「確定キーで保存されます」が無いことを確認
7. FAB を 1 タップ → 空行が即追加される（編集モードで入る）
8. FAB を長押し → 3 メニュー（写真/URL/テキスト貼付）が上に展開、AI バッジが無いことを確認
9. メニュー外をタップで閉じる

### 自動テスト

```bash
# Flutter
dart run build_runner build       # 生成不要のはずだが念のため
flutter analyze                    # 静的解析エラーなしを確認
flutter test                       # 既存 widget test + frame_widgets_test.dart 修正後パス

# Maestro
/maestro-flutter home_page_test.yaml
/maestro-flutter design_v2_list_settings.yaml
/maestro-flutter add_and_check_item.yaml   # FAB タップ動作の回帰確認
/maestro-flutter settings_profile.yaml    # 設定遷移系の代表フロー
```

設定遷移系のMaestroフロー（21件）は順次実行して破綻が無いか確認、破綻したフローのみ `tapOn: id: "app_settings_button"` 置換で修正。

---

## チェックリスト

### 実装内容
- [ ] 変更対象ファイルごとに具体的なコード提案をコードブロックで記載している
- [ ] 既存コードのパターン・構成を確認し、同じパターンで実装している

### Flutter（lib/ に変更がある場合）
- [ ] コード生成: `dart run build_runner build` で生成ファイル更新
- [ ] 静的解析: `flutter analyze` エラーなし
- [ ] テスト: `flutter test` 全件パス
- [ ] iOS ビルド: `flutter build ios` 成功
- [ ] Android ビルド: `flutter build apk` 成功
- [ ] 新規・変更機能に対するテストが存在する（なければ新規作成）
- [ ] Maestro E2E: 該当する maestro flow があれば実行、なければ新規作成
- [ ] Entity命名: フィールド名が省略されていない
- [ ] DB操作: Firestore操作は `call` クラスのProvider経由
- [ ] 引数: 関数・コンストラクタの引数に `{required}` あり（timestamp等メタデータ除く）
- [ ] ref使い分け: build内は `ref.watch`、コールバック・操作は `ref.read`
- [ ] サブコレクションEntityに親ドキュメントIDフィールドあり（該当する場合）

### 共通
- [ ] エラーメッセージはそのまま表示（加工・プレフィックス除去なし）
