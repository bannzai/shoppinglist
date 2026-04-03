import 'package:flutter_test/flutter_test.dart';
import 'package:shoppinglist/entity/group_shopping_location.dart';

void main() {
  group('GroupShoppingLocation JSON', () {
    test('既存データ（lat/lng なし）からのデシリアライズで null になる', () {
      final json = {
        'id': 'loc1',
        'groupID': 'group1',
        'name': 'スーパー',
      };
      final location = GroupShoppingLocation.fromJson(json);
      expect(location.latitude, isNull);
      expect(location.longitude, isNull);
      expect(location.geofenceRadiusMeters, isNull);
      expect(location.name, 'スーパー');
    });

    test('lat/lng 付きデータのデシリアライズ', () {
      final json = {
        'id': 'loc1',
        'groupID': 'group1',
        'name': 'コンビニ',
        'latitude': 35.6812,
        'longitude': 139.7671,
        'geofenceRadiusMeters': 500.0,
      };
      final location = GroupShoppingLocation.fromJson(json);
      expect(location.latitude, 35.6812);
      expect(location.longitude, 139.7671);
      expect(location.geofenceRadiusMeters, 500.0);
    });

    test('lat/lng 付きデータのシリアライズ', () {
      const location = GroupShoppingLocation(
        id: 'loc1',
        groupID: 'group1',
        name: 'コンビニ',
        latitude: 35.6812,
        longitude: 139.7671,
        geofenceRadiusMeters: 500.0,
      );
      final json = location.toJson();
      expect(json['latitude'], 35.6812);
      expect(json['longitude'], 139.7671);
      expect(json['geofenceRadiusMeters'], 500.0);
    });

    test('defaultGeofenceRadiusMeters は 300m', () {
      expect(defaultGeofenceRadiusMeters, 300.0);
    });
  });
}
