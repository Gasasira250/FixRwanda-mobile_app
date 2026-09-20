import 'professional.dart';

enum TradeCertificateKind {
  tvetIprc,
  rdbBusiness,
}

extension TradeCertificateKindLabel on TradeCertificateKind {
  String get apiName => switch (this) {
        TradeCertificateKind.tvetIprc => 'tvet_iprc',
        TradeCertificateKind.rdbBusiness => 'rdb_business',
      };

  String get label => switch (this) {
        TradeCertificateKind.tvetIprc => 'TVET / IPRC diploma',
        TradeCertificateKind.rdbBusiness => 'RDB business registration',
      };
}

class ProviderVerification {
  const ProviderVerification({
    required this.providerId,
    this.overallStatus = VerificationStatus.pending,
    this.kigaliGreenBadge = false,
    this.nidaStatus = VerificationStatus.pending,
    this.livenessStatus = VerificationStatus.pending,
    this.iremboStatus = VerificationStatus.pending,
    this.tradeStatus = VerificationStatus.pending,
    this.nidaNumber,
    this.iremboCertUrl,
    this.tradeCertUrl,
    this.tradeKind,
    this.livenessSelfieRef,
    this.smileJobId,
    this.rejectionReason,
  });

  final String providerId;
  final VerificationStatus overallStatus;
  final bool kigaliGreenBadge;
  final VerificationStatus nidaStatus;
  final VerificationStatus livenessStatus;
  final VerificationStatus iremboStatus;
  final VerificationStatus tradeStatus;
  final String? nidaNumber;
  final String? iremboCertUrl;
  final String? tradeCertUrl;
  final TradeCertificateKind? tradeKind;
  final String? livenessSelfieRef;
  final String? smileJobId;
  final String? rejectionReason;

  bool get nidaKycPassed =>
      nidaStatus == VerificationStatus.verified &&
      livenessStatus == VerificationStatus.verified;

  bool get documentsComplete =>
      nidaKycPassed &&
      iremboStatus == VerificationStatus.verified &&
      tradeStatus == VerificationStatus.verified;

  Map<String, dynamic> toJson() {
    return {
      'provider_id': providerId,
      'verification_status': overallStatus.name.toUpperCase(),
      'kigali_green_badge': kigaliGreenBadge,
      'documents': {
        'nida_number': nidaNumber,
        'irembo_cert_url': iremboCertUrl,
        'trade_cert_url': tradeCertUrl,
        'trade_cert_kind': tradeKind?.apiName,
      },
    };
  }

  ProviderVerification copyWith({
    String? providerId,
    VerificationStatus? overallStatus,
    bool? kigaliGreenBadge,
    VerificationStatus? nidaStatus,
    VerificationStatus? livenessStatus,
    VerificationStatus? iremboStatus,
    VerificationStatus? tradeStatus,
    String? nidaNumber,
    String? iremboCertUrl,
    String? tradeCertUrl,
    TradeCertificateKind? tradeKind,
    String? livenessSelfieRef,
    String? smileJobId,
    String? rejectionReason,
    bool clearRejection = false,
  }) {
    return ProviderVerification(
      providerId: providerId ?? this.providerId,
      overallStatus: overallStatus ?? this.overallStatus,
      kigaliGreenBadge: kigaliGreenBadge ?? this.kigaliGreenBadge,
      nidaStatus: nidaStatus ?? this.nidaStatus,
      livenessStatus: livenessStatus ?? this.livenessStatus,
      iremboStatus: iremboStatus ?? this.iremboStatus,
      tradeStatus: tradeStatus ?? this.tradeStatus,
      nidaNumber: nidaNumber ?? this.nidaNumber,
      iremboCertUrl: iremboCertUrl ?? this.iremboCertUrl,
      tradeCertUrl: tradeCertUrl ?? this.tradeCertUrl,
      tradeKind: tradeKind ?? this.tradeKind,
      livenessSelfieRef: livenessSelfieRef ?? this.livenessSelfieRef,
      smileJobId: smileJobId ?? this.smileJobId,
      rejectionReason:
          clearRejection ? null : (rejectionReason ?? this.rejectionReason),
    );
  }
}
