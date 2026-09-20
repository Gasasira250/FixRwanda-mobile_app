# Interview demonstration — FixRwanda

## One-sentence pitch

FixRwanda is a Rwanda marketplace where a customer finds a **verified** plumber, electrician or cleaner, books a job, pays with mock **MTN MoMo / Airtel Money / card**, then tracks status and cancels with **server-side refund rules**.

## Architecture to draw

```text
Flutter app (this folder)
        │  REST + JWT
        ▼
Node.js / Express API
        │
   PostgreSQL          Mock payment providers
        │
   Admin dashboard     (/admin)
```

Flutter never decides ID/TVET verification or refund amounts. It displays `verificationStatus` and the refund quote returned by the API.

## Demo path (about 4 minutes)

1. Open the app → splash → **Use demo account**.
2. Home: search + service chips. Open **Electrician**.
3. Open Jean Mugabo → show **Verified professional** (TVET + ID).
4. Book → payment → choose **MTN MoMo** → Pay now (simulated).
5. Track booking. Use **Demo: professional app** to move Confirmed → En route → Arrived → In progress → Completed.
6. Create a second booking, start the journey, then **Cancel**. Show 2,000 RWF transport fee and 28,000 RWF refund.
7. Optionally open http://127.0.0.1:4000/admin/ as `admin@fixrwanda.rw` / `admin123` and verify Patrick (pending carpenter).

## Refund rules (backend/src/refunds.js)

| Status | Can cancel? | Fee | Refund |
| --- | --- | --- | --- |
| Confirmed | Yes | 0 | 100% |
| En route / Arrived | Yes | 2,000 RWF transport | Remainder |
| In progress | Yes | 50% | 50% |
| Completed | No | — | — |

## Talking points if asked “why not calculate refunds in Flutter?”

A modified APK could request a full refund after the professional has started travelling. The API and PostgreSQL are the source of truth.

## Environment notes

- Flutter 3.47 and Node 24 are installed.
- The API runs without PostgreSQL (in-memory) and with PostgreSQL via Docker on port 5433.
- Android SDK is not installed on this PC yet, so use **Windows** or **Chrome** for the live demo. APK/AAB wait until Android Studio is installed.
