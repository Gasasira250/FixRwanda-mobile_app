-- FixRwanda marketplace schema (PostgreSQL)
-- Planned for the hosted API. The Flutter app currently uses a local store.

CREATE TABLE users (
  id TEXT PRIMARY KEY,
  full_name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  phone_number TEXT NOT NULL,
  password_hash TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('customer', 'professional', 'admin')),
  profile_image_url TEXT,
  address TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE professionals (
  id TEXT PRIMARY KEY,
  user_id TEXT REFERENCES users(id),
  name TEXT NOT NULL,
  category TEXT NOT NULL,
  description TEXT NOT NULL,
  location TEXT NOT NULL,
  sector TEXT,
  starting_price INTEGER NOT NULL,
  rating NUMERIC(3,1) NOT NULL DEFAULT 0,
  completed_jobs INTEGER NOT NULL DEFAULT 0,
  phone_verified BOOLEAN NOT NULL DEFAULT FALSE,
  id_verified BOOLEAN NOT NULL DEFAULT FALSE,
  certificate_verified BOOLEAN NOT NULL DEFAULT FALSE,
  kigali_green_badge BOOLEAN NOT NULL DEFAULT FALSE,
  nida_number TEXT,
  irembo_cert_url TEXT,
  trade_cert_url TEXT,
  trade_cert_kind TEXT CHECK (trade_cert_kind IN ('tvet_iprc', 'rdb_business')),
  smile_job_id TEXT,
  liveness_selfie_ref TEXT,
  verification_status TEXT NOT NULL CHECK (
    verification_status IN ('pending', 'verified', 'rejected', 'expired')
  )
);

CREATE TABLE services (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  category TEXT NOT NULL,
  icon_name TEXT NOT NULL
);

CREATE TABLE professional_services (
  professional_id TEXT NOT NULL REFERENCES professionals(id),
  service_id TEXT NOT NULL REFERENCES services(id),
  price_rwf INTEGER NOT NULL,
  PRIMARY KEY (professional_id, service_id)
);

CREATE TABLE verifications (
  id TEXT PRIMARY KEY,
  professional_id TEXT NOT NULL REFERENCES professionals(id),
  kind TEXT NOT NULL CHECK (kind IN ('phone', 'national_id', 'liveness', 'irembo', 'tvet', 'rdb', 'overall')),
  status TEXT NOT NULL CHECK (status IN ('pending', 'verified', 'rejected', 'expired')),
  notes TEXT,
  reviewed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TYPE booking_status AS ENUM (
  'REQUESTED',
  'BROADCASTING',
  'ACCEPTED',
  'EN_ROUTE',
  'ARRIVED',
  'IN_PROGRESS',
  'AWAITING_OTP',
  'COMPLETED',
  'DISPUTED',
  'CANCELLED',
  'EXPIRED'
);

CREATE TYPE payment_state AS ENUM (
  'INITIATED',
  'HELD_IN_ESCROW',
  'DISBURSED_TO_PROVIDER',
  'REFUNDED'
);

CREATE TABLE bookings (
  id TEXT PRIMARY KEY,
  customer_id TEXT NOT NULL REFERENCES users(id),
  professional_id TEXT REFERENCES professionals(id),
  service_id TEXT NOT NULL,
  service_name TEXT NOT NULL,
  category TEXT NOT NULL,
  scheduled_date DATE NOT NULL,
  scheduled_time TEXT NOT NULL,
  customer_address TEXT NOT NULL,
  district TEXT,
  sector TEXT,
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  provider_latitude DOUBLE PRECISION,
  provider_longitude DOUBLE PRECISION,
  last_location_at TIMESTAMPTZ,
  service_price INTEGER NOT NULL,
  amount_rwf INTEGER NOT NULL,
  platform_fee_rwf INTEGER NOT NULL DEFAULT 0,
  status TEXT NOT NULL CHECK (
    status IN (
      'pending',
      'broadcasting',
      'accepted',
      'enRoute',
      'arrived',
      'inProgress',
      'awaitingOtp',
      'completed',
      'disputed',
      'cancelled',
      'expired'
    )
  ),
  payment_state TEXT NOT NULL DEFAULT 'INITIATED' CHECK (
    payment_state IN (
      'INITIATED',
      'HELD_IN_ESCROW',
      'DISBURSED_TO_PROVIDER',
      'REFUNDED'
    )
  ),
  otp_code VARCHAR(4),
  completion_otp TEXT,
  start_job_photo_ref TEXT,
  before_photo_url TEXT,
  after_photo_url TEXT,
  dispute_reason TEXT,
  started_at TIMESTAMPTZ,
  broadcast_expires_at TIMESTAMPTZ,
  cancellation_fee_rwf INTEGER,
  refund_amount_rwf INTEGER,
  cancelled_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE job_messages (
  id TEXT PRIMARY KEY,
  booking_id TEXT NOT NULL REFERENCES bookings(id),
  sender_id TEXT NOT NULL REFERENCES users(id),
  sender_name TEXT NOT NULL,
  body TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE location_pings (
  id TEXT PRIMARY KEY,
  booking_id TEXT NOT NULL REFERENCES bookings(id),
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE escrow_holds (
  id TEXT PRIMARY KEY,
  booking_id TEXT NOT NULL REFERENCES bookings(id),
  amount INTEGER NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('none', 'held', 'released', 'refunded')),
  provider_payout INTEGER NOT NULL DEFAULT 0,
  marketplace_fee INTEGER NOT NULL DEFAULT 0,
  provider_reference TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  released_at TIMESTAMPTZ,
  refunded_at TIMESTAMPTZ
);

CREATE TABLE payments (
  id TEXT PRIMARY KEY,
  booking_id TEXT NOT NULL REFERENCES bookings(id),
  method TEXT NOT NULL CHECK (method IN ('mtnMomo', 'airtelMoney', 'card')),
  amount INTEGER NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('pending', 'success', 'failed')),
  transaction_reference TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE reviews (
  id TEXT PRIMARY KEY,
  booking_id TEXT NOT NULL UNIQUE REFERENCES bookings(id),
  customer_id TEXT NOT NULL REFERENCES users(id),
  professional_id TEXT NOT NULL REFERENCES professionals(id),
  rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE commissions (
  id TEXT PRIMARY KEY,
  booking_id TEXT NOT NULL REFERENCES bookings(id),
  gross_amount INTEGER NOT NULL,
  commission_rate NUMERIC(4,3) NOT NULL,
  commission_amount INTEGER NOT NULL,
  professional_payout INTEGER NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE refunds (
  id TEXT PRIMARY KEY,
  booking_id TEXT NOT NULL REFERENCES bookings(id),
  amount INTEGER NOT NULL,
  fee INTEGER NOT NULL DEFAULT 0,
  status TEXT NOT NULL CHECK (status IN ('pending', 'success', 'failed')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
