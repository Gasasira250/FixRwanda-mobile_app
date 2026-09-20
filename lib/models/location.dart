class ServiceLocation {
  const ServiceLocation({
    required this.address,
    this.district = 'Kigali',
    this.sector,
    this.latitude,
    this.longitude,
  });

  final String address;
  final String district;
  final String? sector;
  final double? latitude;
  final double? longitude;

  String get label {
    final parts = <String>[
      address,
      if (sector != null && sector!.isNotEmpty) sector!,
      district,
    ];
    return parts.join(', ');
  }

  factory ServiceLocation.fromText(String value) {
    return ServiceLocation(address: value);
  }
}
