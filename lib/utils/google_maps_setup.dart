import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

/// Enables Android Hybrid Composition so Google Maps renders on modern emulators
/// instead of a blank / gray surface.
Future<void> configureGoogleMapsAndroid() async {
  if (kIsWeb) return;
  if (defaultTargetPlatform != TargetPlatform.android) return;

  final implementation = GoogleMapsFlutterPlatform.instance;
  if (implementation is! GoogleMapsFlutterAndroid) return;

  implementation.useAndroidViewSurface = true;
  try {
    await implementation.initializeWithRenderer(AndroidMapRenderer.latest);
  } catch (_) {
    // Emulators without Play services can skip renderer init.
  }
}
