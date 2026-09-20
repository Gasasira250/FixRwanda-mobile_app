import '../models/provider_verification.dart';

class TradeCertAuditResult {
  const TradeCertAuditResult({
    required this.verified,
    required this.certificateUrl,
    this.reason,
  });

  final bool verified;
  final String certificateUrl;
  final String? reason;
}

abstract class TradeCertAuditClient {
  Future<TradeCertAuditResult> audit({
    required String providerId,
    required TradeCertificateKind kind,
    required String documentRef,
  });
}

class MockTradeCertAuditClient implements TradeCertAuditClient {
  const MockTradeCertAuditClient();

  @override
  Future<TradeCertAuditResult> audit({
    required String providerId,
    required TradeCertificateKind kind,
    required String documentRef,
  }) async {
    final ref = documentRef.trim();
    if (ref.isEmpty) {
      return const TradeCertAuditResult(
        verified: false,
        certificateUrl: '',
        reason: 'Upload a TVET/IPRC diploma or an RDB business registration.',
      );
    }
    if (ref.toLowerCase().contains('invalid')) {
      return TradeCertAuditResult(
        verified: false,
        certificateUrl: ref,
        reason: 'This trade document could not be verified.',
      );
    }
    final prefix = kind == TradeCertificateKind.rdbBusiness ? 'rdb' : 'tvet';
    final url = ref.startsWith('http')
        ? ref
        : 'https://s3.amazonaws.com/certs/${prefix}_$providerId.pdf';
    return TradeCertAuditResult(verified: true, certificateUrl: url);
  }
}
