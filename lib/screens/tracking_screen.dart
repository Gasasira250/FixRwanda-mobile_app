import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import '../models/booking.dart';
import '../theme/app_theme.dart';
import '../utils/location.dart';
import '../widgets/job_map.dart';

class InAppTrackingScreen extends StatefulWidget {
  const InAppTrackingScreen({
    super.key,
    required this.providerName,
    this.providerInitialLocation = kigaliCenter,
    this.status,
    this.jobLocation,
    this.locateUser = true,
  });

  factory InAppTrackingScreen.fromBooking(Booking booking) {
    return InAppTrackingScreen(
      providerName: booking.professionalName,
      providerInitialLocation: _locationFromText(booking.location),
      status: booking.status,
      jobLocation: booking.location,
    );
  }

  final String providerName;
  final LatLng providerInitialLocation;
  final BookingStatus? status;
  final String? jobLocation;
  final bool locateUser;

  @override
  State<InAppTrackingScreen> createState() => _InAppTrackingScreenState();
}

LatLng _locationFromText(String location) {
  final match = RegExp(
    r'(-?\d+(?:\.\d+)?)\s*,\s*(-?\d+(?:\.\d+)?)',
  ).firstMatch(location);
  if (match == null) return kigaliCenter;
  return LatLng(
    double.parse(match.group(1)!),
    double.parse(match.group(2)!),
  );
}

class _InAppTrackingScreenState extends State<InAppTrackingScreen> {
  GoogleMapController? _mapController;

  LatLng _userLocation = const LatLng(-1.9500, 30.0588);
  Set<Marker> _markers = {};
  bool _isLoadingLocation = true;

  String get _statusLine {
    switch (widget.status) {
      case BookingStatus.confirmed:
        return 'Confirmed • Technician is preparing to leave';
      case BookingStatus.arrived:
        return 'Arrived at your location';
      case BookingStatus.inProgress:
        return 'Work in progress';
      case BookingStatus.completed:
        return 'Job completed';
      case BookingStatus.cancelled:
        return 'Booking cancelled';
      case BookingStatus.enRoute:
      case null:
        return 'On the way • Estimated arrival: 15 mins';
    }
  }

  Color get _statusColor {
    switch (widget.status) {
      case BookingStatus.cancelled:
        return AppColors.danger;
      case BookingStatus.completed:
        return AppColors.kigaliGreen;
      case BookingStatus.arrived:
      case BookingStatus.inProgress:
        return AppColors.warning;
      case BookingStatus.confirmed:
      case BookingStatus.enRoute:
      case null:
        return AppColors.kigaliGreen;
    }
  }

  @override
  void initState() {
    super.initState();
    final mapsImplementation = GoogleMapsFlutterPlatform.instance;
    if (mapsImplementation is GoogleMapsFlutterAndroid) {
      mapsImplementation.useAndroidViewSurface = true;
    }
    _updateMapMarkers();
    if (widget.locateUser) {
      _getUserCurrentLocation();
    } else {
      _isLoadingLocation = false;
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _getUserCurrentLocation() async {
    try {
      final position = await getCurrentLocation().timeout(
        const Duration(seconds: 8),
      );
      if (!mounted) return;
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
        _updateMapMarkers();
      });
      await _recenter();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingLocation = false;
        _updateMapMarkers();
      });
    }
  }

  LatLng get _providerLocation {
    final seed = widget.providerName.hashCode;
    final dLat = ((seed % 80) - 40) / 10000;
    final dLng = (((seed ~/ 80) % 80) - 40) / 10000;
    return LatLng(
      widget.providerInitialLocation.latitude + dLat,
      widget.providerInitialLocation.longitude + dLng,
    );
  }

  void _updateMapMarkers() {
    _markers = {
      Marker(
        markerId: const MarkerId('user_location'),
        position: _userLocation,
        infoWindow: const InfoWindow(title: 'Your Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
      Marker(
        markerId: const MarkerId('provider_location'),
        position: _providerLocation,
        infoWindow: InfoWindow(
          title: widget.providerName,
          snippet: widget.jobLocation ?? 'Service technician',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    };
  }

  Future<void> _recenter() async {
    final controller = _mapController;
    if (controller == null) return;
    await controller.animateCamera(
      CameraUpdate.newLatLngZoom(_userLocation, 14.5),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tracking ${widget.providerName}'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          if (canEmbedGoogleMap())
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: widget.providerInitialLocation,
                zoom: 14,
              ),
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              onMapCreated: (controller) {
                _mapController = controller;
              },
            )
          else
            ColoredBox(
              color: const Color(0xFFE8EEF4),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.map_outlined, size: 56, color: AppColors.primaryBlue),
                    const SizedBox(height: 12),
                    Text(
                      widget.jobLocation ?? 'Kigali, Rwanda',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Live tracking',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ),
          if (_isLoadingLocation)
            const ColoredBox(
              color: Color(0x42000000),
              child: Center(child: CircularProgressIndicator()),
            ),
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primarySoft,
                        child: const Icon(Icons.person, color: AppColors.primaryBlue),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.providerName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              _statusLine,
                              style: TextStyle(
                                color: _statusColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.center_focus_strong, size: 18),
                      label: const Text('Recenter Map'),
                      onPressed: () async {
                        if (_mapController == null) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Centering on your location'),
                            ),
                          );
                          return;
                        }
                        await _recenter();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
