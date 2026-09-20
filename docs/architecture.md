# Architecture

FixRwanda is a Kigali, English-language marketplace. Customers search verified professionals, book a visit, pay into escrow, track the technician, cancel under published rules, and leave one review after completion.

## Layers

```
UI (screens, widgets)
  -> MarketplaceController (state)
    -> Repositories (auth, professionals, bookings, reviews, admin, verification)
      -> Domain (lifecycle, broadcast, cancellation, commission, NIDA, verification pipeline)
      -> EscrowService / LocationSource
        -> LocalMarketplaceStore today
        -> Express API + PostgreSQL (`backend/`)
```

UI never talks to payment providers or SQL. Booking status changes go through `BookingLifecycle`. Client funds sit in `EscrowService` (MTN MoMo Collection `RequestToPay` and Disbursement `Transfer`, or IremboPay). Refunds go through `CancellationPolicy`. Commission is 15% marketplace / 85% provider, released only after the provider enters the 4-digit code from the client screen.

## Job and escrow lifecycle

`pending -> broadcasting -> accepted -> enRoute -> arrived -> inProgress (before photo + OTP) -> completed`

Disputes can open from `inProgress`. Admin can refund escrow or override payout.

Payment states: `INITIATED -> HELD_IN_ESCROW -> DISBURSED_TO_PROVIDER | REFUNDED`.

Cash to the technician is not allowed. After escrow, the closest verified technician in Gasabo, Kicukiro, or Nyarugenge is offered first. If they do not accept in 15 minutes, the next 3 closest verified providers are offered. If nobody remains, the request expires and escrow is refunded.

## Verification

Providers complete NIDA + Smile ID liveness, an Irembo Good Conduct Certificate, and a TVET/IPRC diploma or RDB registration. The Kigali Green Badge is issued only when all three pass. Only badge holders receive job offers.

## Location

While status is `EN_ROUTE`, the provider app sends live coordinates through `geolocator`. The Node API streams them over socket.io.

## Status of this build

| Area | Status |
| --- | --- |
| Customer search, book, pay, cancel, review | Implemented |
| Auth session persistence | `shared_preferences` |
| Escrow + 15-minute cascade + completion OTP | Implemented |
| Provider verification pipeline + Green Badge | Implemented |
| Live technician GPS | Implemented (`geolocator` + socket.io) |
| Admin disputes, photos, chat, refund/payout | Implemented |
| Payment providers | Mocked; same interface for live MTN/IremboPay |
| Hosted API + PostgreSQL | Schema and Express controllers in `backend/` |
