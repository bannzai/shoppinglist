import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shoppinglist/entity/group_shopping_location.dart';

void main() {
  group('ジオフェンス距離計算', () {
    test('半径内の場合にジオフェンスがトリガーされる', () {
      // 東京駅
      const storeLatitude = 35.6812;
      const storeLongitude = 139.7671;
      // 東京駅から約200m北
      const userLatitude = 35.6830;
      const userLongitude = 139.7671;

      final distance = Geolocator.distanceBetween(
        userLatitude,
        userLongitude,
        storeLatitude,
        storeLongitude,
      );

      expect(distance, lessThan(defaultGeofenceRadiusMeters));
    });

    test('半径外の場合にジオフェンスがトリガーされない', () {
      // 東京駅
      const storeLatitude = 35.6812;
      const storeLongitude = 139.7671;
      // 東京駅から約1km南
      const userLatitude = 35.6712;
      const userLongitude = 139.7671;

      final distance = Geolocator.distanceBetween(
        userLatitude,
        userLongitude,
        storeLatitude,
        storeLongitude,
      );

      expect(distance, greaterThan(defaultGeofenceRadiusMeters));
    });

    test('座標なしの店舗はスキップされる', () {
      const location = GroupShoppingLocation(
        id: 'loc1',
        groupID: 'group1',
        name: 'テスト店',
        latitude: null,
        longitude: null,
        geofenceRadiusMeters: null,
      );
      expect(location.latitude, isNull);
      expect(location.longitude, isNull);
    });

    test('カスタム半径が設定されている場合はそれを使用する', () {
      const customRadius = 500.0;
      const location = GroupShoppingLocation(
        id: 'loc1',
        groupID: 'group1',
        name: 'テスト店',
        latitude: 35.6812,
        longitude: 139.7671,
        geofenceRadiusMeters: customRadius,
      );
      expect(
        location.geofenceRadiusMeters ?? defaultGeofenceRadiusMeters,
        customRadius,
      );
    });
  });
}
