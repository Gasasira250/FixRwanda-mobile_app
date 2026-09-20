import 'provider_verification.dart';

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
  final VerificationStatus iremboVerificationStatus;
  final VerificationStatus livenessVerificationStatus;
  final bool kigaliGreenBadge;
  final String? nidaNumber;
  final String? iremboCertUrl;
  final String? tradeCertUrl;
  final TradeCertificateKind? tradeCertKind;
  final String? livenessSelfieRef;
  final String? smileJobId;
  final String? userId;
  final String? sector;
  final String district;
  final double latitude;
  final double longitude;

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
    this.iremboVerificationStatus = VerificationStatus.pending,
    this.livenessVerificationStatus = VerificationStatus.pending,
    this.kigaliGreenBadge = false,
    this.nidaNumber,
    this.iremboCertUrl,
    this.tradeCertUrl,
    this.tradeCertKind,
    this.livenessSelfieRef,
    this.smileJobId,
    this.userId,
    this.sector,
    this.district = 'Gasabo',
    this.latitude = -1.932,
    this.longitude = 30.099,
  });

  bool get isBookable =>
      verificationStatus == VerificationStatus.verified && kigaliGreenBadge;

  ProviderVerification get pipeline => ProviderVerification(
        providerId: id,
        overallStatus: verificationStatus,
        kigaliGreenBadge: kigaliGreenBadge,
        nidaStatus: idVerificationStatus,
        livenessStatus: livenessVerificationStatus,
        iremboStatus: iremboVerificationStatus,
        tradeStatus: tvetVerificationStatus,
        nidaNumber: nidaNumber,
        iremboCertUrl: iremboCertUrl,
        tradeCertUrl: tradeCertUrl,
        tradeKind: tradeCertKind,
        livenessSelfieRef: livenessSelfieRef,
        smileJobId: smileJobId,
      );

  Map<String, dynamic> get verificationFlag => pipeline.toJson();

  Professional applyPipeline(ProviderVerification next) {
    return copyWith(
      verificationStatus: next.overallStatus,
      kigaliGreenBadge: next.kigaliGreenBadge,
      nidaNumber: next.nidaNumber,
      iremboCertUrl: next.iremboCertUrl,
      tradeCertUrl: next.tradeCertUrl,
      tradeCertKind: next.tradeKind,
      livenessSelfieRef: next.livenessSelfieRef,
      smileJobId: next.smileJobId,
      idVerified: next.nidaKycPassed,
      certificateVerified: next.tradeStatus == VerificationStatus.verified,
      phoneVerified:
          next.overallStatus == VerificationStatus.verified ? true : phoneVerified,
      idVerificationStatus: next.nidaStatus,
      livenessVerificationStatus: next.livenessStatus,
      iremboVerificationStatus: next.iremboStatus,
      tvetVerificationStatus: next.tradeStatus,
    );
  }

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
    VerificationStatus? iremboVerificationStatus,
    VerificationStatus? livenessVerificationStatus,
    bool? kigaliGreenBadge,
    String? nidaNumber,
    String? iremboCertUrl,
    String? tradeCertUrl,
    TradeCertificateKind? tradeCertKind,
    String? livenessSelfieRef,
    String? smileJobId,
    String? userId,
    String? sector,
    String? district,
    double? latitude,
    double? longitude,
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
      iremboVerificationStatus:
          iremboVerificationStatus ?? this.iremboVerificationStatus,
      livenessVerificationStatus:
          livenessVerificationStatus ?? this.livenessVerificationStatus,
      kigaliGreenBadge: kigaliGreenBadge ?? this.kigaliGreenBadge,
      nidaNumber: nidaNumber ?? this.nidaNumber,
      iremboCertUrl: iremboCertUrl ?? this.iremboCertUrl,
      tradeCertUrl: tradeCertUrl ?? this.tradeCertUrl,
      tradeCertKind: tradeCertKind ?? this.tradeCertKind,
      livenessSelfieRef: livenessSelfieRef ?? this.livenessSelfieRef,
      smileJobId: smileJobId ?? this.smileJobId,
      userId: userId ?? this.userId,
      sector: sector ?? this.sector,
      district: district ?? this.district,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
