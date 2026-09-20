import 'dart:math';

import '../models/professional.dart';

const kigaliDistricts = ['Gasabo', 'Kicukiro', 'Nyarugenge'];

class GeoPoint {
  const GeoPoint(this.lat, this.lng);
  final double lat;
  final double lng;
}

class BroadcastRouter {
  BroadcastRouter._();

  static const initialOfferCount = 1;
  static const rerouteOfferCount = 3;

  static const centroids = <String, GeoPoint>{
    'Gasabo': GeoPoint(-1.932, 30.099),
    'Kicukiro': GeoPoint(-1.978, 30.104),
    'Nyarugenge': GeoPoint(-1.944, 30.061),
  };

  static String districtForSector(String sector) {
    return switch (sector) {
      'Kacyiru' || 'Kimironko' || 'Remera' => 'Gasabo',
      'Gikondo' => 'Kicukiro',
      _ => 'Nyarugenge',
    };
  }

  static GeoPoint pointForDistrict(String district) {
    return centroids[district] ?? const GeoPoint(-1.932, 30.099);
  }

  static double distanceKm(GeoPoint a, GeoPoint b) {
    const earth = 6371.0;
    double toRad(double value) => value * pi / 180;
    final dLat = toRad(b.lat - a.lat);
    final dLng = toRad(b.lng - a.lng);
    final h = sin(dLat / 2) * sin(dLat / 2) +
        cos(toRad(a.lat)) * cos(toRad(b.lat)) * sin(dLng / 2) * sin(dLng / 2);
    return earth * 2 * asin(min(1, sqrt(h)));
  }

  static List<Professional> rankVerified({
    required List<Professional> professionals,
    required String district,
    required String category,
    required GeoPoint origin,
  }) {
    final ranked = professionals
        .where(
          (professional) =>
              professional.isBookable &&
              professional.category == category &&
              professional.district == district,
        )
        .toList()
      ..sort((a, b) {
        final da = distanceKm(origin, GeoPoint(a.latitude, a.longitude));
        final db = distanceKm(origin, GeoPoint(b.latitude, b.longitude));
        return da.compareTo(db);
      });
    return ranked;
  }

  static List<String> nextOfferIds({
    required List<Professional> ranked,
    required List<String> alreadyOffered,
    required int take,
  }) {
    return ranked
        .where((professional) => !alreadyOffered.contains(professional.id))
        .take(take)
        .map((professional) => professional.id)
        .toList();
  }
}
