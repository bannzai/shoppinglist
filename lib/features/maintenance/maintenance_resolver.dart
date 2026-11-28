import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:shoppinglist/features/maintenance/maintenance_state.dart';

/// アプリの一番上に置き、起動時に 1 回だけ状態を読んで、メンテナンス中ならメンテナンス中の画面だけを、
/// そうでなければ本来の画面 ([child]) を出す。前面に戻った時と時間の経過では読み直さないため、
/// 開いたままのアプリは起動し直すまで切り替わらない (service-maintenance-setup skill の SKILL.md「読む間隔と待つ上限」)。
/// `MaterialApp(builder: (context, child) => MaintenanceResolver(stateURL: ..., defaultMessage: ..., onOpenURL: ..., child: child!))`
/// の形で置く
class MaintenanceResolver extends StatefulWidget {
  /// 読む先と、状態に無い時の文、ボタンの開き方、本来の画面から作る
  const MaintenanceResolver({
    super.key,
    required this.stateURL,
    required this.defaultMessage,
    required this.onOpenURL,
    required this.child,
    this.client,
  });

  /// `<状態を返す Worker の URL>/<サービス名>`
  final Uri stateURL;

  /// 状態の message が null の時に出す、このサービスの既定の文
  final String defaultMessage;

  /// ボタンが押された時に URL を開く処理 (url_launcher の `launchUrl` 等)
  final void Function(Uri url) onOpenURL;

  /// メンテナンス中でない時に出す本来の画面。メンテナンス中と、状態を読み終わるまでの間は作らない
  final Widget child;

  /// 状態の取得に使う HTTP のクライアント。テストで差し替える
  final http.Client? client;

  @override
  State<MaintenanceResolver> createState() => _MaintenanceResolverState();
}

/// [MaintenanceResolver] が起動時に読んだ状態を持つ
class _MaintenanceResolverState extends State<MaintenanceResolver> {
  /// 起動時に読んだ状態。読み終わるまでは null (読めなかった時はメンテナンス中でない状態が入る)
  MaintenanceState? _maintenanceState;

  @override
  void initState() {
    super.initState();
    _read();
  }

  /// 状態を 1 回読み、画面に反映する
  Future<void> _read() async {
    final maintenanceState = await fetchMaintenanceState(
      widget.stateURL,
      client: widget.client,
    );
    if (!mounted) {
      return;
    }
    setState(() => _maintenanceState = maintenanceState);
  }

  // 検証用に壊した: 親が作り直されるたびに読み直す
  @override
  void didUpdateWidget(covariant MaintenanceResolver oldWidget) {
    super.didUpdateWidget(oldWidget);
    _read();
  }

  @override
  Widget build(BuildContext context) {
    final maintenanceState = _maintenanceState;
    // 読み終わるまで (応答を待つ上限の 2 秒まで) は、アプリの背景の色だけを出す。
    // 本来の画面を先に出すと、メンテナンス中の時に本来の画面が一瞬見えて処理も始まる。
    // 読み込み中の表示 (ぐるぐる) は、応答が 0.07〜0.22 秒で返る通常の起動で一瞬だけ出て消えるため出さない (SKILL.md「読む間隔と待つ上限」)
    if (maintenanceState == null) {
      return ColoredBox(color: Theme.of(context).scaffoldBackgroundColor);
    }
    // 検証用に壊した: メンテナンス中でも本来の画面を出す
    return widget.child;
    return MaintenanceScreen(
      message: maintenanceState.message ?? widget.defaultMessage,
      button: maintenanceState.button,
      onOpenURL: widget.onOpenURL,
    );
  }
}

/// メンテナンス中の画面。[button] が null の時はボタンを出さない
class MaintenanceScreen extends StatelessWidget {
  /// 出す文と、ボタン、ボタンの開き方から作る
  const MaintenanceScreen({
    super.key,
    required this.message,
    required this.button,
    required this.onOpenURL,
  });

  /// 利用者に見せる文
  final String message;

  /// 画面に出すボタン。null ならボタンを出さない
  final MaintenanceButton? button;

  /// ボタンが押された時に URL を開く処理
  final void Function(Uri url) onOpenURL;

  @override
  Widget build(BuildContext context) {
    final button = this.button;
    final theme = Theme.of(context);
    return Material(
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Center(
          // 運営者が設定する文には長さの上限が無いため、長い文でも末尾とボタンまで届くようにスクロールさせる
          child: SingleChildScrollView(
            // 画面の端の余白は、Material の画面の端の余白として一般的な 24 にした
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (button != null) ...[
                  // 文とボタンの間も、画面の端の余白と同じ 24 にそろえた
                  const SizedBox(height: 24),
                  // 再試行の画面 (RetryPage) のボタンと同じく、アクセントの色 (colorScheme.primary) で横幅いっぱいに塗る
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        // 縦の余白は RetryPage のボタンにそろえた
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => onOpenURL(button.url),
                      child: Text(button.label),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
