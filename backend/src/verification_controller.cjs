function isValidNida(raw) {
  const value = String(raw || '').replace(/[\s-]/g, '');
  if (!/^\d{16}$/.test(value)) return false;
  if (value[0] !== '1' && value[0] !== '2') return false;
  const year = Number(value.slice(1, 5));
  const maxYear = new Date().getFullYear() - 16;
  if (year < 1920 || year > maxYear) return false;
  return value[5] === '7' || value[5] === '8';
}

function evaluateVerification(current) {
  const statuses = [
    current.nidaStatus,
    current.livenessStatus,
    current.iremboStatus,
    current.tradeStatus,
  ];
  if (statuses.includes('rejected')) {
    return {
      ...current,
      verification_status: 'REJECTED',
      kigali_green_badge: false,
    };
  }
  const complete =
    current.nidaStatus === 'verified' &&
    current.livenessStatus === 'verified' &&
    current.iremboStatus === 'verified' &&
    current.tradeStatus === 'verified';
  if (complete) {
    return {
      ...current,
      verification_status: 'VERIFIED',
      kigali_green_badge: true,
    };
  }
  return {
    ...current,
    verification_status: 'PENDING',
    kigali_green_badge: false,
  };
}

function verificationFlag(provider) {
  return {
    provider_id: provider.providerId || provider.id,
    verification_status: String(
      provider.verification_status || provider.verificationStatus || 'PENDING',
    ).toUpperCase(),
    kigali_green_badge: Boolean(provider.kigali_green_badge || provider.kigaliGreenBadge),
    documents: {
      nida_number: provider.nidaNumber || null,
      irembo_cert_url: provider.iremboCertUrl || null,
    },
  };
}

function submitNidaKyc(provider, { nidaNumber, selfieRef }) {
  if (!isValidNida(nidaNumber)) {
    throw new Error('Enter a valid 16-digit Rwandan NIDA number.');
  }
  if (!selfieRef) {
    throw new Error('Complete the selfie liveness check.');
  }
  if (String(selfieRef).toLowerCase().includes('spoof')) {
    return evaluateVerification({
      ...provider,
      nidaNumber,
      nidaStatus: 'rejected',
      livenessStatus: 'rejected',
      livenessSelfieRef: selfieRef,
    });
  }
  return evaluateVerification({
    ...provider,
    nidaNumber,
    nidaStatus: 'verified',
    livenessStatus: 'verified',
    livenessSelfieRef: selfieRef,
    smileJobId: `smile-${Date.now()}`,
  });
}

function submitIremboCertificate(provider, { documentRef }) {
  if (!documentRef) {
    throw new Error('Upload your Irembo Good Conduct Certificate.');
  }
  if (/expired|invalid/i.test(documentRef)) {
    return evaluateVerification({
      ...provider,
      iremboStatus: 'rejected',
      iremboCertUrl: documentRef,
    });
  }
  const url = String(documentRef).startsWith('http')
    ? documentRef
    : `https://s3.amazonaws.com/certs/irembo_${provider.providerId || provider.id}.pdf`;
  return evaluateVerification({
    ...provider,
    iremboStatus: 'verified',
    iremboCertUrl: url,
  });
}

function submitTradeCertificate(provider, { kind, documentRef }) {
  if (kind !== 'tvet_iprc' && kind !== 'rdb_business') {
    throw new Error('Provide a TVET/IPRC diploma or an RDB business registration.');
  }
  if (!documentRef) {
    throw new Error('Upload a TVET/IPRC diploma or an RDB business registration.');
  }
  const prefix = kind === 'rdb_business' ? 'rdb' : 'tvet';
  const url = String(documentRef).startsWith('http')
    ? documentRef
    : `https://s3.amazonaws.com/certs/${prefix}_${provider.providerId || provider.id}.pdf`;
  return evaluateVerification({
    ...provider,
    tradeStatus: 'verified',
    tradeKind: kind,
    tradeCertUrl: url,
  });
}

module.exports = {
  isValidNida,
  evaluateVerification,
  verificationFlag,
  submitNidaKyc,
  submitIremboCertificate,
  submitTradeCertificate,
};
