import 'package:hooks_riverpod/hooks_riverpod.dart';

/// アプリ全体で共有する ProviderContainer。
/// `main()` で生成して `UncontrolledProviderScope` に渡し、同じインスタンスを
/// Widget ツリーと「BuildContext / WidgetRef を持たない場所」（FCM ハンドラ等）の
/// 双方から参照する。これにより `showGlobalToast` のような ref/context 不要の
/// グローバル API から Provider を読み書きできる。
///
/// `final` ではなく `late` なのは、Widget テストでテスト用コンテナを差し替えられる
/// ようにするため（本番では `main()` で一度だけ代入する）。
late ProviderContainer appProviderContainer;
