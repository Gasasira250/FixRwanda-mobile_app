import '../models/professional.dart';
import '../models/provider_verification.dart';

class VerificationPipeline {
  VerificationPipeline._();

  static ProviderVerification evaluate(ProviderVerification current) {
    final rejected = [
      current.nidaStatus,
      current.livenessStatus,
      current.iremboStatus,
      current.tradeStatus,
    ].contains(VerificationStatus.rejected);

    if (rejected) {
      return current.copyWith(
        overallStatus: VerificationStatus.rejected,
        kigaliGreenBadge: false,
        rejectionReason: current.rejectionReason ??
            'A verification step was rejected. Resubmit the failed document.',
      );
    }

    if (current.documentsComplete) {
      return current.copyWith(
        overallStatus: VerificationStatus.verified,
        kigaliGreenBadge: true,
        clearRejection: true,
      );
    }

    return current.copyWith(
      overallStatus: VerificationStatus.pending,
      kigaliGreenBadge: false,
      clearRejection: true,
    );
  }
}
