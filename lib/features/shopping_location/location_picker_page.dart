import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/primitives/app_pill.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';

/// 地図上で店舗の位置を選択するページ。
///
/// 中央のピンを固定し、地図をパン/ズームして位置を決定する。
/// 選択確定時に `({double latitude, double longitude})` を返す。
class LocationPickerPage extends HookConsumerWidget {
  /// 既存の座標がある場合に初期表示位置として使用する。
  final double? initialLatitude;
  final double? initialLongitude;

  const LocationPickerPage({
    super.key,
    required this.initialLatitude,
    required this.initialLongitude,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // デフォルト: 東京駅
    const defaultLatLng = LatLng(35.6812, 139.7671);

    final selectedLatLng = useState<LatLng>(
      initialLatitude != null && initialLongitude != null
          ? LatLng(initialLatitude!, initialLongitude!)
          : defaultLatLng,
    );
    final address = useState<String>('');
    final isLoadingAddress = useState(false);
    final mapController = useState<GoogleMapController?>(null);

    // 初回: 現在地を取得して地図を移動（既存座標がない場合のみ）
    useEffect(() {
      if (initialLatitude != null) {
        return null;
      }
      () async {
        try {
          var permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
          }
          final position = await Geolocator.getCurrentPosition();
          selectedLatLng.value = LatLng(position.latitude, position.longitude);
          mapController.value?.animateCamera(
            CameraUpdate.newLatLng(selectedLatLng.value),
          );
        } catch (_) {
          // 位置情報取得失敗時はデフォルト位置のまま
        }
      }();
      return null;
    }, []);

    /// カメラ移動完了時に逆ジオコーディングで住所を取得する。
    Future<void> onCameraIdle() async {
      isLoadingAddress.value = true;
      try {
        final placemarks = await placemarkFromCoordinates(
          selectedLatLng.value.latitude,
          selectedLatLng.value.longitude,
        );
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          address.value = [
            p.administrativeArea,
            p.locality,
            p.subLocality,
            p.thoroughfare,
            p.subThoroughfare,
          ].where((s) => s != null && s.isNotEmpty).join(' ');
        }
      } catch (_) {
        address.value = '';
      } finally {
        isLoadingAddress.value = false;
      }
    }

    final tokens = context.appTheme;
    final neutral = tokens.neutral;

    return Scaffold(
      backgroundColor: neutral.surface,
      appBar: AppBar(
        title: const Text('場所を地図で選択'),
        backgroundColor: neutral.surface,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: selectedLatLng.value,
              zoom: 16,
            ),
            onMapCreated: (controller) => mapController.value = controller,
            onCameraMove: (position) {
              selectedLatLng.value = position.target;
            },
            onCameraIdle: onCameraIdle,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
          ),
          // 中央ピン（accent カラー、drop shadow 付き）
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 36),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(Icons.location_pin, size: 42, color: tokens.accent),
              ),
            ),
          ),
          // 下部の住所表示カード
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: neutral.card,
                borderRadius: BorderRadius.circular(18),
                boxShadow: tokens.cardShadow,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (isLoadingAddress.value)
                    LinearProgressIndicator(
                      backgroundColor: neutral.divider2,
                      valueColor: AlwaysStoppedAnimation<Color>(tokens.accent),
                    )
                  else if (address.value.isNotEmpty)
                    Text(
                      address.value,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: neutral.ink,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 12),
                  AppPill(
                      label: 'この場所を設定',
                      variant: AppPillVariant.accent,
                      large: true,
                      expanded: true,
                      onPressed: () {
                        analytics.logEvent(
                          name: 'tap_confirm_map_location',
                          parameters: {
                            'hasAddress': address.value.isNotEmpty.toString(),
                          },
                        );
                        Navigator.pop(context, (
                          latitude: selectedLatLng.value.latitude,
                          longitude: selectedLatLng.value.longitude,
                          address: address.value,
                        ));
                      },
                      icon: null),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
