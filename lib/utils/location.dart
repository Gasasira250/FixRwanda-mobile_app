import 'package:geolocator/geolocator.dart';

class DeviceLocation {
  const DeviceLocation({
    required this.latitude,
    required this.longitude,
    required this.label,
  });

  final double latitude;
  final double longitude;
  final String label;
}

Future<DeviceLocation> getCurrentLocation() async {
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw StateError('Location services are disabled.');
  }

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw StateError('Location permissions are denied.');
    }
  }
  if (permission == LocationPermission.deniedForever) {
    throw StateError('Location permissions are permanently denied.');
  }

  final position = await Geolocator.getCurrentPosition();
  return DeviceLocation(
    latitude: position.latitude,
    longitude: position.longitude,
    label:
        '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}',
  );
}
