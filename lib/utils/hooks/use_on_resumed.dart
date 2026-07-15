import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// アプリが foreground へ復帰した時([AppLifecycleState.resumed])に [onResumed] を実行する hook。
///
/// [useOnDisappear] が paused(background 移行)を検知するのと対になり、こちらは
/// 「別アプリから戻ってきた・ロック解除して戻った」タイミングを検知する。アプリ内タイマーを
/// 持たずにライフサイクルに沿って再評価したい処理(表示条件の再判定など)に使う。
///
/// [onResumed] は resumed のたびに呼ばれる。build のたびに最新の callback を参照するため、
/// closure が古い値を掴み続けることはない。
void useOnResumed(void Function() onResumed) {
  // 毎 build 最新の callback を保持する。useEffect を const [] で1度だけ張るため、
  // これが無いと初回 build の古い closure を掴み続けてしまう。
  final latestOnResumed = useRef(onResumed);
  latestOnResumed.value = onResumed;

  // 目的: アプリの foreground 復帰(resumed)で onResumed を呼び、表示条件などを再評価する。
  // 依存配列: const [] 。listener は Widget の生存期間中に1度だけ張れば良く、実際に呼ぶ処理は
  //   latestOnResumed 経由で常に最新を参照するため、依存に値を含めない。
  useEffect(() {
    final listener = AppLifecycleListener(
      onStateChange: (state) {
        if (state == AppLifecycleState.resumed) {
          latestOnResumed.value();
        }
      },
    );
    return listener.dispose;
  }, const []);
}
