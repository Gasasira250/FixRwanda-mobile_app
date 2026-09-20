# FixRwanda phase checklist

| Phase | Item | Status |
| --- | --- | --- |
| 1 | Windows + Flutter + VS Code | Done. Flutter 3.47, Dart 3.13. |
| 2 | Create Flutter project | Done in `Desktop\fix_rwanda`. |
| 3 | Architecture + dependencies | Flutter + Express + PostgreSQL/PGlite. |
| 4 | Theme, splash, login, register | Demo: `hannington@fixrwanda.rw` / `demo123`. |
| 5 | Home, services, search | 14 service categories. |
| 6 | Professionals + verification | 18 professionals. Patrick stays pending until admin verifies. |
| 7 | Booking system | Date, time, location, summary. |
| 8 | Mock MTN / Airtel / card | Simulated charge. |
| 9 | Booking tracking | Confirmed → En route → Arrived → In progress → Completed. |
| 10 | Cancellation + refunds | API is the source of truth (`backend/src/refunds.js`). |
| 11 | Auth / state | JWT + `AppController`. |
| 12 | REST integration | Android emulator uses `http://10.0.2.2:4000/api`. |
| 13 | Node.js + Express | Port 4000. |
| 14 | PostgreSQL | Schema + seed. PGlite when Docker Postgres is down. |
| 15 | Flutter → API → PostgreSQL | Populated: 18 pros, 14 trades, 6 demo bookings. |
| 16 | Emulator + phone | Toolchain ready. Sideload `Desktop\FixRwanda.apk`, or create a device in Android Studio Device Manager then `flutter run`. |
| 17 | Postman | `docs/FixRwanda.postman_collection.json` and `npm run test:api`. |
| 18 | Android APK/AAB | Done. APK 50.5MB at `build\app\outputs\flutter-apk\app-release.apk` (also `Desktop\FixRwanda.apk`). AAB 49.2MB at `build\app\outputs\bundle\release\app-release.aab`. |
| 19 | Web/admin dashboard | http://127.0.0.1:4000/admin/ (`admin@fixrwanda.rw` / `admin123`). |
| 20 | Hosting | `render.yaml`. Needs GitHub + Render. |
| 21 | GitHub + README | README is ready. Run `gh auth login` to publish. |
| 22 | Interview demo | `docs/INTERVIEW.md`. |

## Demo data already loaded

Sign in as Hannington. Bookings tab includes:

- FR-100001 confirmed (Jean, MTN)
- FR-100002 en route (Aline, Airtel)
- FR-100003 completed (Eric, card)
- FR-100004 cancelled with 2,000 RWF fee (Samuel, MTN)
- FR-100005 in progress (Grace, card)
- FR-100006 arrived (Diane, Airtel)
