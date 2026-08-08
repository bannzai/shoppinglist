/// 背景にアプリ画面を敷いた状態でモーダルシートを開く、スクリーンショット撮影用のホスト。
///
/// `lib/features/previews/screens/` のシート preview は背景が無地のため、そのまま撮ると
/// 提出画像にプレースホルダーだけが写る。撮影では実際の利用状況と同じく、
/// 買い物リストの上にシートが乗った状態を見せる。
library;

import 'package:flutter/material.dart';

/// 背景 Widget を表示し、初回フレーム後に `openSheet` のシートを開く。
class ScreenshotSheetHost extends StatefulWidget {
  /// シートの背後に敷くアプリ画面。
  final Widget background;

  /// 開くシート。`showModalBottomSheet` 系の関数をそのまま渡す。
  final Future<void> Function({required BuildContext context}) openSheet;

  const ScreenshotSheetHost({
    super.key,
    required this.background,
    required this.openSheet,
  });

  @override
  State<ScreenshotSheetHost> createState() => _ScreenshotSheetHostState();
}

class _ScreenshotSheetHostState extends State<ScreenshotSheetHost> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      widget.openSheet(context: context);
    });
  }

  @override
  Widget build(BuildContext context) => widget.background;
}
