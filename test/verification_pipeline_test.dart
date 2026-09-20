import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fixrwanda/core/exceptions.dart';
import 'package:fixrwanda/data/local_marketplace_store.dart';
import 'package:fixrwanda/domain/nida.dart';
import 'package:fixrwanda/domain/verification_pipeline.dart';
import 'package:fixrwanda/models/professional.dart';
import 'package:fixrwanda/models/provider_verification.dart';
import 'package:fixrwanda/models/user.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('accepts a 16-digit Rwandan NIDA number', () {
    expect(NidaNumber.isValid('1199580000000000'), isTrue);
    expect(NidaNumber.isValid('11995'), isFalse);
    expect(NidaNumber.isValid('3199580000000000'), isFalse);
  });

  test('pipeline issues VERIFIED and the Kigali Green Badge only after all three tiers', () {
    const pending = ProviderVerification(providerId: 'prov_9082');
    expect(VerificationPipeline.evaluate(pending).kigaliGreenBadge, isFalse);

    final complete = VerificationPipeline.evaluate(
      pending.copyWith(
        nidaStatus: VerificationStatus.verified,
        livenessStatus: VerificationStatus.verified,
        iremboStatus: VerificationStatus.verified,
        tradeStatus: VerificationStatus.verified,
        nidaNumber: '1199580000000000',
        iremboCertUrl: 'https://s3.amazonaws.com/certs/irembo_882.pdf',
      ),
    );
    expect(complete.overallStatus, VerificationStatus.verified);
    expect(complete.kigaliGreenBadge, isTrue);
    expect(complete.toJson(), {
      'provider_id': 'prov_9082',
      'verification_status': 'VERIFIED',
      'kigali_green_badge': true,
      'documents': {
        'nida_number': '1199580000000000',
        'irembo_cert_url': 'https://s3.amazonaws.com/certs/irembo_882.pdf',
        'trade_cert_url': null,
        'trade_cert_kind': null,
      },
    });
  });

  test('a new provider becomes bookable only after NIDA, Irembo, and trade documents pass', () async {
    final store = LocalMarketplaceStore();
    await store.register(
      fullName: 'Yves Habineza',
      email: 'yves.onboard@fixrwanda.rw',
      phoneNumber: '+250788321000',
      password: 'rwanda123',
      role: UserRole.professional,
    );

    expect(store.professionalForUser(store.currentUserOrThrow().id)?.isBookable, isFalse);

    await store.submitNidaKyc(
      nidaNumber: '1199580000000000',
      selfieRef: 'liveness-live',
    );
    await store.submitIremboCertificate(documentRef: 'irembo-good-conduct');
    final finished = await store.submitTradeCertificate(
      kind: TradeCertificateKind.tvetIprc,
      documentRef: 'tvet-diploma',
    );

    expect(finished.verificationStatus, VerificationStatus.verified);
    expect(finished.kigaliGreenBadge, isTrue);
    expect(finished.isBookable, isTrue);
    expect(store.verificationFlag(finished.id)['kigali_green_badge'], isTrue);
    expect(store.verificationFlag(finished.id)['documents']['nida_number'], '1199580000000000');
  });

  test('spoofed liveness and expired Irembo certificates are rejected', () async {
    final store = LocalMarketplaceStore();
    await store.register(
      fullName: 'Failed KYC',
      email: 'fail.kyc@fixrwanda.rw',
      phoneNumber: '+250788321111',
      password: 'rwanda123',
      role: UserRole.professional,
    );

    final spoofed = await store.submitNidaKyc(
      nidaNumber: '1199580000000000',
      selfieRef: 'spoof-selfie',
    );
    expect(spoofed.verificationStatus, VerificationStatus.rejected);
    expect(spoofed.kigaliGreenBadge, isFalse);

    await store.submitNidaKyc(
      nidaNumber: '1199580000000000',
      selfieRef: 'liveness-live',
    );
    final expired = await store.submitIremboCertificate(
      documentRef: 'expired-irembo',
    );
    expect(expired.iremboVerificationStatus, VerificationStatus.rejected);
    expect(expired.kigaliGreenBadge, isFalse);
  });

  test('admin cannot issue the green badge without completed documents', () async {
    final store = LocalMarketplaceStore();
    await store.login(identifier: 'admin@fixrwanda.rw', password: 'admin123');
    await expectLater(
      store.setOverallVerification('pro-5', VerificationStatus.verified),
      throwsA(isA<MarketplaceException>()),
    );
  });
}
