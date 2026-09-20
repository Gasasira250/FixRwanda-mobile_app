const express = require('express');
const http = require('http');
const { Server } = require('socket.io');

const {
  startBroadcast,
  onBroadcastTimeout,
  generateCompletionOtp,
  providerCompleteWithOtp,
} = require('./booking_controller.cjs');
const {
  requestToPay,
  applyCollectionWebhook,
  transferToProvider,
} = require('./payment_service.cjs');
const { openDispute, adminRefund, adminPayout } = require('./dispute_controller.cjs');
const { attachRealtime } = require('./realtime.cjs');

function createApp({ io } = {}) {
  const app = express();
  app.use(express.json());
  const bookings = new Map();

  app.post('/api/bookings/:id/pay', (req, res) => {
    const booking = bookings.get(req.params.id) || {
      id: req.params.id,
      ...req.body.booking,
      status: req.body.booking?.status || 'REQUESTED',
    };
    try {
      const collection = requestToPay({
        bookingId: booking.id,
        amountRwf: booking.amount_rwf || booking.servicePrice,
        msisdn: req.body.msisdn,
      });
      bookings.set(booking.id, { ...booking, payment_state: collection.payment_state });
      res.json({ booking: bookings.get(booking.id), collection });
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  });

  app.post('/webhooks/momo/collection', (req, res) => {
    const booking = bookings.get(req.body.bookingId);
    if (!booking) {
      res.status(404).json({ error: 'Booking was not found.' });
      return;
    }
    const result = applyCollectionWebhook(booking, req.body);
    const next = result.held
      ? startBroadcast(result.booking, req.body.providers || [])
      : result.booking;
    bookings.set(booking.id, next);
    res.json({ booking: next, held: result.held });
  });

  app.post('/api/bookings/:id/complete', (req, res) => {
    const booking = bookings.get(req.params.id);
    if (!booking) {
      res.status(404).json({ error: 'Booking was not found.' });
      return;
    }
    try {
      const result = transferToProvider(booking, {
        otp: req.body.otp,
        providerMsisdn: req.body.providerMsisdn,
      });
      bookings.set(booking.id, result.booking);
      res.json(result);
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  });

  app.post('/api/bookings/:id/location', (req, res) => {
    const booking = bookings.get(req.params.id);
    if (!booking) {
      res.status(404).json({ error: 'Booking was not found.' });
      return;
    }
    const next = {
      ...booking,
      provider_latitude: req.body.lat,
      provider_longitude: req.body.lng,
      last_location_at: new Date().toISOString(),
    };
    bookings.set(booking.id, next);
    if (io) {
      io.to(`job:${booking.id}`).emit('location', {
        bookingId: booking.id,
        lat: req.body.lat,
        lng: req.body.lng,
        at: next.last_location_at,
      });
    }
    res.json({ booking: next });
  });

  app.post('/api/bookings/:id/dispute', (req, res) => {
    const booking = bookings.get(req.params.id);
    if (!booking) {
      res.status(404).json({ error: 'Booking was not found.' });
      return;
    }
    try {
      const next = openDispute(booking, req.body);
      bookings.set(booking.id, next);
      res.json({ booking: next });
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  });

  app.post('/api/admin/bookings/:id/refund', (req, res) => {
    const booking = bookings.get(req.params.id);
    if (!booking) {
      res.status(404).json({ error: 'Booking was not found.' });
      return;
    }
    try {
      const result = adminRefund(booking);
      bookings.set(booking.id, result.booking);
      res.json(result);
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  });

  app.post('/api/admin/bookings/:id/payout', (req, res) => {
    const booking = bookings.get(req.params.id);
    if (!booking) {
      res.status(404).json({ error: 'Booking was not found.' });
      return;
    }
    try {
      const result = adminPayout(booking);
      bookings.set(booking.id, result.booking);
      res.json(result);
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  });

  app.get('/health', (_req, res) => res.json({ ok: true }));

  app.locals.bookings = bookings;
  app.locals.startBroadcast = startBroadcast;
  app.locals.onBroadcastTimeout = onBroadcastTimeout;
  app.locals.generateCompletionOtp = generateCompletionOtp;
  app.locals.providerCompleteWithOtp = providerCompleteWithOtp;
  return app;
}

function startServer(port = process.env.PORT || 8080) {
  const app = createApp();
  const server = http.createServer(app);
  const io = new Server(server, { cors: { origin: '*' } });
  attachRealtime(io);
  const routed = createApp({ io });
  server.removeAllListeners('request');
  server.on('request', routed);
  routed.locals.io = io;
  server.listen(port);
  return server;
}

if (require.main === module) {
  startServer();
}

module.exports = { createApp, startServer };
