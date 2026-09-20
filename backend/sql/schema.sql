-- FixRwanda PostgreSQL schema.
-- Authentication uses bcrypt password_hash. Customers sign in with email or phone.

CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT UNIQUE,
  phone TEXT UNIQUE,
  password_hash TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'customer',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS service_categories (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  icon TEXT NOT NULL,
  sort_order INT NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS professionals (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  trade TEXT NOT NULL,
  category_id TEXT REFERENCES service_categories(id),
  location TEXT NOT NULL,
  about TEXT,
  rating NUMERIC(3,2) NOT NULL DEFAULT 0,
  jobs_completed INT NOT NULL DEFAULT 0,
  service_fee_rwf INT NOT NULL,
  tvet_verified BOOLEAN NOT NULL DEFAULT FALSE,
  id_verified BOOLEAN NOT NULL DEFAULT FALSE,
  verification_status TEXT NOT NULL DEFAULT 'pending',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS professional_services (
  professional_id TEXT REFERENCES professionals(id) ON DELETE CASCADE,
  service_name TEXT NOT NULL,
  PRIMARY KEY (professional_id, service_name)
);

CREATE TABLE IF NOT EXISTS bookings (
  id TEXT PRIMARY KEY,
  customer_id TEXT REFERENCES users(id),
  professional_id TEXT REFERENCES professionals(id),
  service TEXT NOT NULL,
  scheduled_at TIMESTAMPTZ NOT NULL,
  location TEXT NOT NULL,
  description TEXT,
  service_fee_rwf INT NOT NULL,
  status TEXT NOT NULL,
  payment_method TEXT,
  paid BOOLEAN NOT NULL DEFAULT FALSE,
  payment_reference TEXT,
  cancellation_fee_rwf INT,
  refund_amount_rwf INT,
  cancelled_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE bookings ADD COLUMN IF NOT EXISTS payment_status TEXT NOT NULL DEFAULT 'unpaid';

CREATE TABLE IF NOT EXISTS payments (
  id TEXT PRIMARY KEY,
  booking_id TEXT REFERENCES bookings(id),
  method TEXT NOT NULL,
  amount_rwf INT NOT NULL,
  status TEXT NOT NULL,
  provider_reference TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
