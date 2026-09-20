# Testing

```bash
cd C:\Users\PC\OneDrive\Desktop\fixrwanda
flutter pub get
flutter analyze
flutter test
```

## Covered

- Booking lifecycle: valid and invalid transitions
- Cancellation: full refund, 2,000 RWF transport fee, no cancel in progress
- Commission: 10% default, clamped to 10–15%
- Professional search/filter/sort
- Payment failure leaves booking pending; success confirms it
- Reviews only after completion, no duplicates
- Unverified professionals cannot be booked
- App widget loads

## Still needed

- Widget coverage for cancel/review dialogs
- Integration tests against a hosted API
- Provider tests with live MTN/Airtel sandbox credentials (not committed)
