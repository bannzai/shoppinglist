import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Widget が画面から消える時に [onDisappear] を1回実行する hook。
///
/// 「画面から消える」とは次の2つを指す:
/// - Widget が tree から外れる(dispose) … 戻る操作・別画面遷移・モーダルを閉じる
/// - アプリがバックグラウンドへ移る([AppLifecycleState.paused]) … ホームに戻る・別アプリへ切替
///
/// 「保存ボタンを押さなくても」離脱時に入力値を永続化する用途を想定している。
///
/// 重要: [onDisappear] は Widget の unmount 後(dispose 時)にも呼ばれるため、その中で
/// `ref` / `BuildContext` を参照してはいけない(hooks_riverpod では unmount 後の `ref`
/// 使用は StateError を投げる)。保存に必要な処理は呼び出し側の build 時にキャプチャして
/// closure に閉じ込めること
/// (例: `final update = ref.watch(...Provider); useOnDisappear(() => update.call(...));`)。
void useOnDisappear(void Function() onDisappear) {
  // 毎 build 最新の callback を保持する。useEffect を const [] で1度だけ張るため、
  // これが無いと初回 build の古い closure(古い category 等)を掴み続けてしまう。
  final latestOnDisappear = useRef(onDisappear);
  latestOnDisappear.value = onDisappear;

  // 目的: 画面離脱(dispose の cleanup) と アプリの background 移行(paused) の両方で
  //   onDisappear を呼び、未保存の入力を永続化する。
  // 依存配列: const [] 。listener と cleanup は Widget の生存期間中に1度だけ張れば良く、
  //   実際に呼ぶ処理は latestOnDisappear 経由で常に最新を参照するため、依存に値を含めない。
  useEffect(() {
    final listener = AppLifecycleListener(
      onStateChange: (state) {
        if (state == AppLifecycleState.paused) {
          latestOnDisappear.value();
        }
      },
    );
    return () {
      latestOnDisappear.value();
      listener.dispose();
    };
  }, const []);
}
