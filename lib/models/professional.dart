enum VerificationStatus { pending, verified, rejected, expired }

class ServiceCategory {
  const ServiceCategory({
    required this.id,
    required this.name,
    required this.icon,
  });

  final String id;
  final String name;
  final String icon;

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String? ?? '🛠️',
    );
  }
}

class Professional {
  const Professional({
    required this.id,
    required this.name,
    required this.trade,
    required this.location,
    required this.rating,
    required this.jobsCompleted,
    required this.tvetVerified,
    required this.idVerified,
    required this.verificationStatus,
    required this.services,
    required this.serviceFeeRwf,
    this.about =
        'Trusted local professional available for home and business work across Rwanda.',
  });

  final String id;
  final String name;
  final String trade;
  final String location;
  final double rating;
  final int jobsCompleted;
  final bool tvetVerified;
  final bool idVerified;
  final VerificationStatus verificationStatus;
  final List<String> services;
  final int serviceFeeRwf;
  final String about;

  bool get isVerifiedProfessional =>
      verificationStatus == VerificationStatus.verified &&
      (tvetVerified || idVerified);

  String get verificationLabel {
    switch (verificationStatus) {
      case VerificationStatus.verified:
        return 'Verified professional';
      case VerificationStatus.pending:
        return 'Verification pending';
      case VerificationStatus.rejected:
        return 'Verification rejected';
      case VerificationStatus.expired:
        return 'Verification expired';
    }
  }

  factory Professional.fromJson(Map<String, dynamic> json) {
    return Professional(
      id: json['id'] as String,
      name: json['name'] as String,
      trade: json['trade'] as String,
      location: json['location'] as String,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      jobsCompleted: json['jobsCompleted'] as int? ?? 0,
      tvetVerified: json['tvetVerified'] as bool? ?? false,
      idVerified: json['idVerified'] as bool? ?? false,
      verificationStatus: VerificationStatus.values.firstWhere(
        (value) => value.name == json['verificationStatus'],
        orElse: () => VerificationStatus.pending,
      ),
      services: (json['services'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      serviceFeeRwf: json['serviceFeeRwf'] as int? ?? 0,
      about: json['about'] as String? ??
          'Trusted local professional available for home and business work across Rwanda.',
    );
  }
}

class Customer {
  const Customer({
    required this.id,
    required this.name,
    required this.identifier,
    this.role = 'customer',
    this.token,
  });

  final String id;
  final String name;
  final String identifier;
  final String role;
  final String? token;

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as String,
      name: json['name'] as String,
      identifier: (json['identifier'] ?? json['email'] ?? json['phone'] ?? '')
          .toString(),
      role: json['role'] as String? ?? 'customer',
      token: json['token'] as String?,
    );
  }

  Customer copyWith({
    String? name,
    String? identifier,
    String? token,
  }) {
    return Customer(
      id: id,
      name: name ?? this.name,
      identifier: identifier ?? this.identifier,
      role: role,
      token: token ?? this.token,
    );
  }
}
