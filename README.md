# FixRwanda

FixRwanda helps people in Rwanda find verified professionals, book a job, pay with MTN MoMo, Airtel Money or card, then track or cancel the booking.

**Live app:** https://gasasira250.github.io/FixRwanda-mobile_app/

## Run

API:

```powershell
cd backend
copy .env.example .env
npm install
npm start
```

- API: http://127.0.0.1:4000
- Admin: http://127.0.0.1:4000/admin/
- Health: http://127.0.0.1:4000/health

Flutter:

```powershell
flutter pub get
flutter run
```

Android emulator uses `http://10.0.2.2:4000/api`. On a physical phone, pass your PC LAN address:

```powershell
flutter run -d <deviceId> --dart-define=API_BASE=http://192.168.1.10:4000/api
```

```powershell
flutter build apk --release
```

## Accounts

| Role | Email / phone | Password |
| --- | --- | --- |
| Customer | `hannington@fixrwanda.rw` or `0780000000` | `demo123` |
| Customer | `aline@fixrwanda.rw` | `demo123` |
| Admin | `admin@fixrwanda.rw` | `admin123` |

## Layout

```text
lib/        Flutter app
backend/   Express API
admin/      Admin dashboard
```

```powershell
flutter test
```
