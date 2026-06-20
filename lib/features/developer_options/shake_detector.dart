import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// シェイクジェスチャーを検出してコールバックを発火するウィジェット。
/// kDebugMode のみで動作する。リリースビルドでは child をそのまま返す。
class ShakeDetectorWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback onShake;

  const ShakeDetectorWrapper({
    super.key,
    required this.child,
    required this.onShake,
  });

  @override
  State<ShakeDetectorWrapper> createState() => _ShakeDetectorWrapperState();
}

class _ShakeDetectorWrapperState extends State<ShakeDetectorWrapper> {
  StreamSubscription<AccelerometerEvent>? _subscription;
  DateTime _lastShakeTime = DateTime.fromMillisecondsSinceEpoch(0);

  // 3軸合成加速度の閾値（m/s²）
  static const double _shakeThreshold = 30.0;

  // 連続検出防止のデバウンス時間
  static const Duration _debounceDuration = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      _subscription = accelerometerEventStream().listen(_onAccelerometerEvent);
    }
  }

  void _onAccelerometerEvent(AccelerometerEvent event) {
    final magnitude = sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );
    if (magnitude > _shakeThreshold) {
      final now = DateTime.now();
      if (now.difference(_lastShakeTime) > _debounceDuration) {
        _lastShakeTime = now;
        widget.onShake();
      }
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
