# Testing

```bash
cd C:\Users\PC\OneDrive\Desktop\fixrwanda
flutter pub get
flutter analyze
flutter test
node --test backend/src/*.test.js
```

## Covered

- Booking lifecycle, including disputes
- Cancellation: full refund, 2,000 RWF transport fee, no cancel in progress
- Commission: 15% marketplace / 85% provider, clamped 10–15%
- Professional search/filter/sort
- Escrow hold, 15-minute cascade to the next 3 providers, expiry refund
- Provider OTP payout gate and after-photo requirement
- NIDA / Irembo / trade verification and Kigali Green Badge
- Admin cannot verify without completed documents
- Unverified professionals cannot accept jobs
- App widget loads

## Still needed

- Widget coverage for cancel/review dialogs
- Integration tests against a hosted API with live MTN sandbox credentials (not committed)
