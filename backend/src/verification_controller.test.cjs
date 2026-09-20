const test = require('node:test');
const assert = require('node:assert/strict');
const {
  isValidNida,
  submitNidaKyc,
  submitIremboCertificate,
  submitTradeCertificate,
  verificationFlag,
} = require('./verification_controller.cjs');

const pending = {
  providerId: 'prov_9082',
  nidaStatus: 'pending',
  livenessStatus: 'pending',
  iremboStatus: 'pending',
  tradeStatus: 'pending',
};

test('accepts a 16-digit Rwandan NIDA number', () => {
  assert.equal(isValidNida('1199580000000000'), true);
  assert.equal(isValidNida('11995'), false);
});

test('NIDA plus liveness, Irembo, and trade docs issue the green badge', () => {
  const afterNida = submitNidaKyc(pending, {
    nidaNumber: '1199580000000000',
    selfieRef: 'liveness-1',
  });
  assert.equal(afterNida.verification_status, 'PENDING');
  const afterIrembo = submitIremboCertificate(afterNida, {
    documentRef: 'irembo-good-conduct',
  });
  const verified = submitTradeCertificate(afterIrembo, {
    kind: 'tvet_iprc',
    documentRef: 'tvet-diploma',
  });
  assert.equal(verified.verification_status, 'VERIFIED');
  assert.equal(verified.kigali_green_badge, true);
  assert.deepEqual(verificationFlag(verified), {
    provider_id: 'prov_9082',
    verification_status: 'VERIFIED',
    kigali_green_badge: true,
    documents: {
      nida_number: '1199580000000000',
      irembo_cert_url: 'https://s3.amazonaws.com/certs/irembo_prov_9082.pdf',
    },
  });
});

test('spoofed selfie blocks KYC and the green badge', () => {
  const failed = submitNidaKyc(pending, {
    nidaNumber: '1199580000000000',
    selfieRef: 'spoof-selfie',
  });
  assert.equal(failed.verification_status, 'REJECTED');
  assert.equal(failed.kigali_green_badge, false);
});
