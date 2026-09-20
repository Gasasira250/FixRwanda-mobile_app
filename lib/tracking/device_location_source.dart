import 'package:geolocator/geolocator.dart';

import 'location_source.dart';

class DeviceLocationSource implements LocationSource {
  const DeviceLocationSource();

  @override
  Future<({double latitude, double longitude})> read({
    required double fallbackLatitude,
    required double fallbackLongitude,
  }) async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        return (
          latitude: fallbackLatitude,
          longitude: fallbackLongitude,
        );
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return (
          latitude: fallbackLatitude,
          longitude: fallbackLongitude,
        );
      }
      final position = await Geolocator.getCurrentPosition();
      return (latitude: position.latitude, longitude: position.longitude);
    } catch (_) {
      return (
        latitude: fallbackLatitude,
        longitude: fallbackLongitude,
      );
    }
  }
}
