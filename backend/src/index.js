import 'dotenv/config';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import bcrypt from 'bcryptjs';
import cors from 'cors';
import express from 'express';
import jwt from 'jsonwebtoken';
import { initDb, state } from './db.js';
import {
  isValidMoMoPhone,
  mockMoMoPush,
  mockPayment,
  nextStatus,
  quoteCancellation,
} from './refunds.js';
import {
  adminStats,
  createBooking,
  createUser,
  findBooking,
  findProfessional,
  findUserById,
  findUserByIdentifier,
  listBookings,
  listCategories,
  listProfessionals,
  markBookingPayment,
  saveBooking,
  seed,
  setVerification,
} from './store.js';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const app = express();
const PORT = Number(process.env.PORT || 4000);
const JWT_SECRET = process.env.JWT_SECRET || 'fixrwanda-interview-secret';

app.use(cors());
app.use(express.json());
const adminDir = [
  path.join(__dirname, '..', '..', 'admin'),
  path.join(__dirname, '..', 'admin'),
].find((candidate) => fs.existsSync(candidate));
if (adminDir) {
  app.use('/admin', express.static(adminDir));
}

function sign(user) {
  return jwt.sign(
    { id: user.id, role: user.role, name: user.name },
    JWT_SECRET,
    { expiresIn: '7d' },
  );
}

function publicUser(user, token) {
  return {
    user: {
      id: user.id,
      name: user.name,
      identifier: user.email || user.phone,
      email: user.email,
      phone: user.phone,
      role: user.role,
    },
    token,
  };
}

function auth(requiredRole) {
  return (req, res, next) => {
    const header = req.headers.authorization || '';
    const token = header.startsWith('Bearer ') ? header.slice(7) : null;
    if (!token) return res.status(401).json({ message: 'Sign in required.' });
    try {
      req.user = jwt.verify(token, JWT_SECRET);
      if (requiredRole && req.user.role !== requiredRole && req.user.role !== 'admin') {
        return res.status(403).json({ message: 'Not allowed.' });
      }
      return next();
    } catch {
      return res.status(401).json({ message: 'Invalid or expired token.' });
    }
  };
}

app.get('/health', (_req, res) => {
  res.json({
    ok: true,
    service: 'fixrwanda-api',
    store: state.engine,
  });
});

function identifierFrom(body = {}) {
  return String(body.email || body.identifier || body.phone || '').trim();
}

async function handleLogin(req, res) {
  const identifier = identifierFrom(req.body);
  const password = req.body?.password;
  if (!identifier || !password) {
    return res.status(400).json({
      success: false,
      message: 'Email and password are required',
    });
  }
  try {
    const user = await findUserByIdentifier(identifier);
    if (!user || !(await bcrypt.compare(password, user.password_hash))) {
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password',
      });
    }
    return res.status(200).json({
      success: true,
      message: 'Login successful',
      ...publicUser(user, sign(user)),
    });
  } catch (error) {
    console.error('Login error:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error during login',
    });
  }
}

async function handleSignup(req, res) {
  const identifier = identifierFrom(req.body);
  const password = req.body?.password;
  const name = String(req.body?.name || '').trim();
  if (!identifier || !password) {
    return res.status(400).json({
      success: false,
      message: 'Email and password are required',
    });
  }
  if (password.length < 6) {
    return res.status(400).json({
      success: false,
      message: 'Password must be at least 6 characters',
    });
  }
  try {
    const existing = await findUserByIdentifier(identifier);
    if (existing) {
      return res.status(400).json({
        success: false,
        message: 'An account with this email already exists',
      });
    }
    const displayName =
      name ||
      (identifier.includes('@') ? identifier.split('@')[0] : identifier);
    const user = await createUser({
      name: displayName,
      identifier,
      password,
    });
    return res.status(201).json({
      success: true,
      message: 'Account created successfully',
      ...publicUser(user, sign(user)),
    });
  } catch (error) {
    console.error('Signup error:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error during registration',
    });
  }
}

app.post('/api/login', handleLogin);
app.post('/api/auth/login', handleLogin);
app.post('/api/signup', handleSignup);
app.post('/api/auth/register', handleSignup);

app.get('/api/services', async (_req, res) => {
  const categories = await listCategories();
  res.json({
    categories: categories.map((item) => ({
      id: item.id,
      name: item.name,
      icon: item.icon,
    })),
  });
});

app.get('/api/professionals', async (req, res) => {
  const professionals = await listProfessionals({
    trade: req.query.trade,
    q: req.query.q,
  });
  res.json({ professionals });
});

app.get('/api/professionals/:id', async (req, res) => {
  const professional = await findProfessional(req.params.id);
  if (!professional) return res.status(404).json({ message: 'Professional not found.' });
  res.json({ professional });
});

app.get('/api/bookings', auth(), async (req, res) => {
  const user = await findUserById(req.user.id);
  const bookings = await listBookings(user);
  res.json({ bookings });
});

app.post('/api/bookings', auth(), async (req, res) => {
  const {
    professionalId,
    service,
    scheduledAt,
    location,
    description,
    paymentMethod,
  } = req.body || {};
  const professional = await findProfessional(professionalId);
  if (!professional) {
    return res.status(404).json({ message: 'Professional not found.' });
  }
  const verified =
    professional.verificationStatus === 'verified' &&
    (professional.tvetVerified || professional.idVerified);
  if (!verified) {
    return res.status(409).json({ message: 'Only verified professionals can be booked.' });
  }
  const payment = mockPayment(paymentMethod || 'mtnMomo');
  await new Promise((resolve) => setTimeout(resolve, 400));
  const booking = await createBooking({
    customerId: req.user.id,
    professional,
    service: service || professional.services[0],
    scheduledAt,
    location,
    description,
    payment,
  });
  res.status(201).json({ booking, payment });
});

app.post('/api/payments/momo', auth(), async (req, res) => {
  const { bookingId, phoneNumber, amount, method } = req.body || {};
  if (!phoneNumber || amount == null || amount === '') {
    return res.status(400).json({
      success: false,
      message: 'Phone number and amount are required',
    });
  }
  const payMethod = method === 'airtelMoney' ? 'airtelMoney' : 'mtnMomo';
  if (!isValidMoMoPhone(phoneNumber, payMethod)) {
    return res.status(400).json({
      success: false,
      message:
        payMethod === 'airtelMoney'
          ? 'Enter a valid Airtel Money number (073 or 072)'
          : 'Enter a valid MTN MoMo number (078 or 079)',
    });
  }
  try {
    const push = mockMoMoPush({
      phoneNumber,
      amount,
      method: payMethod,
    });
    await new Promise((resolve) => setTimeout(resolve, 700));
    if (bookingId) {
      await markBookingPayment(bookingId, {
        paymentStatus: 'Pending Processing',
        paymentReference: push.providerReference,
        method: payMethod,
      });
    }
    return res.json({ ...push, bookingId: bookingId || null });
  } catch (error) {
    console.error('MoMo error:', error);
    return res.status(500).json({
      success: false,
      message: 'Payment gateway error',
    });
  }
});

app.get('/api/bookings/:id/refund-quote', auth(), async (req, res) => {
  const booking = await findBooking(req.params.id);
  if (!booking) return res.status(404).json({ message: 'Booking not found.' });
  res.json({ quote: quoteCancellation(booking) });
});

app.post('/api/bookings/:id/cancel', auth(), async (req, res) => {
  const booking = await findBooking(req.params.id);
  if (!booking) return res.status(404).json({ message: 'Booking not found.' });
  const quote = quoteCancellation(booking);
  if (!quote.canCancel) {
    return res.status(409).json({ message: quote.message, quote });
  }
  booking.status = 'cancelled';
  booking.cancellationFeeRwf = quote.cancellationFeeRwf;
  booking.refundAmountRwf = quote.refundAmountRwf;
  booking.cancelledAt = new Date().toISOString();
  const saved = await saveBooking(booking);
  res.json({ booking: saved, quote });
});

app.post('/api/bookings/:id/advance', auth(), async (req, res) => {
  const booking = await findBooking(req.params.id);
  if (!booking) return res.status(404).json({ message: 'Booking not found.' });
  const next = nextStatus(booking.status);
  if (!next) {
    return res.status(409).json({ message: 'No further professional action.' });
  }
  booking.status = next;
  const saved = await saveBooking(booking);
  res.json({ booking: saved });
});

app.get('/api/admin/stats', auth('admin'), async (_req, res) => {
  res.json(await adminStats());
});

app.get('/api/admin/professionals', auth('admin'), async (_req, res) => {
  res.json({ professionals: await listProfessionals() });
});

app.patch('/api/admin/professionals/:id', auth('admin'), async (req, res) => {
  const status = req.body?.verificationStatus;
  if (!['verified', 'rejected', 'pending'].includes(status)) {
    return res.status(400).json({ message: 'verificationStatus must be verified, rejected or pending.' });
  }
  const professional = await setVerification(req.params.id, status);
  if (!professional) return res.status(404).json({ message: 'Professional not found.' });
  res.json({ professional });
});

app.get('/api/admin/bookings', auth('admin'), async (req, res) => {
  const user = await findUserById(req.user.id);
  res.json({ bookings: await listBookings(user) });
});

app.use((error, _req, res, _next) => {
  console.error(error);
  res.status(500).json({ message: 'Server error.' });
});

await initDb();
await seed();

app.listen(PORT, '0.0.0.0', () => {
  console.log(`FixRwanda API on http://127.0.0.1:${PORT}`);
  console.log(`Admin dashboard on http://127.0.0.1:${PORT}/admin/`);
  console.log(`Database engine: ${state.engine}`);
});
