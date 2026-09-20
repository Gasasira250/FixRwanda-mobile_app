# FixRwanda

FixRwanda is a Kigali marketplace for finding, booking, paying, and reviewing verified local professionals. The market language is English. Prices are in RWF.

**Live app:** https://gasasira250.github.io/FixRwanda-mobile_app/

## What you can do

- Create an account and stay signed in on this device
- Browse ten service categories
- Filter professionals by trade, rating, price, and verification
- Book only overall-verified professionals
- Pay with MTN MoMo, Airtel Money, or card through a provider interface
- Cancel with the published refund rules
- Review a completed job once

## Run the app

```powershell
cd C:\Users\PC\OneDrive\Desktop\fixrwanda
flutter pub get
flutter run -d emulator-5554
```

In Android Studio, open `C:\Users\PC\OneDrive\Desktop\fixrwanda` and run `lib/main.dart`.

Sign-in credentials used by the local development store:

- Customer: `hannington@fixrwanda.rw` / `rwanda123`
- Admin: `admin@fixrwanda.rw` / `admin123`

To see a declined payment, use a phone number ending in `0000`.

## Project layout

- `lib/screens` UI
- `lib/state` app state
- `lib/repositories` contracts
- `lib/data` local marketplace store
- `lib/domain` booking, cancellation, and commission rules
- `lib/payments` payment providers
- `backend/sql/` planned database
- `docs/` architecture, API plan, and testing notes

## Verification

Phone, National ID, TVET, and overall status are stored as `pending`, `verified`, `rejected`, or `expired`. The app does not call live NIDA or TVET systems. Admin review happens in the verification queue.

## Payment providers

Mock MTN, Airtel, and card providers sit behind `PaymentGateway`. Swap those classes for live providers without changing booking screens. Do not put production MoMo secrets in this repository.
