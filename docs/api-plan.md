# API plan

The Flutter app uses `LocalMarketplaceStore` today. Express controllers in `backend/src` are the hosted contracts.

## Endpoints

| Method | Path | Auth | Notes |
| --- | --- | --- | --- |
| POST | `/auth/signup` | No | Create customer or professional |
| POST | `/auth/login` | No | Email/phone + password, JWT |
| GET | `/me` | Yes | Current user |
| GET | `/professionals` | No | Filters including verified / green badge |
| POST | `/bookings` | Customer | Creates `pending` / `REQUESTED` booking |
| POST | `/bookings/:id/pay` | Customer | MTN Collection `RequestToPay` |
| POST | `/webhooks/momo/collection` | Provider | Sets `HELD_IN_ESCROW` and starts broadcast |
| POST | `/bookings/:id/complete` | Provider | OTP then Disbursement `Transfer` of 85% |
| POST | `/bookings/:id/location` | Provider | Live EN_ROUTE coordinates |
| POST | `/bookings/:id/dispute` | Customer | Opens `DISPUTED` while escrow is held |
| POST | `/admin/bookings/:id/refund` | Admin | Manual escrow refund |
| POST | `/admin/bookings/:id/payout` | Admin | Manual payout override |
| GET | `/admin/verifications` | Admin | Pending professionals |
| POST | `/reviews` | Customer | Completed booking, one review |

Socket.io events: `join_job`, `provider_location`, `location`.

## Payments

Until live credentials exist, keep mock MoMo behind the same interface. Numbers ending in `0000` fail collection. Never store production secrets in git.

## Database

See `backend/sql/schema.sql` for escrow payment states, OTP, before/after photos, disputes, and location pings.
