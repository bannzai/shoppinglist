# Issue #297: ShoppingListSettingPage design v2 視覚差分 5 件の手戻り対応

## Context

PR #300 で `ShoppingListSettingPage` を design v2 SSOT に準拠させる骨格リファクタを行い merge 済み。ただし Web preview (`design_handoff_shoppinglist/preview/screens-list-settings.jsx`) と並べた目視比較が未実施で、issue #297 のコメント 2 で **5 件の視覚差分が残存** していることが判明した。

本プランは構造差分 (§4: autoNotify Switch / リストの操作セクション) を **本 issue では触らず**、視覚差分 §3-1 〜 §3-5 のみを Web SSOT に揃えることがゴール。3 状態 (通常 / 招待コード dialog / 削除確認 dialog) を iPhone 16 Plus Simulator preview ↔ Web SSOT で目視 PASS させ、`documents/design-handoff-v2-screenshot-comparison.md` の Dark 🟡 を ✅ に昇格できる状態を作る。

## 採用方針 (ユーザー確認済み)

- 王冠アイコン: `Icons.workspace_premium` (Material 標準。pubspec 変更不要)
- Dashed border: **CustomPainter 自前実装** (`dotted_border` package を導入せず、`lib/components/` 配下に共通 widget として実装)
- Maestro 範囲: 招待コード dialog flow を `design_v2_list_settings.yaml` に追記 (削除 dialog 拡張はしない)

## 変更対象ファイル

| 種別 | パス | 概要 |
|---|---|---|
| 修正 | `lib/components/frame/app_pill.dart` | `AppPillVariant.dangerSolid` 追加 |
| 修正 | `lib/components/frame/app_cell.dart` | detail Text の `fontSize: 13` 明示 |
| **新規** | `lib/components/dashed_border_box.dart` | CustomPainter ベース dashed RRect box widget |
| 修正 | `lib/features/shopping_list_setting/page.dart` | 削除ボタン inline 化 (radius 14)、アップグレード icon を `workspace_premium` |
| 修正 | `lib/features/shopping_list_setting/delete_confirm_dialog.dart` | 「削除」ボタンを `AppPillVariant.dangerSolid` に切替 |
| 修正 | `lib/features/shopping_list_setting/invitation_code_dialog.dart` | コード枠の `Container.border` を `DashedBorderBox` に置換 |
| 修正 | `maestro/flows/design_v2_list_settings.yaml` | 招待コード dialog タップ + assertVisible flow 追記 |
| 修正 | `documents/design-handoff-v2-screenshot-comparison.md` | ShoppingListSettingPage 単独の 3 状態比較セクション追加 |

## 実装コード提案

### 1. `lib/components/frame/app_pill.dart` — `dangerSolid` variant 追加

```dart
/// Pill 形状ボタンの色バリアント。
/// `design_handoff_shopping_list/source/frame.jsx#Pill` の variant に対応する。
enum AppPillVariant {
  neutral,
  accent,
  soft,
  ghost,

  /// 破壊的操作 (淡背景)。dangerSoft + danger 文字。
  danger,

  /// 破壊的操作 (確定アクション)。danger 塗りつぶし + 白文字。
  /// 削除確認 dialog 等の primary action 用。
  dangerSolid,
}
```

`build` 内の switch にも 1 case 追加:

```dart
final (bg, fg, side) = switch (variant) {
  // ... 既存 case ...
  AppPillVariant.dangerSolid => (
      neutral.danger,
      Colors.white,
      BorderSide.none,
    ),
};
```

### 2. `lib/components/frame/app_cell.dart` — detail fontSize 13

現在の `detail` 描画箇所 (L98-103 付近):

```dart
Text(
  detail!,
  style: textTheme.bodySmall?.copyWith(
    color: neutral.ink3,
    fontSize: 13,
  ),
),
```

Web SSOT (`screens-list-settings.jsx`) の Cell detail は `fontSize: 13`。`bodySmall` (12px) で 1px 不足していたため明示的に上書きする。

### 3. `lib/components/dashed_border_box.dart` — 新規 CustomPainter widget

`dotted_border` package 不採用のため自前実装。SSOT は `border: 1px dashed ${t.divider}` 単一仕様なので、汎用化しすぎず必要最低限の prop に絞る。

```dart
import 'package:flutter/material.dart';

/// 角丸長方形に破線枠を描画する Box。
/// `design_handoff_shopping_list/source/screens-list-settings.jsx#InviteCodeDialog`
/// の招待コード表示枠 (`border: 1px dashed ${t.divider}`) を再現する。
class DashedBorderBox extends StatelessWidget {
  /// 中央配置する子。
  final Widget child;

  /// 角丸半径。Web SSOT の `radius 14` を既定値とする。
  final double borderRadius;

  /// 破線の色。`tokens.neutral.divider` を渡す想定。
  final Color color;

  /// 破線の太さ。Web SSOT の `1px` を既定値とする。
  final double strokeWidth;

  /// 破線パターン [線, 空白] を交互に描画する。
  final List<double> dashPattern;

  const DashedBorderBox({
    super.key,
    required this.child,
    required this.color,
    this.borderRadius = 14,
    this.strokeWidth = 1,
    this.dashPattern = const [4, 3],
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRRectPainter(
        color: color,
        strokeWidth: strokeWidth,
        radius: borderRadius,
        dashPattern: dashPattern,
      ),
      child: child,
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;
  final List<double> dashPattern;

  _DashedRRectPainter({
    required this.color,
    required this.strokeWidth,
    required this.radius,
    required this.dashPattern,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    final dashed = _buildDashedPath(path, dashPattern);
    canvas.drawPath(
      dashed,
      Paint()
        ..color = color
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke,
    );
  }

  /// PathMetric を辿りながら dashPattern に沿って線分／空白を切り出す。
  Path _buildDashedPath(Path source, List<double> pattern) {
    final result = Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0;
      bool draw = true;
      int index = 0;
      while (distance < metric.length) {
        final len = pattern[index % pattern.length];
        if (draw) {
          result.addPath(
            metric.extractPath(distance, distance + len),
            Offset.zero,
          );
        }
        distance += len;
        draw = !draw;
        index++;
      }
    }
    return result;
  }

  @override
  bool shouldRepaint(_DashedRRectPainter old) =>
      old.color != color ||
      old.strokeWidth != strokeWidth ||
      old.radius != radius ||
      old.dashPattern != dashPattern;
}
```

### 4. `lib/features/shopping_list_setting/page.dart`

#### 4-1. 「このリストを削除」ボタンを radius 14 化 (§3-2)

L221 付近の `AppPill(variant: AppPillVariant.danger, large: true, expanded: true)` を捨て、SSOT の `borderRadius: 14, padding 14x16, fontSize 15, fontWeight 600, icon size 16, gap 8` に揃えた inline 実装に置換:

```dart
// SSOT: screens-list-settings.jsx L55-61
// background: dangerSoft / color: danger / radius: 14 / padding: 14px 16px
SizedBox(
  width: double.infinity,
  child: Material(
    color: neutral.dangerSoft,
    borderRadius: BorderRadius.circular(14),
    child: InkWell(
      onTap: () => _onTapDelete(context, ref),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, size: 16, color: neutral.danger),
            const SizedBox(width: 8),
            Text(
              'このリストを削除',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: neutral.danger,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ),
  ),
),
```

#### 4-2. アップグレード Pill 王冠アイコン (§3-5)

L424 付近の `Icons.star_outline` を:

```dart
AppPill(
  label: 'アップグレード',
  icon: Icons.workspace_premium, // 王冠ベースの Material アイコン
  variant: AppPillVariant.soft,
  onPressed: () { ... showPaywall(context: context); },
),
```

### 5. `lib/features/shopping_list_setting/delete_confirm_dialog.dart` — solid 化 (§3-1)

L80 付近の AppPill の variant を切り替えるだけ。サイズ・expanded は維持:

```dart
AppPill(
  label: '削除',
  variant: AppPillVariant.dangerSolid, // ← danger (淡) から solid に変更
  large: true,
  expanded: true,
  onPressed: () {
    Navigator.of(context).pop();
    onConfirm();
  },
),
```

### 6. `lib/features/shopping_list_setting/invitation_code_dialog.dart` — dashed border (§3-3)

L60-79 の `Container(decoration: BoxDecoration(border: Border.all(...)))` を `DashedBorderBox` でラップ:

```dart
DashedBorderBox(
  color: neutral.divider,
  borderRadius: 14,
  child: Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    decoration: BoxDecoration(
      color: neutral.surface2,
      borderRadius: BorderRadius.circular(14),
    ),
    child: SelectableText(
      invitationCode,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontFamily: 'monospace',
        fontSize: 36,
        fontWeight: FontWeight.w600,
        letterSpacing: 8,
      ),
    ),
  ),
),
```

### 7. `maestro/flows/design_v2_list_settings.yaml` — 招待コード dialog flow 追記

既存の削除 dialog セクション (L69-82 付近) と同じパターンで append:

```yaml
- tapOn:
    text: "グループに招待コードを送る"
    optional: true
- assertVisible:
    text: "招待コード"
    optional: true
- assertVisible:
    text: "有効期限"
    optional: true
- tapOn:
    text: "閉じる"
    optional: true
```

### 8. `documents/design-handoff-v2-screenshot-comparison.md` — 比較セクション追加

`## 2026-05-19 更新 — Issue #297 視覚差分対応` の見出しで以下を追記:

- ShoppingListSettingPage 通常状態: iOS Light/Dark, Android Light/Dark, Web Light/Dark の 6 枚を `tmp/handover-297/` に保存して並列比較
- 削除確認 dialog: 同 6 枚
- 招待コード dialog: 同 6 枚
- 残課題: §4 構造差分 (autoNotify Switch / リストの操作) は SSOT 拡張 issue (別 issue) で対応

## 検証

### 1. コード品質チェック (Flutter)

```bash
dart run build_runner build --delete-conflicting-outputs
flutter analyze            # No issues found
flutter test               # 145+ pass (新規 widget があれば +1)
flutter build ios --no-codesign --debug
flutter build apk --debug
```

### 2. 単体テスト追加

`test/components/dashed_border_box_test.dart` を新規作成し、`DashedBorderBox` が CustomPaint を子としてレンダリングし、与えた `color` / `borderRadius` を CustomPainter に渡していることを smoke レベルで検証する (描画ピクセル比較は不要、`testWidgets` で `find.byType(CustomPaint)` の確認に留める)。

`AppPillVariant.dangerSolid` の追加に伴い、`test/components/frame/app_pill_test.dart` (もしくは新規) に variant ごとの bg / fg 色を `tester.widget<Material>` で取り出して検証するケースを追加。

### 3. preview による目視比較 (iPhone 16 Plus 固定)

```bash
# 並列で Python サーバー + Simulator
cd design_handoff_shoppinglist/preview
python3 -m http.server 8765 &
cd -

xcrun simctl boot "iPhone 16 Plus" 2>&1 || true
open -a Simulator
flutter run -t lib/features/previews/main_preview.dart -d "iPhone 16 Plus"
# → PreviewsPage → "ShoppingListSettingPage" タップ

# mobile-mcp でスクショ取得
# 1. 通常状態
# 2. 「グループに招待コードを送る」タップ → 招待コード dialog
# 3. dialog 閉じる → 「このリストを削除」タップ → 削除確認 dialog
```

Web SSOT スクショ (`tmp/handover-297/0[1-3]_web_ssot_*.png`) と並べて pixel 比較。issue コメントの §5 チェックリスト 7 項目を埋める。

### 4. Maestro E2E

```bash
maestro test maestro/flows/design_v2_list_settings.yaml
```

招待コード dialog flow が追加分含めて pass することを確認。

### 5. Firebase Functions (今回スコープ外だが招待コード dialog 表示で `createGroupInvitation` を呼ぶため smoke のみ)

```bash
cd firebase/functions
npm run lint && npm run build && npm test
```

## チェックリスト

### 実装内容
- [ ] 変更対象ファイルごとに具体的なコード提案をコードブロックで記載している
- [ ] 既存コードのパターン・構成を確認し、同じパターンで実装している (AppPill variant 追加 / Material+InkWell inline 構造 / CustomPainter widget)

### Flutter (lib/ に変更あり)
- [ ] コード生成: `dart run build_runner build --delete-conflicting-outputs` で生成ファイル更新
- [ ] 静的解析: `flutter analyze` エラーなし
- [ ] テスト: `flutter test` 全件パス (`DashedBorderBox` / `AppPillVariant.dangerSolid` の新規テスト含む)
- [ ] iOS ビルド: `flutter build ios --no-codesign --debug` 成功
- [ ] Android ビルド: `flutter build apk --debug` 成功
- [ ] 新規 widget (DashedBorderBox) に widget test あり
- [ ] AppPillVariant.dangerSolid に variant 別テスト追加
- [ ] Maestro E2E: `maestro/flows/design_v2_list_settings.yaml` に招待コード dialog flow 追加 + 実行 pass
- [ ] Entity 命名: フィールド名が省略されていない (本 PR で entity は触らないので該当箇所なし)
- [ ] DB 操作: Firestore 操作は `call` クラスの Provider 経由 (`CreateGroupInvitation.call` 既存利用)
- [ ] 引数: 関数・コンストラクタの引数に `{required}` あり (新規 `DashedBorderBox` の `child` / `color` も `required`)
- [ ] ref 使い分け: build 内は `ref.watch`、コールバック・操作は `ref.read` (削除 dialog 開閉部は既存パターン踏襲)
- [ ] サブコレクション Entity の親 ID フィールド: 本 PR で entity 変更なし
- [ ] 3 状態 (通常 / 招待 / 削除) を iPhone 16 Plus Simulator preview で Web SSOT と並べて目視 PASS
- [ ] Light モード 7 項目 (issue §5 リスト) PASS
- [ ] Dark モード 7 項目 (issue §5 リスト) PASS
- [ ] `documents/design-handoff-v2-screenshot-comparison.md` に ShoppingListSettingPage 比較セクション追加
- [ ] `documents/design-handoff-v2-verification.md` の Dark 🟡 を ✅ に昇格

### Firebase (firebase/ に変更なし)
- [ ] 本 PR で functions 変更なし。動作確認のため `cd firebase/functions && npm run lint && npm run build && npm test` のみ smoke 実行

### 共通
- [ ] エラーメッセージはそのまま表示 (招待コード dialog のエラー表示部に変更なし、既存パターン維持)
