import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shoppinglist/components/spotlight/spotlight_view.dart';
import 'package:shoppinglist/entity/group_shopping_list.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/provider/app_navigator_key.dart';
import 'package:shoppinglist/provider/string_shared_preferences.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/hooks/use_on_resumed.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';
import 'package:shoppinglist/utils/shared_preferences/keys.dart';

part 'create_list_spotlight.g.dart';

/// リスト追加スポットライトを表示すべきかを判定する純粋関数(Issue #494)。
///
/// 引数はすべてローカル時刻の DateTime として扱う(日付比較のため呼び出し側で `toLocal()` 済みを渡す)。
///
/// - cond1(日次ナッジ): 最後のリスト作成日のローカル日付が、今日より前 = 「日付が変わった」
/// - cond2(チェック後の再訪ナッジ): 最後にアイテムをチェックしてから1時間以上経過
/// - shownForToday: 最終表示日時が今日と同じローカル日付 = 「今日」の機会に対して表示済み
/// - shownForCheckOccasion: 最終表示が最後のチェック以降 = 「そのチェックセッション」に対して表示済み
///
/// return は `(cond1 && !shownForToday) || (cond2 && !shownForCheckOccasion)`。
/// 意図: 1回の表示で「今日」と「現在のチェック機会」の両方を消費する
/// (Issue 条件3「1,2 でいずれも showcase を出してない時」)。翌日リストが未作成なら cond1 で再び出る
/// (日次ナッジ)。再チェック後1時間経過で cond2 が再び出る。
bool shouldShowCreateListSpotlight({
  required DateTime now,
  required DateTime? lastShoppingListCreatedDateTime,
  required DateTime? lastShoppingListItemCheckedDateTime,
  required DateTime? spotlightLastShownDateTime,
}) {
  final lastCreated = lastShoppingListCreatedDateTime;
  final lastChecked = lastShoppingListItemCheckedDateTime;
  final lastShown = spotlightLastShownDateTime;

  final cond1 = lastCreated != null && _isLocalDateBefore(lastCreated, now);
  final cond2 =
      lastChecked != null &&
      now.difference(lastChecked) >= const Duration(hours: 1);
  final shownForToday = lastShown != null && _isSameLocalDate(lastShown, now);
  final shownForCheckOccasion =
      lastShown != null &&
      lastChecked != null &&
      !lastShown.isBefore(lastChecked);

  return (cond1 && !shownForToday) || (cond2 && !shownForCheckOccasion);
}

/// [a] のローカル日付が [b] のローカル日付より前か(時刻は無視)。
bool _isLocalDateBefore(DateTime a, DateTime b) =>
    DateTime(a.year, a.month, a.day).isBefore(DateTime(b.year, b.month, b.day));

/// [a] と [b] が同じローカル日付か(時刻は無視)。
bool _isSameLocalDate(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// 開発者オプションからスポットライトを強制表示するための in-memory フラグ。
///
/// true の間、[CreateListSpotlightHost] は表示条件を無視してスポットライトを表示する。
/// 強制表示時は SharedPreferences の履歴を書かない(本番状態を汚さない)。表示後に false へ戻す。
/// 開発者オプションを閉じて買い物リスト画面へ戻るまで状態を保持するため keepAlive にする。
@Riverpod(keepAlive: true)
class DebugForceCreateListSpotlight extends _$DebugForceCreateListSpotlight {
  @override
  bool build() => false;

  /// 強制表示を ON にする。
  void show() => state = true;

  /// 強制表示を OFF に戻す。
  void reset() => state = false;
}

/// リスト追加ボタン([targetKey] が指す `CreateListMenuButton`)へスポットライトを出す機能ホスト。
///
/// build は [SizedBox.shrink] を返し、Overlay へのスポットライト挿入を命令的に管理する
/// (route push はシートの pop 乗っ取りになるため使わない。`toast_overlay.dart` と同じく
/// [appNavigatorKey] 経由で root Overlay へ挿入する)。
///
/// 評価タイミング:
/// - 初回にアイテム一覧が到達した(null→非null)後の post-frame で1回
/// - foreground 復帰時([useOnResumed])
/// - 開発者オプションの強制表示フラグが立っている間(前面へ戻るまで短時間ポーリング)
///
/// 連続 rebuild では評価しない(上記の限定タイミングのみ)。表示条件は [shouldShowCreateListSpotlight]。
class CreateListSpotlightHost extends HookConsumerWidget {
  /// 対象グループID。analytics のパラメータに使う。
  final String groupID;

  /// 買い物リスト一覧(createdDateTime 降順)。先頭が最後に作成されたリスト。
  final List<GroupShoppingList> shoppingLists;

  /// 表示中リストのアイテム一覧(チェック済み含む全件)。未取得(ロード中)は null。
  /// null→非null の初回到達を評価開始の合図に使う。
  final List<GroupShoppingListItem>? shoppingListItems;

  /// スポットライトの切り抜き対象(リスト追加ボタン)を指す GlobalKey。
  final GlobalKey targetKey;

  const CreateListSpotlightHost({
    super.key,
    required this.groupID,
    required this.shoppingLists,
    required this.shoppingListItems,
    required this.targetKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Provider は build 内で watch してローカル変数にキャプチャする(riverpod-rules)。
    final debugForce = ref.watch(debugForceCreateListSpotlightProvider);
    final debugForceNotifier = ref.watch(
      debugForceCreateListSpotlightProvider.notifier,
    );
    final spotlightPrefsKey = StringKey.createListSpotlightLastShownDateTime;
    final lastShownString = ref.watch(
      stringSharedPreferencesProvider(key: spotlightPrefsKey),
    );
    final spotlightPrefsNotifier = ref.watch(
      stringSharedPreferencesProvider(key: spotlightPrefsKey).notifier,
    );

    // build 時点の props を closure へ束ねる(コールバック内で ref を触らない)。
    final shoppingLists = this.shoppingLists;
    final shoppingListItems = this.shoppingListItems;
    final targetKey = this.targetKey;
    final groupID = this.groupID;

    // 表示中の OverlayEntry。二重 insert 防止と unmount 時の remove に使う。
    final entryRef = useRef<OverlayEntry?>(null);

    // ルート遷移完了待ちの post-frame 再試行を1本に絞るためのフラグ(多重スケジュール防止)。
    final retryScheduledRef = useRef(false);

    void removeEntry() {
      entryRef.value?.remove();
      entryRef.value?.dispose();
      entryRef.value = null;
    }

    // スポットライトを表示できるなら表示する。表示した(または既に表示中の)なら true を返す。
    // [force] が true なら条件を無視して表示し、履歴は書かず強制フラグを OFF に戻す。
    bool attemptShow({required bool force}) {
      // 既に表示中なら二重 insert しない。
      if (entryRef.value != null) {
        return true;
      }
      // route 自体が無い(まだツリーに乗っていない)時だけ即座に諦める。
      final route = ModalRoute.of(context);
      if (route == null) {
        return false;
      }
      // 「current でない(シート・設定画面などが上にある)」と「遷移が未完了」を1つの保留分岐に統合する。
      // どちらも今は測定・表示すべきでないが、評価をここで捨てず post-frame 再試行で保留する。
      //
      // - !route.isCurrent: シートや設定画面が上に乗っている間。この Host は上のルートが pop されても
      //   再 build されないため、ここで false を返して評価を捨てると、上のルートを閉じた後に評価する
      //   機会が失われる(設定画面を開いたまま foreground 復帰 → 閉じても取りこぼす。codex レビュー指摘)。
      //   current に戻るまで保留し、閉じた後の再試行で拾う。
      // - !_isRouteSettled(route): 遷移アニメーション中。isCurrent は上のルートが pop された「瞬間」に
      //   true になるが、Cupertino の pop 遷移中は下層ページ(この画面)がまだ横スライド中で、
      //   renderObject.localToGlobal(下記)がスライド中の誤った座標(ずれ幅 ≈ 画面幅/3)を返す。
      //   animation が completed かつ secondaryAnimation が dismissed になる(= 遷移完全終了)まで待つ。
      //
      // 再試行はフレームが生成された時だけ発火する軽量チェック(addPostFrameCallback は自らフレームを
      // 予約しないため busy-loop しない)。current かつ settled の評価に到達して発火するか、unmount で
      // context.mounted ガードに弾かれて自然に止まる。強制表示・通常(初回/resumed)いずれの経路も
      // この共通箇所を通るため一律で効く。
      if (!route.isCurrent || !_isRouteSettled(route)) {
        if (!retryScheduledRef.value) {
          retryScheduledRef.value = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            retryScheduledRef.value = false;
            // unmount 後に発火しても何もしないよう mounted をガードする。
            if (context.mounted) {
              attemptShow(force: force);
            }
          });
        }
        return false;
      }
      // 対象ボタンの RenderBox が取れない/未レイアウトなら表示しない。
      final renderObject = targetKey.currentContext?.findRenderObject();
      if (renderObject is! RenderBox || !renderObject.hasSize) {
        return false;
      }

      final now = DateTime.now();
      if (!force) {
        final shouldShow = shouldShowCreateListSpotlight(
          now: now,
          lastShoppingListCreatedDateTime:
              shoppingLists.firstOrNull?.createdDateTime?.toLocal(),
          lastShoppingListItemCheckedDateTime:
              _latestCheckedDateTime(shoppingListItems)?.toLocal(),
          spotlightLastShownDateTime:
              lastShownString != null
                  ? DateTime.tryParse(lastShownString)?.toLocal()
                  : null,
        );
        if (!shouldShow) {
          return false;
        }
      }

      final overlay = appNavigatorKey.currentState?.overlay;
      if (overlay == null) {
        return false;
      }

      // 切り抜き対象の global Rect を算出する。
      final targetRect =
          renderObject.localToGlobal(Offset.zero) & renderObject.size;

      analytics.logEvent(
        name: 'show_create_list_spotlight',
        parameters: {'groupID': groupID},
      );

      final entry = OverlayEntry(
        builder:
            (context) => SpotlightView(
              targetRect: targetRect,
              targetPadding: const EdgeInsets.all(8),
              shape: const SpotlightRoundedRect(cornerRadius: 12),
              content: const CreateListSpotlightBubble(),
              onDismiss: () {
                analytics.logEvent(
                  name: 'tap_dismiss_create_list_spotlight',
                  parameters: {'groupID': groupID},
                );
                removeEntry();
              },
            ),
      );
      entryRef.value = entry;
      overlay.insert(entry);

      // 表示した時点で記録する(dismiss 時ではない。アプリ kill でも再表示しないため)。
      // 強制表示は本番状態を汚さないよう履歴を書かず、フラグを戻すだけにする。
      if (force) {
        debugForceNotifier.reset();
      } else {
        spotlightPrefsNotifier.set(value: now.toIso8601String());
      }
      return true;
    }

    // 初回のアイテム一覧到達(null→非null)後に、post-frame で1回だけ評価する。
    // itemsLoaded を依存にすることで、ロード完了時の1回のみ評価し連続 rebuild では評価しない。
    final itemsLoaded = shoppingListItems != null;
    useEffect(() {
      if (itemsLoaded) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // リスト切替(親が ValueKey を変え element ごと破棄)や画面遷移で Host 破棄直後に
          // 発火し得るため、無効な context で ModalRoute.of / targetKey 参照が走らないよう
          // mounted をガードする。
          if (context.mounted) {
            attemptShow(force: false);
          }
        });
      }
      return null;
    }, [itemsLoaded]);

    // foreground 復帰時に条件を再評価する(チェックから1時間経過などをアプリ復帰で拾う)。
    useOnResumed(() {
      attemptShow(force: false);
    });

    // 開発者オプションの強制表示。フラグが立っている間、買い物リスト画面が前面に来て
    // 表示できるまで短時間ポーリングする(開発者オプションを閉じて戻った後に確実に出すため。
    // 前面へ戻っても route pop ではこの Widget は rebuild されないため、ポーリングで拾う)。
    // 表示できたら timer を止め、attemptShow がフラグを OFF に戻す。effect の cleanup でも
    // 必ず cancel されるため、未表示のまま残っても Widget 破棄時に停止する。
    useEffect(() {
      if (!debugForce) {
        return null;
      }
      final timer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
        if (attemptShow(force: true)) {
          timer.cancel();
        }
      });
      return timer.cancel;
    }, [debugForce]);

    // unmount 時に Overlay から確実に取り除く。
    useEffect(() {
      return removeEntry;
    }, const []);

    return const SizedBox.shrink();
  }
}

/// ルートの遷移(push/pop アニメーション)が完全に終わっているか。
///
/// - `animation` が completed: この画面自身の遷移(push の入場など)が終わっている。
/// - `secondaryAnimation` が dismissed: 上に乗っていたルートの pop 遷移で、この画面が横スライド
///   させられている最中でない(元位置に戻り切っている)。
///
/// 遷移中に `RenderBox.localToGlobal` で測ると、スライド中の座標を拾って切り抜き位置がずれるため、
/// 両方が終端に達していることを表示前のガードに使う。
bool _isRouteSettled(ModalRoute<dynamic> route) {
  final animation = route.animation;
  final secondaryAnimation = route.secondaryAnimation;
  final primarySettled =
      animation == null || animation.status == AnimationStatus.completed;
  final secondarySettled =
      secondaryAnimation == null ||
      secondaryAnimation.status == AnimationStatus.dismissed;
  return primarySettled && secondarySettled;
}

/// アイテム一覧の `lastCheckedDateTime` の最大値(未チェックのみ/空/null は null)。
DateTime? _latestCheckedDateTime(List<GroupShoppingListItem>? items) {
  if (items == null) {
    return null;
  }
  DateTime? latest;
  for (final item in items) {
    final checked = item.lastCheckedDateTime;
    if (checked == null) {
      continue;
    }
    if (latest == null || checked.isAfter(latest)) {
      latest = checked;
    }
  }
  return latest;
}

/// スポットライトの説明バブル。リスト追加ボタンの役割と閉じ方を伝える。
/// 文言マッチに依存したテストを避けるため、コンポーネントクラスとして切り出す(find.byType で検証)。
class CreateListSpotlightBubble extends StatelessWidget {
  const CreateListSpotlightBubble({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTheme;
    return Material(
      color: tokens.neutral.card,
      elevation: 8,
      borderRadius: BorderRadius.circular(AppThemeExtension.radiusCard),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long, size: 20, color: tokens.accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '新しい買い物リストはここから追加できます',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: tokens.neutral.ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '日付ごとのリストを作ったり、今のリストを複製したりできます。',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: tokens.neutral.ink2),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'タップして閉じる',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: tokens.neutral.ink3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
