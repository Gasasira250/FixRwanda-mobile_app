# FixRwanda

Book **verified** home and business professionals across Rwanda. Customers search a trade, view ID/TVET verification, book a job, pay with **MTN MoMo**, **Airtel Money** or **card**, then track status and cancel with server-side refund rules.

**Live web app:** https://gasasira250.github.io/FixRwanda-mobile_app/

The GitHub Pages site runs the Flutter web client. If the API is not hosted, the app still loads professionals and bookings from the built-in catalog.

```text
Flutter app  →  Express REST API  →  PostgreSQL
                              ↘  Admin dashboard
                              ↘  Mock MTN / Airtel / card
```

## Demo accounts

| Role | Phone / email | Password |
| --- | --- | --- |
| Customer | `hannington@fixrwanda.rw` or `0780000000` | `demo123` |
| Customer | `aline@fixrwanda.rw` | `demo123` |
| Admin | `admin@fixrwanda.rw` | `admin123` |

Payment is simulated. No real money is charged.

## Run locally

### 1. API

```powershell
cd backend
copy .env.example .env
npm install
npm start
```

API: http://127.0.0.1:4000  
Admin: http://127.0.0.1:4000/admin/  
Health: http://127.0.0.1:4000/health

If PostgreSQL is not running, the API starts an embedded **PGlite** Postgres engine (same SQL schema) so bookings still persist. `GET /health` reports `"store": "pglite"`.

To use Docker Postgres on port **5433** instead:

```powershell
docker compose up -d db
```

Then restart the API. Health should report `"store": "postgresql"`.

Full stack:

```powershell
docker compose up --build
```

### 3. Flutter app

Open this folder in VS Code / Cursor (`File → Open Folder → Desktop\fix_rwanda`), then:

```powershell
flutter pub get
flutter run
```

Pick **Windows**, **Chrome**, an **Android emulator**, or a **physical phone**.

The demo account already has 6 bookings (confirmed, en route, arrived, in progress, completed, cancelled) and 18 professionals across 14 trades.

```powershell
flutter run -d windows
flutter run -d chrome
flutter run -d android
```

Android emulator talks to the API at `http://10.0.2.2:4000/api`. On a physical phone, use your PC’s LAN IP:

```powershell
flutter run -d <deviceId> --dart-define=API_BASE=http://192.168.1.10:4000/api
```

Build installers:

```powershell
flutter build apk --release
flutter build appbundle --release
```

Release builds (already produced on this machine):

- APK (50.5MB): `build\app\outputs\flutter-apk\app-release.apk` and `Desktop\FixRwanda.apk`
- AAB (49.2MB): `build\app\outputs\bundle\release\app-release.aab`

Install the APK on a phone with USB debugging, or copy `Desktop\FixRwanda.apk` onto the device. Keep the API running on the PC (`http://127.0.0.1:4000`). On a physical phone, rebuild/run with your LAN IP:

```powershell
flutter run -d <deviceId> --dart-define=API_BASE=http://192.168.1.9:4000/api
```

## Product flow

Login → Home / search → Professional profile + verification badge → Book → Mock payment → Booking status → Cancel / refund

Cancellation (source of truth: `backend/src/refunds.js`, mirrored in `lib/services/refund_policy.dart` for offline tests):

- **Confirmed:** full refund
- **En route or arrived:** 2,000 RWF transport fee, remainder refunded
- **In progress:** 50% refund
- **Completed:** cannot cancel

Unverified professionals (example: Patrick in Musanze) cannot be booked until an admin verifies them.

## Project layout

```text
lib/                  Flutter app (UI, state, REST client)
backend/             Node.js + Express + PostgreSQL
admin/                Web dashboard
docs/                 Postman collection + interview script
docker-compose.yml    Postgres 16 + API
```

## Testing

```powershell
flutter test
```

Import `docs/FixRwanda.postman_collection.json` into Postman. Login requests save JWT tokens automatically.

## Android APK / AAB (after Android Studio)

```powershell
flutter build apk --release
flutter build appbundle --release
```

## Hosting

- **GitHub Pages (web app):** https://gasasira250.github.io/FixRwanda-mobile_app/
- **API (Render):** open [Deploy to Render](https://render.com/deploy?repo=https://github.com/Gasasira250/FixRwanda-mobile_app), sign in, and create the `fixrwanda-api` service from `render.yaml`. After it is live, rebuild the web app with `--dart-define=API_BASE=https://YOUR-SERVICE.onrender.com/api`.

## GitHub

```powershell
git init
git add .
git commit -m "Add FixRwanda marketplace app, API and admin dashboard."
gh repo create fix_rwanda --public --source=. --push
```

## Interview

See [docs/INTERVIEW.md](docs/INTERVIEW.md) for the 4-minute demo path and architecture talking points.
