enum VerificationStatus {
  pending,
  verified,
  rejected,
  expired,
}

class Professional {
  final String id;
  final String name;
  final String imageUrl;
  final String category;
  final String description;
  final String location;
  final int startingPrice;
  final double rating;
  final int completedJobs;
  final bool phoneVerified;
  final bool idVerified;
  final bool certificateVerified;
  final VerificationStatus verificationStatus;
  final VerificationStatus phoneVerificationStatus;
  final VerificationStatus idVerificationStatus;
  final VerificationStatus tvetVerificationStatus;
  final String? userId;
  final String? sector;

  const Professional({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.category,
    required this.description,
    required this.location,
    required this.startingPrice,
    required this.rating,
    required this.completedJobs,
    required this.phoneVerified,
    required this.idVerified,
    required this.certificateVerified,
    required this.verificationStatus,
    this.phoneVerificationStatus = VerificationStatus.pending,
    this.idVerificationStatus = VerificationStatus.pending,
    this.tvetVerificationStatus = VerificationStatus.pending,
    this.userId,
    this.sector,
  });

  bool get isBookable => verificationStatus == VerificationStatus.verified;

  Professional copyWith({
    String? id,
    String? name,
    String? imageUrl,
    String? category,
    String? description,
    String? location,
    int? startingPrice,
    double? rating,
    int? completedJobs,
    bool? phoneVerified,
    bool? idVerified,
    bool? certificateVerified,
    VerificationStatus? verificationStatus,
    VerificationStatus? phoneVerificationStatus,
    VerificationStatus? idVerificationStatus,
    VerificationStatus? tvetVerificationStatus,
    String? userId,
    String? sector,
  }) {
    return Professional(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      description: description ?? this.description,
      location: location ?? this.location,
      startingPrice: startingPrice ?? this.startingPrice,
      rating: rating ?? this.rating,
      completedJobs: completedJobs ?? this.completedJobs,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      idVerified: idVerified ?? this.idVerified,
      certificateVerified: certificateVerified ?? this.certificateVerified,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      phoneVerificationStatus:
          phoneVerificationStatus ?? this.phoneVerificationStatus,
      idVerificationStatus: idVerificationStatus ?? this.idVerificationStatus,
      tvetVerificationStatus:
          tvetVerificationStatus ?? this.tvetVerificationStatus,
      userId: userId ?? this.userId,
      sector: sector ?? this.sector,
    );
  }
}
