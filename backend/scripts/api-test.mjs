const BASE = process.env.API_BASE || 'http://127.0.0.1:4000';

async function request(method, path, { token, body } = {}) {
  const response = await fetch(`${BASE}${path}`, {
    method,
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
    body: body ? JSON.stringify(body) : undefined,
  });
  const data = await response.json().catch(() => ({}));
  if (!response.ok) {
    throw new Error(`${method} ${path} -> ${response.status} ${data.message || ''}`);
  }
  return data;
}

function assert(condition, message) {
  if (!condition) throw new Error(message);
}

const health = await request('GET', '/health');
assert(health.ok, 'health check failed');
console.log(`health ok, store=${health.store}`);

const customer = await request('POST', '/api/login', {
  body: { email: 'hannington@fixrwanda.rw', password: 'demo123' },
});
assert(customer.token, 'customer login missing token');
assert(customer.success === true, 'login should report success');

const admin = await request('POST', '/api/auth/login', {
  body: { identifier: 'admin@fixrwanda.rw', password: 'admin123' },
});
assert(admin.user.role === 'admin', 'admin login failed');

const signupEmail = `api-test-${Date.now()}@fixrwanda.rw`;
const created = await request('POST', '/api/signup', {
  body: { email: signupEmail, password: 'secret123', name: 'API Tester' },
});
assert(created.success === true, 'signup should report success');
assert(created.token, 'signup should return a JWT');
assert(created.user.email === signupEmail, 'signup should return the new email');

const services = await request('GET', '/api/services');
assert(services.categories.length >= 4, 'expected service categories');

const pros = await request('GET', '/api/professionals?q=Kigali');
assert(pros.professionals.length > 0, 'expected professionals');

const booking = await request('POST', '/api/bookings', {
  token: customer.token,
  body: {
    professionalId: 'pro-jean',
    service: 'House wiring',
    scheduledAt: new Date(Date.now() + 86400000).toISOString(),
    location: 'Kimironko, Kigali',
    description: 'Need full house wiring.',
    paymentMethod: 'mtnMomo',
  },
});
assert(booking.booking.paid === true, 'booking should be paid');
assert(booking.booking.status === 'confirmed', 'booking should be confirmed');
assert(booking.payment.providerReference.startsWith('MOM-'), 'expected MTN mock reference');

const quote = await request(
  'GET',
  `/api/bookings/${booking.booking.id}/refund-quote`,
  { token: customer.token },
);
assert(quote.quote.refundAmountRwf === booking.booking.serviceFeeRwf, 'confirmed refund should be full');

const advanced = await request(
  'POST',
  `/api/bookings/${booking.booking.id}/advance`,
  { token: customer.token },
);
assert(advanced.booking.status === 'enRoute', 'expected enRoute after start journey');

const second = await request('POST', '/api/bookings', {
  token: customer.token,
  body: {
    professionalId: 'pro-aline',
    service: 'Leak repair',
    scheduledAt: new Date(Date.now() + 172800000).toISOString(),
    location: 'Nyamirambo, Kigali',
    description: 'Kitchen leak',
    paymentMethod: 'airtelMoney',
  },
});
const cancelled = await request(
  'POST',
  `/api/bookings/${second.booking.id}/cancel`,
  { token: customer.token },
);
assert(cancelled.booking.status === 'cancelled', 'expected cancelled booking');
assert(cancelled.quote.cancellationFeeRwf === 0, 'confirmed cancel should have no fee');

const stats = await request('GET', '/api/admin/stats', { token: admin.token });
assert(stats.bookings >= 2, 'admin should see bookings');

const verified = await request('PATCH', '/api/admin/professionals/pro-patrick', {
  token: admin.token,
  body: { verificationStatus: 'verified' },
});
assert(verified.professional.verificationStatus === 'verified', 'carpenter should be verified');

const momo = await request('POST', '/api/payments/momo', {
  token: customer.token,
  body: { phoneNumber: '0788123456', amount: 25000, method: 'mtnMomo' },
});
assert(momo.success === true, 'momo push should succeed');
assert(momo.status === 'Pending Processing', 'momo should start pending');
assert(String(momo.providerReference).startsWith('MOM-'), 'expected MTN MoMo reference');

console.log('All API tests passed.');
