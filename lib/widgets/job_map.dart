import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../theme/app_theme.dart';
import '../utils/launchers.dart';

const kigaliCenter = LatLng(-1.9441, 30.0619);

bool canEmbedGoogleMap() {
  if (const bool.fromEnvironment('FLUTTER_TEST')) return false;
  if (kIsWeb) {
    const key = String.fromEnvironment('MAPS_API_KEY');
    return key.isNotEmpty;
  }
  return defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
}

class JobMapCard extends StatelessWidget {
  const JobMapCard({
    super.key,
    required this.query,
    this.latitude,
    this.longitude,
  });

  final String query;
  final double? latitude;
  final double? longitude;

  @override
  Widget build(BuildContext context) {
    final target = latitude != null && longitude != null
        ? LatLng(latitude!, longitude!)
        : kigaliCenter;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (canEmbedGoogleMap())
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 160,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(target: target, zoom: 13),
                markers: {
                  Marker(
                    markerId: const MarkerId('job'),
                    position: target,
                    infoWindow: InfoWindow(title: query),
                  ),
                },
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
              ),
            ),
          )
        else
          Container(
            height: 88,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.line),
            ),
            child: Row(
              children: [
                const Icon(Icons.map_outlined, color: AppColors.primaryBlue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    query,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () async {
            final ok = await openMaps(
              query: query,
              latitude: latitude,
              longitude: longitude,
            );
            if (!context.mounted) return;
            await showLaunchResult(
              context,
              ok: ok,
              fallback: 'Open Google Maps for: $query',
            );
          },
          icon: const Icon(Icons.directions),
          label: const Text('Open in Maps'),
        ),
      ],
    );
  }
}
