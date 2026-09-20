# FixRwanda

FixRwanda is a Kigali marketplace for finding, booking, paying, and reviewing verified local professionals. The market language is English. Prices are in RWF.

**Live app:** https://gasasira250.github.io/FixRwanda-mobile_app/  
**Install on phone:** https://gasasira250.github.io/FixRwanda-mobile_app/install.html  
**Android APK:** https://github.com/Gasasira250/FixRwanda-mobile_app/releases/latest

## What you can do

- Search verified technicians in Gasabo, Kicukiro, and Nyarugenge
- Hold payment in escrow (MTN MoMo / IremboPay interface). Cash to the technician is not allowed
- Offer the closest Kigali Green Badge provider first; if they do not accept in 15 minutes, route to the next 3 closest
- Show a 4-digit code on the client screen; the provider must enter it to receive 85%
- Track the technician live while they are en route
- Complete NIDA, Irembo good-conduct, and TVET/RDB verification to earn the Kigali Green Badge
- Open a dispute; admin can refund escrow or override payout

## Run the app

```powershell
cd C:\Users\PC\OneDrive\Desktop\fix_rwanda
flutter pub get
flutter run
```

In Android Studio, open this folder and run `lib/main.dart`.

Local store sign-in:

- Customer: `hannington@fixrwanda.rw` / `rwanda123`
- Provider: `jean@fixrwanda.rw` / `rwanda123`
- Admin: `admin@fixrwanda.rw` / `admin123`

To see a declined MoMo collection, use a phone number ending in `0000`.

## Project layout

- `lib/screens` UI including live tracker, OTP, onboarding, admin disputes
- `lib/domain` booking lifecycle, broadcast router, NIDA, verification pipeline
- `lib/payments` escrow (Collection + Disbursement)
- `backend/src` Express API, socket.io, MoMo escrow controllers
- `docs/` architecture, API plan, and testing notes
