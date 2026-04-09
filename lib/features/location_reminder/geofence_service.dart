import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shoppinglist/entity/group_shopping_list.dart';
import 'package:shoppinglist/entity/group_shopping_location.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';

/// ジオフェンス監視サービス。
///
/// 登録済み店舗の座標と現在位置を比較し、閾値以内に入った場合にローカル通知を発行する。
/// geolocator の位置情報ストリームを使い、distanceFilter で更新頻度を制御する。
///
/// 通知の重複防止: 一度通知した店舗は、ジオフェンス半径の2倍まで離れるまで再通知しない。
class GeofenceService {
  /// ローカル通知プラグインのインスタンス。
  final FlutterLocalNotificationsPlugin notificationsPlugin;

  StreamSubscription<Position>? _positionSubscription;

  /// 監視対象の店舗一覧。groupID -> locations のマップ。
  Map<String, List<GroupShoppingLocation>> _monitoredLocations = {};

  /// 各店舗に紐づくアクティブな買い物リスト。locationID -> lists。
  Map<String, List<GroupShoppingList>> _activeShoppingLists = {};

  /// 既に通知済みの locationID。同じ店舗で連続通知しない。
  final Set<String> _notifiedLocationIDs = {};

  GeofenceService({required this.notificationsPlugin});

  /// 監視対象の店舗と買い物リストを更新する。
  void updateMonitoredData({
    required Map<String, List<GroupShoppingLocation>> locationsByGroupID,
    required Map<String, List<GroupShoppingList>> activeListsByLocationID,
  }) {
    _monitoredLocations = locationsByGroupID;
    _activeShoppingLists = activeListsByLocationID;
  }

  /// 位置情報ストリームの監視を開始する。
  void startMonitoring() {
    if (_positionSubscription != null) return;

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        distanceFilter: 100, // 100m移動ごとに更新（バッテリー節約）
      ),
    ).listen(_onPositionUpdate);

    debugPrint('[GeofenceService] 監視を開始しました');
  }

  /// 監視を停止する。
  void stopMonitoring() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _notifiedLocationIDs.clear();
    debugPrint('[GeofenceService] 監視を停止しました');
  }

  void _onPositionUpdate(Position position) {
    for (final locations in _monitoredLocations.values) {
      for (final location in locations) {
        if (location.latitude == null || location.longitude == null) continue;

        final distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          location.latitude!,
          location.longitude!,
        );

        final radius =
            location.geofenceRadiusMeters ?? defaultGeofenceRadiusMeters;

        if (distance <= radius && !_notifiedLocationIDs.contains(location.id)) {
          _triggerNotification(location: location);
          _notifiedLocationIDs.add(location.id);
        } else if (distance > radius * 2 &&
            _notifiedLocationIDs.contains(location.id)) {
          // ヒステリシス: 半径の2倍離れたら再通知可能にする
          _notifiedLocationIDs.remove(location.id);
        }
      }
    }
  }

  Future<void> _triggerNotification({
    required GroupShoppingLocation location,
  }) async {
    final lists = _activeShoppingLists[location.id] ?? [];
    if (lists.isEmpty) return;

    analytics.logEvent(
      name: 'geofence_notification_sent',
      parameters: {
        'listCount': lists.length.toString(),
      },
    );

    await notificationsPlugin.show(
      id: location.id.hashCode,
      title: '「${location.name}」の近くにいます',
      body: '買い物リストを確認しましょう',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'location_reminder',
          '位置情報リマインダー',
          channelDescription: '店舗の近くに来た時に買い物リストをリマインドします',
          importance: Importance.high,
          priority: Priority.high,
          visibility: NotificationVisibility.private,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  /// リソースを解放する。
  void dispose() {
    stopMonitoring();
  }
}
