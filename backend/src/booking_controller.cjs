const KIGALI_DISTRICTS = ['Gasabo', 'Kicukiro', 'Nyarugenge'];
const BROADCAST_TIMEOUT_MS = 15 * 60 * 1000;
const INITIAL_OFFER_COUNT = 1;
const REROUTE_OFFER_COUNT = 3;
const MARKETPLACE_FEE_RATE = 0.15;

const DISTRICT_CENTROIDS = {
  Gasabo: { lat: -1.932, lng: 30.099 },
  Kicukiro: { lat: -1.978, lng: 30.104 },
  Nyarugenge: { lat: -1.944, lng: 30.061 },
};

function assertDistrict(district) {
  if (!KIGALI_DISTRICTS.includes(district)) {
    throw new Error('Jobs must be in Gasabo, Kicukiro, or Nyarugenge.');
  }
}

function distanceKm(a, b) {
  const toRad = (value) => (value * Math.PI) / 180;
  const dLat = toRad(b.lat - a.lat);
  const dLng = toRad(b.lng - a.lng);
  const lat1 = toRad(a.lat);
  const lat2 = toRad(b.lat);
  const h =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(lat1) * Math.cos(lat2) * Math.sin(dLng / 2) ** 2;
  return 6371 * 2 * Math.asin(Math.min(1, Math.sqrt(h)));
}

function jobCoordinates(booking) {
  if (booking.jobLat != null && booking.jobLng != null) {
    return { lat: booking.jobLat, lng: booking.jobLng };
  }
  return DISTRICT_CENTROIDS[booking.district] || DISTRICT_CENTROIDS.Gasabo;
}

function rankVerifiedProviders({ providers, booking }) {
  assertDistrict(booking.district);
  const origin = jobCoordinates(booking);
  return providers
    .filter(
      (provider) =>
        provider.verificationStatus === 'verified' &&
        provider.kigaliGreenBadge === true &&
        provider.category === booking.category &&
        provider.district === booking.district,
    )
    .map((provider) => ({
      provider,
      km: distanceKm(origin, {
        lat: provider.lat,
        lng: provider.lng,
      }),
    }))
    .sort((a, b) => a.km - b.km)
    .map((item) => item.provider);
}

function nextOfferBatch(ranked, alreadyOfferedIds, take) {
  return ranked
    .filter((provider) => !alreadyOfferedIds.includes(provider.id))
    .slice(0, take)
    .map((provider) => provider.id);
}

function startBroadcast(booking, providers, now = new Date()) {
  const ranked = rankVerifiedProviders({ providers, booking });
  const currentOfferIds = nextOfferBatch(ranked, [], INITIAL_OFFER_COUNT);
  return {
    ...booking,
    status: 'broadcasting',
    currentOfferIds,
    offeredProviderIds: currentOfferIds,
    broadcastExpiresAt: new Date(now.getTime() + BROADCAST_TIMEOUT_MS).toISOString(),
    broadcastRound: 1,
  };
}

function onBroadcastTimeout(booking, providers, now = new Date()) {
  if (booking.status !== 'broadcasting') {
    return { booking, rerouted: false, expired: false };
  }
  const deadline = new Date(booking.broadcastExpiresAt).getTime();
  if (now.getTime() <= deadline) {
    return { booking, rerouted: false, expired: false };
  }

  const ranked = rankVerifiedProviders({ providers, booking });
  const already = booking.offeredProviderIds || [];
  const nextIds = nextOfferBatch(ranked, already, REROUTE_OFFER_COUNT);

  if (nextIds.length === 0) {
    return {
      booking: {
        ...booking,
        status: 'expired',
        currentOfferIds: [],
        refundAmountRwf: booking.servicePrice,
      },
      rerouted: false,
      expired: true,
    };
  }

  return {
    booking: {
      ...booking,
      status: 'broadcasting',
      currentOfferIds: nextIds,
      offeredProviderIds: [...already, ...nextIds],
      broadcastExpiresAt: new Date(now.getTime() + BROADCAST_TIMEOUT_MS).toISOString(),
      broadcastRound: (booking.broadcastRound || 1) + 1,
    },
    rerouted: true,
    expired: false,
  };
}

function generateCompletionOtp() {
  return String(1000 + Math.floor(Math.random() * 9000));
}

function providerCompleteWithOtp(booking, otp) {
  if (booking.status !== 'inProgress' && booking.status !== 'awaitingOtp') {
    throw new Error('The job is not ready for payout.');
  }
  if (!booking.completionOtp) {
    throw new Error('No client confirmation code has been generated.');
  }
  if (String(otp).trim() !== String(booking.completionOtp)) {
    throw new Error('The client confirmation code is incorrect. Payout was not released.');
  }
  const fee = Math.round(booking.servicePrice * MARKETPLACE_FEE_RATE);
  return {
    booking: {
      ...booking,
      status: 'completed',
    },
    payout: {
      providerPayoutRwf: booking.servicePrice - fee,
      marketplaceFeeRwf: fee,
    },
  };
}

function canProviderSeeBroadcast(booking, providerId) {
  return (
    booking.status === 'broadcasting' &&
    Array.isArray(booking.currentOfferIds) &&
    booking.currentOfferIds.includes(providerId)
  );
}

module.exports = {
  KIGALI_DISTRICTS,
  BROADCAST_TIMEOUT_MS,
  INITIAL_OFFER_COUNT,
  REROUTE_OFFER_COUNT,
  DISTRICT_CENTROIDS,
  distanceKm,
  rankVerifiedProviders,
  startBroadcast,
  onBroadcastTimeout,
  generateCompletionOtp,
  providerCompleteWithOtp,
  canProviderSeeBroadcast,
};
