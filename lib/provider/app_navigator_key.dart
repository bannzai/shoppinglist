import 'package:flutter/material.dart';

/// アプリ全体で共有する root Navigator key。
///
/// `BuildContext` を持たない通知ハンドラ等からも root Navigator の最前面へ route を積むために使う。
final appNavigatorKey = GlobalKey<NavigatorState>();
