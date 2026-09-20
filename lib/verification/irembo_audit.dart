class IremboAuditResult {
  const IremboAuditResult({
    required this.verified,
    required this.certificateUrl,
    this.reason,
  });

  final bool verified;
  final String certificateUrl;
  final String? reason;
}

abstract class IremboGovAuditClient {
  String get name;
  Future<IremboAuditResult> auditGoodConduct({
    required String providerId,
    required String documentRef,
  });
}

class MockIremboGovAuditClient implements IremboGovAuditClient {
  const MockIremboGovAuditClient();

  @override
  String get name => 'IremboGov';

  @override
  Future<IremboAuditResult> auditGoodConduct({
    required String providerId,
    required String documentRef,
  }) async {
    final ref = documentRef.trim();
    if (ref.isEmpty) {
      return const IremboAuditResult(
        verified: false,
        certificateUrl: '',
        reason: 'Upload your Irembo Good Conduct Certificate.',
      );
    }
    final lower = ref.toLowerCase();
    if (lower.contains('expired') || lower.contains('invalid')) {
      return IremboAuditResult(
        verified: false,
        certificateUrl: ref,
        reason: 'IremboGov rejected this Good Conduct Certificate.',
      );
    }
    final url = ref.startsWith('http')
        ? ref
        : 'https://s3.amazonaws.com/certs/irembo_$providerId.pdf';
    return IremboAuditResult(verified: true, certificateUrl: url);
  }
}
