import bcrypt from 'bcryptjs';
import { query, state } from './db.js';

const CATEGORIES = [
  { id: 'electrician', name: 'Electrician', icon: '⚡', sort_order: 1 },
  { id: 'plumber', name: 'Plumber', icon: '🔧', sort_order: 2 },
  { id: 'cleaner', name: 'Cleaner', icon: '🧹', sort_order: 3 },
  { id: 'painter', name: 'Painter', icon: '🎨', sort_order: 4 },
  { id: 'carpenter', name: 'Carpenter', icon: '🪚', sort_order: 5 },
  { id: 'hvac', name: 'AC & Fridge', icon: '❄️', sort_order: 6 },
  { id: 'phone', name: 'Phone repair', icon: '📱', sort_order: 7 },
  { id: 'stylist', name: 'Stylist', icon: '💇', sort_order: 8 },
  { id: 'mason', name: 'Mason', icon: '🧱', sort_order: 9 },
  { id: 'tiler', name: 'Tiler', icon: '⬜', sort_order: 10 },
  { id: 'mechanic', name: 'Mechanic', icon: '🚗', sort_order: 11 },
  { id: 'gardener', name: 'Gardener', icon: '🌿', sort_order: 12 },
  { id: 'locksmith', name: 'Locksmith', icon: '🔑', sort_order: 13 },
  { id: 'welder', name: 'Welder', icon: '🛠️', sort_order: 14 },
];

const PROFESSIONALS = [
  {
    id: 'pro-jean',
    name: 'Jean Mugabo Electrical',
    trade: 'Electrician',
    category_id: 'electrician',
    location: 'Kimironko, Kigali',
    about: 'Licensed electrician for homes and shops across Kigali.',
    rating: 4.8,
    jobs_completed: 126,
    service_fee_rwf: 30000,
    tvet_verified: true,
    id_verified: true,
    verification_status: 'verified',
    services: [
      'House wiring',
      'Socket repair',
      'Lighting install',
      'Fuse box repair',
      'Ceiling fan install',
      'Generator hookup',
      'Fault finding',
      'Intercom wiring',
    ],
  },
  {
    id: 'pro-aline',
    name: 'Aline Uwase Plumbing',
    trade: 'Plumber',
    category_id: 'plumber',
    location: 'Nyamirambo, Kigali',
    about: 'Fast leak repair and bathroom fitting.',
    rating: 4.7,
    jobs_completed: 94,
    service_fee_rwf: 25000,
    tvet_verified: true,
    id_verified: true,
    verification_status: 'verified',
    services: [
      'Leak repair',
      'Pipe installation',
      'Bathroom fitting',
      'Toilet install',
      'Kitchen sink',
      'Drain unblocking',
      'Water pump',
      'Mixer tap fitting',
    ],
  },
  {
    id: 'pro-eric',
    name: 'Eric Niyonzima Cleaning',
    trade: 'Cleaner',
    category_id: 'cleaner',
    location: 'Remera, Kigali',
    about: 'Home and office deep cleaning.',
    rating: 4.9,
    jobs_completed: 210,
    service_fee_rwf: 18000,
    tvet_verified: true,
    id_verified: true,
    verification_status: 'verified',
    services: [
      'Home cleaning',
      'Office cleaning',
      'Deep cleaning',
      'After-party clean',
      'Carpet shampoo',
      'Window washing',
      'Kitchen degrease',
      'Move-out clean',
    ],
  },
  {
    id: 'pro-claudine',
    name: 'Claudine Mukamana Paint',
    trade: 'Painter',
    category_id: 'painter',
    location: 'Huye',
    about: 'Interior and exterior painting in Southern Province.',
    rating: 4.6,
    jobs_completed: 71,
    service_fee_rwf: 22000,
    tvet_verified: true,
    id_verified: true,
    verification_status: 'verified',
    services: [
      'Interior painting',
      'Exterior painting',
      'Touch-up',
      'Ceiling painting',
      'Weatherproof coat',
      'Skirting boards',
      'Feature wall',
      'Wood varnish',
    ],
  },
  {
    id: 'pro-patrick',
    name: 'Patrick Habimana Woodworks',
    trade: 'Carpenter',
    category_id: 'carpenter',
    location: 'Musanze',
    about: 'ID submitted. TVET certificate is still under admin review.',
    rating: 4.5,
    jobs_completed: 40,
    service_fee_rwf: 28000,
    tvet_verified: false,
    id_verified: true,
    verification_status: 'pending',
    services: [
      'Doors',
      'Furniture repair',
      'Kitchen cabinets',
      'Wardrobes',
      'Window frames',
      'Table restore',
      'Bed frames',
      'Skirting fit',
    ],
  },
  {
    id: 'pro-samuel',
    name: 'Samuel Kwizera Cooling',
    trade: 'AC & Fridge',
    category_id: 'hvac',
    location: 'Gisozi, Kigali',
    about: 'AC service, fridge repair and gas refill.',
    rating: 4.8,
    jobs_completed: 88,
    service_fee_rwf: 35000,
    tvet_verified: true,
    id_verified: true,
    verification_status: 'verified',
    services: [
      'AC service',
      'Fridge repair',
      'Gas refill',
      'AC installation',
      'Deep freezer',
      'Cooler service',
      'Thermostat replace',
      'Filter cleaning',
    ],
  },
  {
    id: 'pro-nadine',
    name: 'Nadine Phone Clinic',
    trade: 'Phone repair',
    category_id: 'phone',
    location: 'Rubavu',
    about: 'Screens, batteries and software on the Rwanda–DRC border towns.',
    rating: 4.7,
    jobs_completed: 156,
    service_fee_rwf: 15000,
    tvet_verified: true,
    id_verified: true,
    verification_status: 'verified',
    services: [
      'Screen replacement',
      'Battery',
      'Software',
      'Charging port',
      'Camera repair',
      'Speaker repair',
      'Water damage',
      'Phone unlock',
    ],
  },
  {
    id: 'pro-grace',
    name: 'Grace Style House',
    trade: 'Stylist',
    category_id: 'stylist',
    location: 'Kacyiru, Kigali',
    about: 'Braiding and event styling.',
    rating: 4.9,
    jobs_completed: 64,
    service_fee_rwf: 12000,
    tvet_verified: false,
    id_verified: true,
    verification_status: 'verified',
    services: [
      'Braiding',
      'Haircut',
      'Event styling',
      'Makeup',
      'Nails',
      'Weave install',
      'Kids haircut',
      'Bridal styling',
    ],
  },
  {
    id: 'pro-olivier',
    name: 'Olivier Mason Works',
    trade: 'Mason',
    category_id: 'mason',
    location: 'Gasabo, Kigali',
    about: 'Foundations, plaster and small home extensions.',
    rating: 4.6,
    jobs_completed: 58,
    service_fee_rwf: 40000,
    tvet_verified: true,
    id_verified: true,
    verification_status: 'verified',
    services: [
      'Plaster',
      'Block work',
      'Small extension',
      'Foundation',
      'Floor screed',
      'Boundary wall',
      'Concrete slab',
      'Brick pointing',
    ],
  },
  {
    id: 'pro-diane',
    name: 'Diane Tile Studio',
    trade: 'Tiler',
    category_id: 'tiler',
    location: 'Kicukiro, Kigali',
    about: 'Bathroom and kitchen tiling with neat finishing.',
    rating: 4.8,
    jobs_completed: 102,
    service_fee_rwf: 27000,
    tvet_verified: true,
    id_verified: true,
    verification_status: 'verified',
    services: [
      'Bathroom tiles',
      'Kitchen backsplash',
      'Floor tiles',
      'Waterproofing',
      'Grout refresh',
      'Stair tiles',
      'Outdoor paving',
      'Mosaic work',
    ],
  },
  {
    id: 'pro-bosco',
    name: 'Bosco Auto Fix',
    trade: 'Mechanic',
    category_id: 'mechanic',
    location: 'Nyabugogo, Kigali',
    about: 'Car diagnostics, brakes and general service.',
    rating: 4.5,
    jobs_completed: 190,
    service_fee_rwf: 32000,
    tvet_verified: true,
    id_verified: true,
    verification_status: 'verified',
    services: [
      'Engine check',
      'Brake service',
      'Oil change',
      'Battery jump',
      'Tyre change',
      'Suspension',
      'Clutch repair',
      'Computer diagnostics',
    ],
  },
  {
    id: 'pro-immaculee',
    name: 'Immaculée Gardens',
    trade: 'Gardener',
    category_id: 'gardener',
    location: 'Nyarutarama, Kigali',
    about: 'Lawn care, hedges and compound cleanup.',
    rating: 4.9,
    jobs_completed: 77,
    service_fee_rwf: 16000,
    tvet_verified: false,
    id_verified: true,
    verification_status: 'verified',
    services: [
      'Lawn mowing',
      'Hedge trim',
      'Compound cleanup',
      'Flower beds',
      'Tree pruning',
      'Irrigation setup',
      'Composting',
      'Potted plants',
    ],
  },
  {
    id: 'pro-kevin',
    name: 'Kevin Lock & Key',
    trade: 'Locksmith',
    category_id: 'locksmith',
    location: 'CBD, Kigali',
    about: 'Emergency lockouts, lock changes and gate keys.',
    rating: 4.7,
    jobs_completed: 83,
    service_fee_rwf: 20000,
    tvet_verified: true,
    id_verified: true,
    verification_status: 'verified',
    services: [
      'Lockout',
      'Lock change',
      'Gate keys',
      'Padlock fit',
      'Safe opening',
      'Cylinder upgrade',
      'Door closer',
      'Duplicate keys',
    ],
  },
  {
    id: 'pro-chantal',
    name: 'Chantal Welding Co',
    trade: 'Welder',
    category_id: 'welder',
    location: 'Rwamagana',
    about: 'Gates, window grills and metal repairs.',
    rating: 4.4,
    jobs_completed: 49,
    service_fee_rwf: 26000,
    tvet_verified: true,
    id_verified: true,
    verification_status: 'verified',
    services: [
      'Gate welding',
      'Window grills',
      'Metal repair',
      'Burglar bars',
      'Steel door',
      'Tank stand',
      'Balcony rail',
      'Trailer hitch',
    ],
  },
  {
    id: 'pro-yves',
    name: 'Yves Power Fix',
    trade: 'Electrician',
    category_id: 'electrician',
    location: 'Huye',
    about: 'Solar backup, distribution boards and lighting.',
    rating: 4.6,
    jobs_completed: 61,
    service_fee_rwf: 28000,
    tvet_verified: true,
    id_verified: true,
    verification_status: 'verified',
    services: [
      'DB board',
      'Solar backup',
      'Lighting',
      'Inverter install',
      'Surge protection',
      'Earthing',
      'Street lights',
      'Meter relocation',
    ],
  },
  {
    id: 'pro-peace',
    name: 'Peace Plumbing Plus',
    trade: 'Plumber',
    category_id: 'plumber',
    location: 'Gisenyi, Rubavu',
    about: 'Water tanks, solar water heaters and leak detection.',
    rating: 4.8,
    jobs_completed: 112,
    service_fee_rwf: 24000,
    tvet_verified: true,
    id_verified: true,
    verification_status: 'verified',
    services: [
      'Tank install',
      'Solar heater',
      'Leak detection',
      'Gutter downpipe',
      'Hot water line',
      'Shower mixer',
      'Toilet cistern',
      'Pressure pump',
    ],
  },
  {
    id: 'pro-solange',
    name: 'Solange Clean Home',
    trade: 'Cleaner',
    category_id: 'cleaner',
    location: 'Kacyiru, Kigali',
    about: 'Move-in cleaning and weekly home plans.',
    rating: 4.7,
    jobs_completed: 134,
    service_fee_rwf: 17000,
    tvet_verified: true,
    id_verified: true,
    verification_status: 'verified',
    services: [
      'Move-in clean',
      'Weekly plan',
      'Laundry help',
      'Ironing',
      'Fridge clean',
      'Bathroom detail',
      'Sofa shampoo',
      'End-of-tenancy',
    ],
  },
  {
    id: 'pro-fabrice',
    name: 'Fabrice Wood & Fit',
    trade: 'Carpenter',
    category_id: 'carpenter',
    location: 'Nyamata',
    about: 'Custom beds, shelves and door hanging.',
    rating: 4.6,
    jobs_completed: 55,
    service_fee_rwf: 29000,
    tvet_verified: true,
    id_verified: true,
    verification_status: 'verified',
    services: [
      'Beds',
      'Shelves',
      'Door hanging',
      'TV stand',
      'Dining table',
      'Room partition',
      'Drawer repair',
      'Ceiling lining',
    ],
  },
];

function publicProfessional(row, services) {
  return {
    id: row.id,
    name: row.name,
    trade: row.trade,
    location: row.location,
    about: row.about,
    rating: Number(row.rating),
    jobsCompleted: row.jobs_completed ?? row.jobsCompleted,
    serviceFeeRwf: row.service_fee_rwf ?? row.serviceFeeRwf,
    tvetVerified: row.tvet_verified ?? row.tvetVerified,
    idVerified: row.id_verified ?? row.idVerified,
    verificationStatus: row.verification_status ?? row.verificationStatus,
    services,
  };
}

function publicBooking(row, professionalName, trade) {
  return {
    id: row.id,
    professionalId: row.professional_id ?? row.professionalId,
    professionalName,
    trade,
    service: row.service,
    scheduledAt: row.scheduled_at ?? row.scheduledAt,
    location: row.location,
    description: row.description,
    serviceFeeRwf: row.service_fee_rwf ?? row.serviceFeeRwf,
    status: row.status,
    paymentMethod: row.payment_method ?? row.paymentMethod,
    paid: row.paid,
    paymentReference: row.payment_reference ?? row.paymentReference,
    paymentStatus: row.payment_status ?? row.paymentStatus ?? (row.paid ? 'Paid' : 'unpaid'),
    cancellationFeeRwf: row.cancellation_fee_rwf ?? row.cancellationFeeRwf,
    refundAmountRwf: row.refund_amount_rwf ?? row.refundAmountRwf,
    cancelledAt: row.cancelled_at ?? row.cancelledAt,
    createdAt: row.created_at ?? row.createdAt,
    customerId: row.customer_id ?? row.customerId,
  };
}

function matchesProfessional(item, { trade, q }) {
  const tradeOk =
    !trade ||
    item.trade.toLowerCase() === trade.toLowerCase() ||
    item.category_id === trade;
  const needle = (q || '').trim().toLowerCase();
  const queryOk =
    !needle ||
    item.name.toLowerCase().includes(needle) ||
    item.trade.toLowerCase().includes(needle) ||
    item.location.toLowerCase().includes(needle) ||
    item.services.some((service) => service.toLowerCase().includes(needle));
  return tradeOk && queryOk;
}

export async function seed() {
  const passwordHash = await bcrypt.hash('demo123', 10);
  const adminHash = await bcrypt.hash('admin123', 10);
  const users = [
    {
      id: 'usr-hannington',
      name: 'Hannington',
      email: 'hannington@fixrwanda.rw',
      phone: '0780000000',
      password_hash: passwordHash,
      role: 'customer',
    },
    {
      id: 'usr-admin',
      name: 'FixRwanda Admin',
      email: 'admin@fixrwanda.rw',
      phone: '0781111111',
      password_hash: adminHash,
      role: 'admin',
    },
    {
      id: 'usr-aline',
      name: 'Aline Uwase',
      email: 'aline@fixrwanda.rw',
      phone: '0782222222',
      password_hash: passwordHash,
      role: 'customer',
    },
  ];

  const demoBookings = demoBookingRows();

  if (!state.postgres) {
    state.users = users;
    state.categories = CATEGORIES;
    state.professionals = PROFESSIONALS.map((item) => ({ ...item }));
    state.bookings = demoBookings.map((item) => ({ ...item }));
    state.payments = demoBookings.map((item) => ({
      id: `pay-${item.id}`,
      booking_id: item.id,
      method: item.payment_method,
      amount_rwf: item.service_fee_rwf,
      status: item.status === 'cancelled' ? 'refunded' : 'success',
      provider_reference: item.payment_reference,
    }));
    state.bookingSeq = demoBookings.length + 1;
    return;
  }

  for (const user of users) {
    await query(
      `INSERT INTO users (id, name, email, phone, password_hash, role)
       VALUES ($1,$2,$3,$4,$5,$6)
       ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, email = EXCLUDED.email, phone = EXCLUDED.phone`,
      [user.id, user.name, user.email, user.phone, user.password_hash, user.role],
    );
  }
  for (const category of CATEGORIES) {
    await query(
      `INSERT INTO service_categories (id, name, icon, sort_order)
       VALUES ($1,$2,$3,$4)
       ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, icon = EXCLUDED.icon, sort_order = EXCLUDED.sort_order`,
      [category.id, category.name, category.icon, category.sort_order],
    );
  }
  for (const pro of PROFESSIONALS) {
    await query(
      `INSERT INTO professionals
        (id, name, trade, category_id, location, about, rating, jobs_completed,
         service_fee_rwf, tvet_verified, id_verified, verification_status)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12)
       ON CONFLICT (id) DO UPDATE SET
         name = EXCLUDED.name, trade = EXCLUDED.trade, category_id = EXCLUDED.category_id,
         location = EXCLUDED.location, about = EXCLUDED.about, rating = EXCLUDED.rating,
         jobs_completed = EXCLUDED.jobs_completed, service_fee_rwf = EXCLUDED.service_fee_rwf,
         tvet_verified = EXCLUDED.tvet_verified, id_verified = EXCLUDED.id_verified,
         verification_status = EXCLUDED.verification_status`,
      [
        pro.id,
        pro.name,
        pro.trade,
        pro.category_id,
        pro.location,
        pro.about,
        pro.rating,
        pro.jobs_completed,
        pro.service_fee_rwf,
        pro.tvet_verified,
        pro.id_verified,
        pro.verification_status,
      ],
    );
    await query('DELETE FROM professional_services WHERE professional_id = $1', [pro.id]);
    for (const service of pro.services) {
      await query(
        `INSERT INTO professional_services (professional_id, service_name)
         VALUES ($1,$2)`,
        [pro.id, service],
      );
    }
  }

  const existing = await query(
    `SELECT COUNT(*)::int AS count FROM bookings WHERE id = 'FR-100001'`,
  );
  if (existing.rows[0].count === 0) {
    for (const booking of demoBookings) {
      await query(
        `INSERT INTO bookings
          (id, customer_id, professional_id, service, scheduled_at, location,
           description, service_fee_rwf, status, payment_method, paid, payment_reference,
           cancellation_fee_rwf, refund_amount_rwf, cancelled_at)
         VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,TRUE,$11,$12,$13,$14)`,
        [
          booking.id,
          booking.customer_id,
          booking.professional_id,
          booking.service,
          booking.scheduled_at,
          booking.location,
          booking.description,
          booking.service_fee_rwf,
          booking.status,
          booking.payment_method,
          booking.payment_reference,
          booking.cancellation_fee_rwf,
          booking.refund_amount_rwf,
          booking.cancelled_at,
        ],
      );
      await query(
        `INSERT INTO payments (id, booking_id, method, amount_rwf, status, provider_reference)
         VALUES ($1,$2,$3,$4,$5,$6)`,
        [
          `pay-${booking.id}`,
          booking.id,
          booking.payment_method,
          booking.service_fee_rwf,
          booking.status === 'cancelled' ? 'refunded' : 'success',
          booking.payment_reference,
        ],
      );
    }
  }
}

function demoBookingRows() {
  const now = new Date();
  const days = (offset) => new Date(now.getTime() + offset * 86400000).toISOString();
  return [
    {
      id: 'FR-100001',
      customer_id: 'usr-hannington',
      professional_id: 'pro-jean',
      service: 'House wiring',
      scheduled_at: days(2),
      location: 'Kimironko, Kigali',
      description: 'Full house rewiring before painting.',
      service_fee_rwf: 30000,
      status: 'confirmed',
      payment_method: 'mtnMomo',
      payment_reference: 'MOM-100001',
      cancellation_fee_rwf: null,
      refund_amount_rwf: null,
      cancelled_at: null,
    },
    {
      id: 'FR-100002',
      customer_id: 'usr-hannington',
      professional_id: 'pro-aline',
      service: 'Leak repair',
      scheduled_at: days(0),
      location: 'Nyamirambo, Kigali',
      description: 'Kitchen sink leak.',
      service_fee_rwf: 25000,
      status: 'enRoute',
      payment_method: 'airtelMoney',
      payment_reference: 'AIR-100002',
      cancellation_fee_rwf: null,
      refund_amount_rwf: null,
      cancelled_at: null,
    },
    {
      id: 'FR-100003',
      customer_id: 'usr-hannington',
      professional_id: 'pro-eric',
      service: 'Deep cleaning',
      scheduled_at: days(-5),
      location: 'Remera, Kigali',
      description: 'Apartment deep clean after guests.',
      service_fee_rwf: 18000,
      status: 'completed',
      payment_method: 'card',
      payment_reference: 'CARD-100003',
      cancellation_fee_rwf: null,
      refund_amount_rwf: null,
      cancelled_at: null,
    },
    {
      id: 'FR-100004',
      customer_id: 'usr-hannington',
      professional_id: 'pro-samuel',
      service: 'AC service',
      scheduled_at: days(-2),
      location: 'Gisozi, Kigali',
      description: 'Cancelled after professional started travelling.',
      service_fee_rwf: 35000,
      status: 'cancelled',
      payment_method: 'mtnMomo',
      payment_reference: 'MOM-100004',
      cancellation_fee_rwf: 2000,
      refund_amount_rwf: 33000,
      cancelled_at: days(-2),
    },
    {
      id: 'FR-100005',
      customer_id: 'usr-hannington',
      professional_id: 'pro-grace',
      service: 'Braiding',
      scheduled_at: days(0),
      location: 'Kacyiru, Kigali',
      description: 'Wedding braids.',
      service_fee_rwf: 12000,
      status: 'inProgress',
      payment_method: 'card',
      payment_reference: 'CARD-100005',
      cancellation_fee_rwf: null,
      refund_amount_rwf: null,
      cancelled_at: null,
    },
    {
      id: 'FR-100006',
      customer_id: 'usr-hannington',
      professional_id: 'pro-diane',
      service: 'Bathroom tiles',
      scheduled_at: days(1),
      location: 'Kicukiro, Kigali',
      description: 'Guest bathroom retile.',
      service_fee_rwf: 27000,
      status: 'arrived',
      payment_method: 'airtelMoney',
      payment_reference: 'AIR-100006',
      cancellation_fee_rwf: null,
      refund_amount_rwf: null,
      cancelled_at: null,
    },
  ];
}

export async function findUserByIdentifier(identifier) {
  const value = identifier.trim().toLowerCase();
  if (!state.postgres) {
    return state.users.find(
      (user) =>
        user.email?.toLowerCase() === value ||
        user.phone === identifier.trim(),
    );
  }
  const { rows } = await query(
    `SELECT * FROM users
     WHERE LOWER(email) = $1 OR phone = $2`,
    [value, identifier.trim()],
  );
  return rows[0];
}

export async function findUserById(id) {
  if (!state.postgres) return state.users.find((user) => user.id === id);
  const { rows } = await query('SELECT * FROM users WHERE id = $1', [id]);
  return rows[0];
}

export async function createUser({ name, identifier, password }) {
  const id = `usr-${Date.now()}`;
  const email = identifier.includes('@') ? identifier.trim().toLowerCase() : null;
  const phone = identifier.includes('@') ? null : identifier.trim();
  const passwordHash = await bcrypt.hash(password, 10);
  const user = {
    id,
    name: name.trim(),
    email,
    phone,
    password_hash: passwordHash,
    role: 'customer',
  };
  if (!state.postgres) {
    state.users.push(user);
    return user;
  }
  await query(
    `INSERT INTO users (id, name, email, phone, password_hash, role)
     VALUES ($1,$2,$3,$4,$5,'customer')`,
    [id, user.name, email, phone, passwordHash],
  );
  return user;
}

export async function listCategories() {
  if (!state.postgres) {
    return [...state.categories].sort((a, b) => a.sort_order - b.sort_order);
  }
  const { rows } = await query(
    'SELECT * FROM service_categories ORDER BY sort_order',
  );
  return rows;
}

export async function listProfessionals({ trade, q } = {}) {
  if (!state.postgres) {
    return state.professionals
      .filter((item) => matchesProfessional(item, { trade, q }))
      .map((item) => publicProfessional(item, item.services));
  }
  const { rows } = await query('SELECT * FROM professionals ORDER BY name');
  const result = [];
  for (const row of rows) {
    const services = await servicesFor(row.id);
    const item = { ...row, services, category_id: row.category_id };
    if (matchesProfessional(item, { trade, q })) {
      result.push(publicProfessional(row, services));
    }
  }
  return result;
}

async function servicesFor(id) {
  if (!state.postgres) {
    return state.professionals.find((item) => item.id === id)?.services || [];
  }
  const { rows } = await query(
    'SELECT service_name FROM professional_services WHERE professional_id = $1',
    [id],
  );
  return rows.map((row) => row.service_name);
}

export async function findProfessional(id) {
  if (!state.postgres) {
    const item = state.professionals.find((pro) => pro.id === id);
    return item ? publicProfessional(item, item.services) : null;
  }
  const { rows } = await query('SELECT * FROM professionals WHERE id = $1', [id]);
  if (!rows[0]) return null;
  return publicProfessional(rows[0], await servicesFor(id));
}

export async function setVerification(id, status) {
  const tvet = status === 'verified';
  if (!state.postgres) {
    const item = state.professionals.find((pro) => pro.id === id);
    if (!item) return null;
    item.verification_status = status;
    item.tvet_verified = tvet || item.tvet_verified;
    item.id_verified = true;
    return findProfessional(id);
  }
  await query(
    `UPDATE professionals
     SET verification_status = $2, tvet_verified = $3, id_verified = TRUE
     WHERE id = $1`,
    [id, status, tvet],
  );
  return findProfessional(id);
}

export async function createBooking({
  customerId,
  professional,
  service,
  scheduledAt,
  location,
  description,
  payment,
}) {
  const id = state.postgres
    ? `FR-${String((await countBookings()) + 1).padStart(6, '0')}`
    : `FR-${String(state.bookingSeq).padStart(6, '0')}`;
  if (!state.postgres) state.bookingSeq += 1;

  const booking = {
    id,
    customer_id: customerId,
    professional_id: professional.id,
    service,
    scheduled_at: scheduledAt,
    location,
    description,
    service_fee_rwf: professional.serviceFeeRwf,
    status: 'confirmed',
    payment_method: payment.method,
    paid: true,
    payment_reference: payment.providerReference,
    payment_status: 'Paid',
    created_at: new Date().toISOString(),
  };

  const paymentRow = {
    id: `pay-${Date.now()}`,
    booking_id: id,
    method: payment.method,
    amount_rwf: professional.serviceFeeRwf,
    status: 'success',
    provider_reference: payment.providerReference,
    created_at: new Date().toISOString(),
  };

  if (!state.postgres) {
    state.bookings.unshift(booking);
    state.payments.unshift(paymentRow);
    return publicBooking(booking, professional.name, professional.trade);
  }

  await query(
    `INSERT INTO bookings
      (id, customer_id, professional_id, service, scheduled_at, location,
       description, service_fee_rwf, status, payment_method, paid, payment_reference)
     VALUES ($1,$2,$3,$4,$5,$6,$7,$8,'confirmed',$9,TRUE,$10)`,
    [
      id,
      customerId,
      professional.id,
      service,
      scheduledAt,
      location,
      description,
      professional.serviceFeeRwf,
      payment.method,
      payment.providerReference,
    ],
  );
  await query(
    `INSERT INTO payments (id, booking_id, method, amount_rwf, status, provider_reference)
     VALUES ($1,$2,$3,$4,'success',$5)`,
    [
      paymentRow.id,
      id,
      payment.method,
      professional.serviceFeeRwf,
      payment.providerReference,
    ],
  );
  return publicBooking(booking, professional.name, professional.trade);
}

async function countBookings() {
  const { rows } = await query('SELECT COUNT(*)::int AS count FROM bookings');
  return rows[0].count;
}

export async function listBookings(user) {
  if (!state.postgres) {
    const rows =
      user.role === 'admin'
        ? state.bookings
        : state.bookings.filter((item) => item.customer_id === user.id);
    return Promise.all(rows.map(hydrateBooking));
  }
  const sql =
    user.role === 'admin'
      ? 'SELECT * FROM bookings ORDER BY created_at DESC'
      : 'SELECT * FROM bookings WHERE customer_id = $1 ORDER BY created_at DESC';
  const { rows } = await query(sql, user.role === 'admin' ? [] : [user.id]);
  return Promise.all(rows.map(hydrateBooking));
}

export async function findBooking(id) {
  if (!state.postgres) {
    const row = state.bookings.find((item) => item.id === id);
    return row ? hydrateBooking(row) : null;
  }
  const { rows } = await query('SELECT * FROM bookings WHERE id = $1', [id]);
  return rows[0] ? hydrateBooking(rows[0]) : null;
}

async function hydrateBooking(row) {
  const professional = await findProfessional(row.professional_id || row.professionalId);
  return publicBooking(
    row,
    professional?.name || 'Professional',
    professional?.trade || '',
  );
}

export async function saveBooking(booking) {
  if (!state.postgres) {
    const index = state.bookings.findIndex((item) => item.id === booking.id);
    if (index >= 0) {
      state.bookings[index] = {
        ...state.bookings[index],
        status: booking.status,
        cancellation_fee_rwf: booking.cancellationFeeRwf,
        refund_amount_rwf: booking.refundAmountRwf,
        cancelled_at: booking.cancelledAt,
      };
    }
    return findBooking(booking.id);
  }
  await query(
    `UPDATE bookings
     SET status = $2, cancellation_fee_rwf = $3, refund_amount_rwf = $4, cancelled_at = $5
     WHERE id = $1`,
    [
      booking.id,
      booking.status,
      booking.cancellationFeeRwf,
      booking.refundAmountRwf,
      booking.cancelledAt,
    ],
  );
  return findBooking(booking.id);
}

export async function markBookingPayment(bookingId, { paymentStatus, paymentReference, method }) {
  if (!bookingId) return null;
  if (!state.postgres) {
    const row = state.bookings.find((item) => item.id === bookingId);
    if (!row) return null;
    row.payment_status = paymentStatus;
    if (paymentReference) row.payment_reference = paymentReference;
    if (method) row.payment_method = method;
    return findBooking(bookingId);
  }
  await query(
    `UPDATE bookings
     SET payment_status = $2,
         payment_reference = COALESCE($3, payment_reference),
         payment_method = COALESCE($4, payment_method)
     WHERE id = $1`,
    [bookingId, paymentStatus, paymentReference || null, method || null],
  );
  return findBooking(bookingId);
}

export async function adminStats() {
  const professionals = await listProfessionals();
  const bookings = state.postgres
    ? (await query('SELECT * FROM bookings')).rows
    : state.bookings;
  const payments = state.postgres
    ? (await query(`SELECT * FROM payments WHERE status = 'success'`)).rows
    : state.payments.filter((item) => item.status === 'success');
  const users = state.postgres
    ? (await query('SELECT * FROM users')).rows
    : state.users;
  return {
    users: users.length,
    professionals: professionals.length,
    pendingVerifications: professionals.filter(
      (item) => item.verificationStatus === 'pending',
    ).length,
    bookings: bookings.length,
    revenueRwf: payments.reduce(
      (sum, item) => sum + (item.amount_rwf || item.amountRwf || 0),
      0,
    ),
    store: state.engine,
  };
}
