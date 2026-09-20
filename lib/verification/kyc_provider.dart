import '../domain/nida.dart';

class SmileIdKycResult {
  const SmileIdKycResult({
    required this.verified,
    required this.jobId,
    this.reason,
  });

  final bool verified;
  final String jobId;
  final String? reason;
}

abstract class IdentityKycClient {
  String get name;
  Future<SmileIdKycResult> verifyNida({
    required String nidaNumber,
    required String selfieRef,
  });
}

class SmileIdKycClient implements IdentityKycClient {
  const SmileIdKycClient();

  @override
  String get name => 'Smile ID';

  @override
  Future<SmileIdKycResult> verifyNida({
    required String nidaNumber,
    required String selfieRef,
  }) async {
    if (!NidaNumber.isValid(nidaNumber)) {
      return const SmileIdKycResult(
        verified: false,
        jobId: '',
        reason: 'Enter a valid 16-digit Rwandan NIDA number.',
      );
    }
    if (selfieRef.trim().isEmpty) {
      return const SmileIdKycResult(
        verified: false,
        jobId: '',
        reason: 'Complete the selfie liveness check.',
      );
    }
    if (selfieRef.toLowerCase().contains('spoof')) {
      return SmileIdKycResult(
        verified: false,
        jobId: 'smile-fail-${DateTime.now().millisecondsSinceEpoch}',
        reason: 'Smile ID liveness failed. Capture a live selfie.',
      );
    }
    return SmileIdKycResult(
      verified: true,
      jobId: 'smile-${DateTime.now().millisecondsSinceEpoch}',
    );
  }
}
