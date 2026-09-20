# Architecture

FixRwanda is a Kigali, English-language marketplace. Customers search verified professionals, book a visit, pay, track job status, cancel under published rules, and leave one review after completion.

## Layers

```
UI (screens, widgets)
  -> MarketplaceController (state)
    -> Repositories (auth, professionals, bookings, reviews, admin)
      -> Domain (lifecycle, cancellation, commission)
      -> PaymentGateway / PaymentProvider
        -> LocalMarketplaceStore today
        -> HTTP API later
          -> PostgreSQL
```

UI never talks to payment providers or SQL. Booking status changes go through `BookingLifecycle`. Refunds go through `CancellationPolicy`. Commission is calculated by `CommissionService` (10–15%).

## Booking status

`pending -> confirmed -> enRoute -> arrived -> inProgress -> completed`

Cancellation is allowed from `pending`, `confirmed`, `enRoute`, and `arrived`. It is not allowed from `inProgress` or `completed`.

Refunds:

- Confirmed / pending, professional not travelling: full refund
- En route or arrived: 2,000 RWF transport fee, remainder refunded
- In progress or completed: no cancellation

Failed payments leave the booking in `pending`. Successful payments move it to `confirmed` and record commission.

## Verification

Each professional has phone, National ID, TVET, and overall status. Overall `verified` is required before booking. These flags are reviewed in-app. They are not live government API results.

## Location

Bookings store district, sector, and street address, with optional lat/lng in the planned schema.

## Status of this build

| Area | Status |
| --- | --- |
| Customer search, book, pay, cancel, review | Implemented against local store |
| Auth session persistence | Implemented with `shared_preferences` |
| Payment providers | Mocked; interface is ready for live MTN/Airtel/card |
| Admin verification queue | Implemented locally |
| Hosted API + PostgreSQL | Planned (`backend/sql/schema.sql`) |
| Live technician GPS | Planned |
| NIDA / TVET APIs | Not connected |
