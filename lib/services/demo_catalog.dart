import '../models/booking.dart';
import '../models/professional.dart';
import 'refund_policy.dart';

/// Offline catalogue used when the REST API is unreachable.
class DemoCatalog {
  DemoCatalog() {
    bookings.addAll(_seedBookings());
    _sequence = bookings.length + 1;
  }

  final List<Booking> bookings = [];
  int _sequence = 1;

  static const categories = [
    ServiceCategory(id: 'electrician', name: 'Electrician', icon: '⚡'),
    ServiceCategory(id: 'plumber', name: 'Plumber', icon: '🔧'),
    ServiceCategory(id: 'cleaner', name: 'Cleaner', icon: '🧹'),
    ServiceCategory(id: 'painter', name: 'Painter', icon: '🎨'),
    ServiceCategory(id: 'carpenter', name: 'Carpenter', icon: '🪚'),
    ServiceCategory(id: 'hvac', name: 'AC & Fridge', icon: '❄️'),
    ServiceCategory(id: 'phone', name: 'Phone repair', icon: '📱'),
    ServiceCategory(id: 'stylist', name: 'Stylist', icon: '💇'),
    ServiceCategory(id: 'mason', name: 'Mason', icon: '🧱'),
    ServiceCategory(id: 'tiler', name: 'Tiler', icon: '⬜'),
    ServiceCategory(id: 'mechanic', name: 'Mechanic', icon: '🚗'),
    ServiceCategory(id: 'gardener', name: 'Gardener', icon: '🌿'),
    ServiceCategory(id: 'locksmith', name: 'Locksmith', icon: '🔑'),
    ServiceCategory(id: 'welder', name: 'Welder', icon: '🛠️'),
  ];

  static const professionals = [
    Professional(
      id: 'pro-jean',
      name: 'Jean Mugabo Electrical',
      trade: 'Electrician',
      location: 'Kimironko, Kigali',
      rating: 4.8,
      jobsCompleted: 126,
      tvetVerified: true,
      idVerified: true,
      verificationStatus: VerificationStatus.verified,
      serviceFeeRwf: 30000,
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
      about:
          'Licensed electrician for homes and shops. Wiring, sockets, lighting and fault-finding across Kigali.',
    ),
    Professional(
      id: 'pro-aline',
      name: 'Aline Uwase Plumbing',
      trade: 'Plumber',
      location: 'Nyamirambo, Kigali',
      rating: 4.7,
      jobsCompleted: 94,
      tvetVerified: true,
      idVerified: true,
      verificationStatus: VerificationStatus.verified,
      serviceFeeRwf: 25000,
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
      about:
          'Fast leak repair and bathroom fitting. Available across Nyarugenge and Kicukiro.',
    ),
    Professional(
      id: 'pro-eric',
      name: 'Eric Niyonzima Cleaning',
      trade: 'Cleaner',
      location: 'Remera, Kigali',
      rating: 4.9,
      jobsCompleted: 210,
      tvetVerified: true,
      idVerified: true,
      verificationStatus: VerificationStatus.verified,
      serviceFeeRwf: 18000,
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
    ),
    Professional(
      id: 'pro-claudine',
      name: 'Claudine Mukamana Paint',
      trade: 'Painter',
      location: 'Huye',
      rating: 4.6,
      jobsCompleted: 71,
      tvetVerified: true,
      idVerified: true,
      verificationStatus: VerificationStatus.verified,
      serviceFeeRwf: 22000,
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
    ),
    Professional(
      id: 'pro-patrick',
      name: 'Patrick Habimana Woodworks',
      trade: 'Carpenter',
      location: 'Musanze',
      rating: 4.5,
      jobsCompleted: 40,
      tvetVerified: false,
      idVerified: true,
      verificationStatus: VerificationStatus.pending,
      serviceFeeRwf: 28000,
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
      about: 'ID submitted. TVET certificate is still under admin review.',
    ),
    Professional(
      id: 'pro-samuel',
      name: 'Samuel Kwizera Cooling',
      trade: 'AC & Fridge',
      location: 'Gisozi, Kigali',
      rating: 4.8,
      jobsCompleted: 88,
      tvetVerified: true,
      idVerified: true,
      verificationStatus: VerificationStatus.verified,
      serviceFeeRwf: 35000,
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
    ),
    Professional(
      id: 'pro-nadine',
      name: 'Nadine Phone Clinic',
      trade: 'Phone repair',
      location: 'Rubavu',
      rating: 4.7,
      jobsCompleted: 156,
      tvetVerified: true,
      idVerified: true,
      verificationStatus: VerificationStatus.verified,
      serviceFeeRwf: 15000,
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
    ),
    Professional(
      id: 'pro-grace',
      name: 'Grace Style House',
      trade: 'Stylist',
      location: 'Kacyiru, Kigali',
      rating: 4.9,
      jobsCompleted: 64,
      tvetVerified: false,
      idVerified: true,
      verificationStatus: VerificationStatus.verified,
      serviceFeeRwf: 12000,
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
    ),
    Professional(
      id: 'pro-olivier',
      name: 'Olivier Mason Works',
      trade: 'Mason',
      location: 'Gasabo, Kigali',
      rating: 4.6,
      jobsCompleted: 58,
      tvetVerified: true,
      idVerified: true,
      verificationStatus: VerificationStatus.verified,
      serviceFeeRwf: 40000,
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
      about: 'Foundations, plaster and small home extensions.',
    ),
    Professional(
      id: 'pro-diane',
      name: 'Diane Tile Studio',
      trade: 'Tiler',
      location: 'Kicukiro, Kigali',
      rating: 4.8,
      jobsCompleted: 102,
      tvetVerified: true,
      idVerified: true,
      verificationStatus: VerificationStatus.verified,
      serviceFeeRwf: 27000,
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
    ),
    Professional(
      id: 'pro-bosco',
      name: 'Bosco Auto Fix',
      trade: 'Mechanic',
      location: 'Nyabugogo, Kigali',
      rating: 4.5,
      jobsCompleted: 190,
      tvetVerified: true,
      idVerified: true,
      verificationStatus: VerificationStatus.verified,
      serviceFeeRwf: 32000,
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
    ),
    Professional(
      id: 'pro-immaculee',
      name: 'Immaculée Gardens',
      trade: 'Gardener',
      location: 'Nyarutarama, Kigali',
      rating: 4.9,
      jobsCompleted: 77,
      tvetVerified: false,
      idVerified: true,
      verificationStatus: VerificationStatus.verified,
      serviceFeeRwf: 16000,
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
    ),
    Professional(
      id: 'pro-kevin',
      name: 'Kevin Lock & Key',
      trade: 'Locksmith',
      location: 'CBD, Kigali',
      rating: 4.7,
      jobsCompleted: 83,
      tvetVerified: true,
      idVerified: true,
      verificationStatus: VerificationStatus.verified,
      serviceFeeRwf: 20000,
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
    ),
    Professional(
      id: 'pro-chantal',
      name: 'Chantal Welding Co',
      trade: 'Welder',
      location: 'Rwamagana',
      rating: 4.4,
      jobsCompleted: 49,
      tvetVerified: true,
      idVerified: true,
      verificationStatus: VerificationStatus.verified,
      serviceFeeRwf: 26000,
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
    ),
    Professional(
      id: 'pro-yves',
      name: 'Yves Power Fix',
      trade: 'Electrician',
      location: 'Huye',
      rating: 4.6,
      jobsCompleted: 61,
      tvetVerified: true,
      idVerified: true,
      verificationStatus: VerificationStatus.verified,
      serviceFeeRwf: 28000,
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
    ),
    Professional(
      id: 'pro-peace',
      name: 'Peace Plumbing Plus',
      trade: 'Plumber',
      location: 'Gisenyi, Rubavu',
      rating: 4.8,
      jobsCompleted: 112,
      tvetVerified: true,
      idVerified: true,
      verificationStatus: VerificationStatus.verified,
      serviceFeeRwf: 24000,
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
    ),
    Professional(
      id: 'pro-solange',
      name: 'Solange Clean Home',
      trade: 'Cleaner',
      location: 'Kacyiru, Kigali',
      rating: 4.7,
      jobsCompleted: 134,
      tvetVerified: true,
      idVerified: true,
      verificationStatus: VerificationStatus.verified,
      serviceFeeRwf: 17000,
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
    ),
    Professional(
      id: 'pro-fabrice',
      name: 'Fabrice Wood & Fit',
      trade: 'Carpenter',
      location: 'Nyamata',
      rating: 4.6,
      jobsCompleted: 55,
      tvetVerified: true,
      idVerified: true,
      verificationStatus: VerificationStatus.verified,
      serviceFeeRwf: 29000,
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
    ),
  ];

  Customer login({required String identifier, required String password}) {
    if (identifier.trim().isEmpty || password.trim().length < 4) {
      throw AuthException(
        'Enter a phone number or email and a password of at least 4 characters.',
      );
    }
    return Customer(
      id: 'usr-hannington',
      name: _displayNameFor(identifier),
      identifier: identifier.trim(),
      token: 'session-token',
    );
  }

  Customer register({
    required String name,
    required String identifier,
    required String password,
  }) {
    if (name.trim().isEmpty ||
        identifier.trim().isEmpty ||
        password.trim().length < 6) {
      throw AuthException('Please complete all fields to create an account.');
    }
    return Customer(
      id: 'usr-${identifier.hashCode}',
      name: name.trim(),
      identifier: identifier.trim(),
      token: 'session-token',
    );
  }

  List<Professional> search({String? trade, String? query}) {
    final needle = query?.trim().toLowerCase() ?? '';
    return professionals.where((professional) {
      final tradeOk =
          trade == null ||
          trade.isEmpty ||
          professional.trade.toLowerCase() == trade.toLowerCase() ||
          professional.id.startsWith('pro-') &&
              trade.toLowerCase() ==
                  professional.trade.toLowerCase().replaceAll(' & ', ' ');
      final queryOk =
          needle.isEmpty ||
          professional.name.toLowerCase().contains(needle) ||
          professional.trade.toLowerCase().contains(needle) ||
          professional.location.toLowerCase().contains(needle) ||
          professional.services.any(
            (service) => service.toLowerCase().contains(needle),
          );
      return tradeOk && queryOk;
    }).toList();
  }

  Booking payAndConfirm({
    required BookingDraft draft,
    required PaymentMethod method,
  }) {
    final professional = professionals.firstWhere(
      (item) => item.id == draft.professionalId,
    );
    if (!professional.isVerifiedProfessional) {
      throw AuthException('Only verified professionals can be booked.');
    }
    final booking = Booking(
      id: 'FR-${_sequence.toString().padLeft(6, '0')}',
      professionalId: draft.professionalId,
      professionalName: draft.professionalName,
      trade: draft.trade,
      service: draft.service,
      scheduledAt: draft.scheduledAt,
      location: draft.location,
      description: draft.description,
      serviceFeeRwf: draft.serviceFeeRwf,
      status: BookingStatus.confirmed,
      paymentMethod: method,
      paid: true,
      createdAt: DateTime.now(),
      paymentReference: _reference(method),
    );
    _sequence += 1;
    bookings.insert(0, booking);
    return booking;
  }

  CancellationQuote quote(String bookingId) {
    return RefundPolicy.quote(_require(bookingId));
  }

  Booking cancel(String bookingId) {
    final current = _require(bookingId);
    final quote = RefundPolicy.quote(current);
    if (!quote.canCancel) {
      throw AuthException(quote.message);
    }
    final cancelled = current.copyWith(
      status: BookingStatus.cancelled,
      cancellationFeeRwf: quote.cancellationFeeRwf,
      refundAmountRwf: quote.refundAmountRwf,
      cancelledAt: DateTime.now(),
    );
    _replace(cancelled);
    return cancelled;
  }

  Booking advance(String bookingId) {
    final current = _require(bookingId);
    final next = RefundPolicy.nextStatus(current.status);
    if (next == null) {
      throw AuthException('No further professional action for this booking.');
    }
    final updated = current.copyWith(status: next);
    _replace(updated);
    return updated;
  }

  Booking _require(String id) {
    return bookings.firstWhere(
      (item) => item.id == id,
      orElse: () => throw AuthException('Booking $id was not found.'),
    );
  }

  void _replace(Booking booking) {
    final index = bookings.indexWhere((item) => item.id == booking.id);
    bookings[index] = booking;
  }

  String _reference(PaymentMethod method) {
    final stamp = DateTime.now().millisecondsSinceEpoch.toString().substring(7);
    return switch (method) {
      PaymentMethod.mtnMomo => 'MOM-$stamp',
      PaymentMethod.airtelMoney => 'AIR-$stamp',
      PaymentMethod.card => 'CARD-$stamp',
    };
  }

  static String _displayNameFor(String identifier) {
    final value = identifier.trim().toLowerCase();
    if (value.contains('hannington') || value == '0780000000') {
      return 'Hannington';
    }
    if (value.contains('@')) {
      final local = value.split('@').first;
      if (local.isEmpty) return 'Guest';
      return '${local[0].toUpperCase()}${local.substring(1)}';
    }
    return 'Hannington';
  }

  static List<Booking> _seedBookings() {
    final now = DateTime.now();
    DateTime shift(int days) => now.add(Duration(days: days));
    return [
      Booking(
        id: 'FR-100001',
        professionalId: 'pro-jean',
        professionalName: 'Jean Mugabo Electrical',
        trade: 'Electrician',
        service: 'House wiring',
        scheduledAt: shift(2),
        location: 'Kimironko, Kigali',
        description: 'Full house rewiring before painting.',
        serviceFeeRwf: 30000,
        status: BookingStatus.confirmed,
        paymentMethod: PaymentMethod.mtnMomo,
        paid: true,
        createdAt: shift(-1),
        paymentReference: 'MOM-100001',
      ),
      Booking(
        id: 'FR-100002',
        professionalId: 'pro-aline',
        professionalName: 'Aline Uwase Plumbing',
        trade: 'Plumber',
        service: 'Leak repair',
        scheduledAt: shift(0),
        location: 'Nyamirambo, Kigali',
        description: 'Kitchen sink leak.',
        serviceFeeRwf: 25000,
        status: BookingStatus.enRoute,
        paymentMethod: PaymentMethod.airtelMoney,
        paid: true,
        createdAt: shift(-1),
        paymentReference: 'AIR-100002',
      ),
      Booking(
        id: 'FR-100003',
        professionalId: 'pro-eric',
        professionalName: 'Eric Niyonzima Cleaning',
        trade: 'Cleaner',
        service: 'Deep cleaning',
        scheduledAt: shift(-5),
        location: 'Remera, Kigali',
        description: 'Apartment deep clean after guests.',
        serviceFeeRwf: 18000,
        status: BookingStatus.completed,
        paymentMethod: PaymentMethod.card,
        paid: true,
        createdAt: shift(-6),
        paymentReference: 'CARD-100003',
      ),
      Booking(
        id: 'FR-100004',
        professionalId: 'pro-samuel',
        professionalName: 'Samuel Kwizera Cooling',
        trade: 'AC & Fridge',
        service: 'AC service',
        scheduledAt: shift(-2),
        location: 'Gisozi, Kigali',
        description: 'Cancelled after professional started travelling.',
        serviceFeeRwf: 35000,
        status: BookingStatus.cancelled,
        paymentMethod: PaymentMethod.mtnMomo,
        paid: true,
        createdAt: shift(-3),
        paymentReference: 'MOM-100004',
        cancellationFeeRwf: 2000,
        refundAmountRwf: 33000,
        cancelledAt: shift(-2),
      ),
      Booking(
        id: 'FR-100005',
        professionalId: 'pro-grace',
        professionalName: 'Grace Style House',
        trade: 'Stylist',
        service: 'Braiding',
        scheduledAt: shift(0),
        location: 'Kacyiru, Kigali',
        description: 'Wedding braids.',
        serviceFeeRwf: 12000,
        status: BookingStatus.inProgress,
        paymentMethod: PaymentMethod.card,
        paid: true,
        createdAt: shift(-1),
        paymentReference: 'CARD-100005',
      ),
      Booking(
        id: 'FR-100006',
        professionalId: 'pro-diane',
        professionalName: 'Diane Tile Studio',
        trade: 'Tiler',
        service: 'Bathroom tiles',
        scheduledAt: shift(1),
        location: 'Kicukiro, Kigali',
        description: 'Guest bathroom retile.',
        serviceFeeRwf: 27000,
        status: BookingStatus.arrived,
        paymentMethod: PaymentMethod.airtelMoney,
        paid: true,
        createdAt: shift(-1),
        paymentReference: 'AIR-100006',
      ),
    ];
  }
}

class AuthException implements Exception {
  AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}
