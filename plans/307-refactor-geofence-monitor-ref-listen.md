# #307 geofenceMonitor を ref.listen ベースに書き直す

## 背景・目的

Issue #307「間違った Riverpod の使い方を正す」の調査の結果、`lib/` 全体で**観点1（副作用を Provider にしている）＋観点2（`ref.watch` を副作用の点火に使っている）に純粋に該当するのは `geofenceMonitor` の1件のみ**だった（他の初期化系は既に `main.dart` で関数化済み、call クラス Provider は override 実態あり）。

`geofenceMonitor` は「ただの関数」には戻せない（複数の状態 Provider をリアクティブに合成して監視を開始/停止しているため）。そこで **Provider は「監視に必要なデータの計算（read）」に徹し、副作用（監視の開始/停止）は購読側の `ref.listen` で起こす** Riverpod 公式 DO の形に書き直す。

### 現状の問題コード

`lib/provider/geofence.dart:51-100`
```dart
@Riverpod()
void geofenceMonitor(Ref ref) {        // ① void = 値を公開しない副作用専用 Provider（観点1）
  final isPremium =
      ref.watch(customerInfoProvider).asData?.value.isPremium ?? false;
  final isEnabled = ref.watch(locationReminderEnabledProvider);
  final service = ref.watch(geofenceServiceProvider);
  final groups = ref.watch(userGroupsProvider).asData?.value ?? [];

  if (!isPremium || !isEnabled || groups.isEmpty) {
    service.stopMonitoring();          // ② build 内で副作用（公式 DON'T）
    return;
  }
  // ...locationsByGroupID / activeListsByLocationID を構築...
  service.updateMonitoredData(...);    // ② build 内で副作用
  service.startMonitoring();           // ② build 内で副作用
}
```

`lib/app.dart:34`
```dart
ref.watch(geofenceMonitorProvider);    // ③ 戻り値を使わず watch（観点2）
```

### 公式根拠
- Riverpod DO/DON'T「Provider の build で副作用を行うな（Provider は read を表す）」: https://github.com/rrousselgit/riverpod/blob/master/website/docs/root/do_dont.mdx
- 副作用はリアクティブに起こしたい → 公式の推奨は購読側の `ref.listen`

## 変更方針

1. `geofenceMonitor`(void) を **`geofenceMonitoringPlan`(監視データを計算して返す純粋 Provider)** に置換する。build 内では `GeofenceService` を一切触らない（副作用ゼロ）。
2. 副作用（`updateMonitoredData` / `startMonitoring` / `stopMonitoring`）は **`app.dart` の `ref.listen(geofenceMonitoringPlanProvider, ..., fireImmediately: true)`** で実行する。`fireImmediately: true` により初回構築時の Plan でもコールバックが発火し、**現状の `ref.watch` と同じ初回監視開始挙動を保つ**。
3. `GeofenceService` クラス（`geofence_service.dart`）は**無変更**。`updateMonitoredData`(冪等) / `startMonitoring`(二重起動ガード有) / `stopMonitoring` の API はそのまま使う。

### 挙動の同一性（重要）
- 監視開始/停止の判定条件（premium && enabled && データ有）は完全に同一。
- `ref.listen` の `previous/next` で毎回 `update + start`（または `stop`）を呼ぶが、`updateMonitoredData` は冪等・`startMonitoring` は二重起動ガード有のため、**現状の「依存変化のたびに build で副作用」と等価**。
- `GeofenceMonitoringPlan` に `==` は実装しない（毎回発火しても冪等で安全。現状 watch と同じ）。停止状態のみ `const stopped` で同一参照とし無駄発火を抑える。

## 実装

### 1. `lib/provider/geofence.dart` — 置換

`geofenceMonitor`(line 47-100) を以下に置き換える。`GeofenceService` への `ref.watch` は削除する（service の取得は app.dart 側へ移動）。

```dart
/// ジオフェンス監視の計算結果（不変値）。
///
/// この値の算出は純粋（副作用なし）。実際の監視開始/停止は購読側（app.dart）の
/// ref.listen で起こす。Riverpod 公式 DO/DON'T「build で副作用を行うな」に従うための分離。
class GeofenceMonitoringPlan {
  /// 監視を行うべきか。premium かつトグル有効かつ対象グループがある場合のみ true。
  final bool shouldMonitor;

  /// 監視対象の店舗一覧。groupID -> locations。
  final Map<String, List<GroupShoppingLocation>> locationsByGroupID;

  /// 各店舗に紐づくアクティブな買い物リスト。locationID -> lists。
  final Map<String, List<GroupShoppingList>> activeListsByLocationID;

  const GeofenceMonitoringPlan({
    required this.shouldMonitor,
    required this.locationsByGroupID,
    required this.activeListsByLocationID,
  });

  /// 監視停止状態を表す定数。停止が連続する間は同一参照となり ref.listen の無駄発火を抑える。
  static const stopped = GeofenceMonitoringPlan(
    shouldMonitor: false,
    locationsByGroupID: {},
    activeListsByLocationID: {},
  );
}

/// ジオフェンス監視に必要なデータを計算するプロバイダー。
///
/// premium状態・トグル状態・監視対象の店舗データ・アクティブリストを監視（ref.watch）し、
/// 監視すべきか否かと監視対象データを [GeofenceMonitoringPlan] として返す。
/// 副作用（GeofenceService の開始/停止）はここでは行わず、購読側の ref.listen で起こす。
@Riverpod()
GeofenceMonitoringPlan geofenceMonitoringPlan(Ref ref) {
  final isPremium =
      ref.watch(customerInfoProvider).asData?.value.isPremium ?? false;
  final isEnabled = ref.watch(locationReminderEnabledProvider);
  final groups = ref.watch(userGroupsProvider).asData?.value ?? [];

  if (!isPremium || !isEnabled || groups.isEmpty) {
    return GeofenceMonitoringPlan.stopped;
  }

  // 全グループの位置情報とアクティブリストを収集（現状ロジックそのまま）
  final locationsByGroupID = <String, List<GroupShoppingLocation>>{};
  final activeListsByLocationID = <String, List<GroupShoppingList>>{};

  for (final group in groups) {
    final locationsWithCoords = (ref
                .watch(shoppingLocationsProvider(groupID: group.id))
                .asData
                ?.value ??
            [])
        .where((l) => l.latitude != null && l.longitude != null)
        .toList();
    if (locationsWithCoords.isNotEmpty) {
      locationsByGroupID[group.id] = locationsWithCoords;
    }

    for (final list in (ref
                .watch(shoppingListsProvider(
                    groupID: group.id, isPremium: isPremium))
                .asData
                ?.value ??
            [])
        .where((l) => l.status == GroupShoppingListStatus.active)) {
      if (list.shoppingLocationID != null) {
        activeListsByLocationID
            .putIfAbsent(list.shoppingLocationID!, () => [])
            .add(list);
      }
    }
  }

  return GeofenceMonitoringPlan(
    shouldMonitor: true,
    locationsByGroupID: locationsByGroupID,
    activeListsByLocationID: activeListsByLocationID,
  );
}
```

- `geofenceServiceProvider`(line 37-45) は**そのまま残す**（app.dart から参照する）。
- `LocationReminderEnabled`(line 18-35) も無変更。

### 2. `lib/app.dart` — watch を listen に置換 + import 追加

import 追加（現状 re-export 経由で参照しているため明示 import を足して堅牢化）:
```dart
import 'package:shoppinglist/provider/geofence.dart';
```

`build` 冒頭（line 33-34）を置き換え:
```dart
  @override
  Widget build(BuildContext context) {
    // ジオフェンス監視: 監視プランの変化に追従して開始/停止する。
    // Provider は計算に徹し、副作用（service の開始/停止）はここで起こす（Riverpod 公式 DO）。
    // fireImmediately: true で初回プランにも反応し、従来の ref.watch と同じ初回挙動を保つ。
    ref.listen(
      geofenceMonitoringPlanProvider,
      (previous, next) {
        final service = ref.read(geofenceServiceProvider);
        if (!next.shouldMonitor) {
          service.stopMonitoring();
          return;
        }
        service.updateMonitoredData(
          locationsByGroupID: next.locationsByGroupID,
          activeListsByLocationID: next.activeListsByLocationID,
        );
        service.startMonitoring();
      },
      fireImmediately: true,
    );

    // appUserProvider は UserDatabaseResolver スコープ外では AsyncError になるが、
    // .asData?.value で安全に null フォールバックし、shu（朱）が使われる
    final accent = resolveAccentPreset(
        ref.watch(appUserProvider).asData?.value.themeColorHex);
    // ...以降は無変更...
```

### 3. コード生成

`geofence.g.dart` を再生成（`geofenceMonitorProvider` が消え `geofenceMonitoringPlanProvider` が生成される）:
```sh
dart run build_runner build --delete-conflicting-outputs
```

### 4. テスト — `test/provider/geofence_monitoring_plan_test.dart`（新規）

副作用を排して純粋計算 Provider にしたことで、`ProviderContainer` で直接 read してテストできる。`ProviderScope(overrides:)` で依存を差し替えて条件分岐を検証する。

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/provider/geofence.dart';
import 'package:shoppinglist/provider/user_groups.dart';
import 'package:shoppinglist/provider/shared_preferences.dart';
// customerInfo / shoppingLocations / shoppingLists の override に必要な import

void main() {
  group('geofenceMonitoringPlan', () {
    test('premium でない場合は shouldMonitor=false (stopped)', () {
      final container = ProviderContainer(overrides: [
        // customerInfo を empty stream（= isPremium false 相当）に override
        // locationReminderEnabled は true 相当、userGroups は1件 にしても
        // premium false なら stopped になることを確認
      ]);
      addTearDown(container.dispose);
      final plan = container.read(geofenceMonitoringPlanProvider);
      expect(plan.shouldMonitor, isFalse);
      expect(plan.locationsByGroupID, isEmpty);
    });

    test('トグル無効の場合は shouldMonitor=false', () { /* locationReminderEnabled=false */ });
    test('グループが空の場合は shouldMonitor=false', () { /* userGroups=[] */ });
    test('premium かつ有効かつ座標付き店舗がある場合は shouldMonitor=true でデータが入る', () {
      // customerInfo の isPremium=true モックは既存 premium テスト
      // (test/group_category_page_premium_test.dart 等) のパターンを踏襲する。
      // 困難な場合はその旨を報告する（プロジェクト方針）。
    });
  });
}
```

> 備考: `locationReminderEnabled` は `sharedPreferencesProvider.overrideWith(...)` で getBool 値を制御するのが簡潔。`customerInfo` の premium=true モックが困難な場合は、premium=false 系3ケースを確実に通し、premium=true パスはユーザーに報告する。

## 影響範囲

| ファイル | 変更 |
|---|---|
| `lib/provider/geofence.dart` | `geofenceMonitor`(void) → `geofenceMonitoringPlan`(値) に置換。`geofenceServiceProvider`/`LocationReminderEnabled` は無変更 |
| `lib/app.dart` | `ref.watch(geofenceMonitorProvider)` → `ref.listen(geofenceMonitoringPlanProvider, ..., fireImmediately: true)`、geofence import 追加 |
| `lib/provider/geofence.g.dart` | build_runner 再生成 |
| `test/provider/geofence_monitoring_plan_test.dart` | 新規 |
| `lib/features/location_reminder/geofence_service.dart` | 無変更 |

- `geofenceMonitor` の参照は app.dart:34 の1箇所のみ（grep 確認済み）。他への波及なし。
- 設定トグル(`LocationReminderEnabled.setEnabled`)は無変更のため、E2E `premium_location_reminder.yaml` / `location_reminder_non_premium.yaml` は影響を受けない見込み。

---

## チェックリスト

### 実装内容
- [ ] 変更対象ファイルごとに具体的なコード提案をコードブロックで記載している
- [ ] 既存コードのパターン・構成を確認し、同じパターンで実装している

### Flutter（lib/ に変更がある場合）
- [ ] コード生成: `dart run build_runner build --delete-conflicting-outputs` で生成ファイル更新
- [ ] 静的解析: `flutter analyze` エラーなし
- [ ] テスト: `flutter test` 全件パス
- [ ] iOS ビルド: `flutter build ios` 成功
- [ ] Android ビルド: `flutter build apk` 成功
- [ ] 新規・変更機能に対するテストが存在する（`geofence_monitoring_plan_test.dart` 新規作成）
- [ ] Maestro E2E: `premium_location_reminder.yaml` / `location_reminder_non_premium.yaml` を実行して退行なし確認
- [ ] Entity命名: フィールド名が省略されていない
- [ ] DB操作: Firestore操作は `call` クラスのProvider経由（本変更では DB 操作なし）
- [ ] 引数: 関数・コンストラクタの引数に `{required}` あり
- [ ] ref使い分け: build内は `ref.watch`、コールバック・操作は `ref.read`（app.dart の listen 内は `ref.read(geofenceServiceProvider)`）
- [ ] サブコレクションEntityに親ドキュメントIDフィールドあり（該当なし）

### 共通
- [ ] エラーメッセージはそのまま表示（加工・プレフィックス除去なし）

### 動作確認（手動）
- [ ] premium + トグル ON で位置情報権限ダイアログが出て監視が開始される（現状と同じ）
- [ ] トグル OFF で監視が停止する
- [ ] premium 解除で監視が停止する
- [ ] アプリ再起動後もトグル状態に応じて監視状態が復元される
