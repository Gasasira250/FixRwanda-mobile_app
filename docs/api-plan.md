# API plan

The Flutter app uses `LocalMarketplaceStore` today. The contracts in `lib/repositories` are the API surface to host later.

## Planned endpoints

| Method | Path | Auth | Notes |
| --- | --- | --- | --- |
| POST | `/auth/signup` | No | Create customer or professional |
| POST | `/auth/login` | No | Email/phone + password, JWT |
| GET | `/me` | Yes | Current user |
| GET | `/professionals` | No | `q`, `category`, `location`, `minRating`, `maxPrice`, `verifiedOnly`, `sort` |
| GET | `/professionals/:id` | No | Profile, services, reviews |
| POST | `/bookings` | Customer | Creates `pending` booking |
| GET | `/bookings` | Customer | Own bookings |
| GET | `/bookings/:id` | Owner/admin | Detail |
| POST | `/bookings/:id/pay` | Customer | Charge via configured provider |
| POST | `/bookings/:id/cancel` | Customer | Server calculates fee/refund |
| POST | `/bookings/:id/status` | Professional/admin | Valid transitions only |
| POST | `/reviews` | Customer | Completed booking, one review |
| GET | `/admin/verifications` | Admin | Pending professionals |
| POST | `/admin/verifications/:id` | Admin | `verified` or `rejected` |

## Payments

`POST /bookings/:id/pay` should call the configured MTN, Airtel, or card provider. Until live credentials exist, keep mock providers behind the same interface. Never store production secrets in git.

## Database

See `backend/sql/schema.sql` for `users`, `professionals`, `services`, `professional_services`, `verifications`, `bookings`, `payments`, `reviews`, `commissions`, and `refunds`.
