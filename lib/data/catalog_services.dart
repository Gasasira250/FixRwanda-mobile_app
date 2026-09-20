import '../models/service.dart';

const kigaliSectors = [
  'Nyarugenge',
  'Kacyiru',
  'Kimironko',
  'Gikondo',
  'Remera',
  'Nyamirambo',
];

List<Service> servicesFor(String professionalId, String category, int basePrice) {
  final offerings = switch (category) {
    'Electrical Installation' => [
      ('Wiring inspection', 'Inspect circuits, sockets and breakers.'),
      ('Fixture installation', 'Install lights, fans and switches.'),
    ],
    'Plumbing' => [
      ('Leak repair', 'Find and repair leaking pipes and taps.'),
      ('Bathroom plumbing', 'Fix toilets, showers and water heaters.'),
    ],
    'House Cleaning' => [
      ('Home deep clean', 'Full house cleaning including kitchen and bathrooms.'),
      ('Office cleaning', 'Scheduled cleaning for small offices.'),
    ],
    'Appliance Repair' => [
      ('Fridge repair', 'Diagnose and repair refrigeration issues.'),
      ('Washing machine repair', 'Fix drums, pumps and control boards.'),
    ],
    'Computer & IT Support' => [
      ('Laptop repair', 'Hardware diagnosis, OS setup and data backup.'),
      ('Network setup', 'Home Wi-Fi and office network installation.'),
    ],
    'Car Repair' => [
      ('Engine diagnostics', 'Check engine lights, fluids and batteries.'),
      ('Brake service', 'Inspect and replace pads, discs and fluid.'),
    ],
    'Painting' => [
      ('Interior painting', 'Wall preparation and interior paint.'),
      ('Exterior painting', 'Weather-ready exterior coat.'),
    ],
    'Construction' => [
      ('Masonry work', 'Brickwork, plaster and small extensions.'),
      ('Site finishing', 'Tiling, plaster and finishing work.'),
    ],
    'Hair Styling' => [
      ('Salon styling', 'Cut, braid and style at home or salon.'),
      ('Bridal hair', 'Bridal and event hair styling.'),
    ],
    'Beauty Services' => [
      ('Makeup session', 'Everyday and event makeup.'),
      ('Skincare session', 'Facials and skin consultations.'),
    ],
    _ => [
      ('Standard visit', 'On-site assessment and repair.'),
      ('Follow-up visit', 'Return visit after the first job.'),
    ],
  };

  return [
    for (var i = 0; i < offerings.length; i++)
      Service(
        id: '$professionalId-s$i',
        name: offerings[i].$1,
        description: offerings[i].$2,
        iconName: category,
        category: category,
        priceRwf: basePrice + (i * 5000),
        professionalId: professionalId,
      ),
  ];
}

List<Service> categoryServices(String category, {int basePrice = 20000}) {
  return servicesFor('broadcast', category, basePrice);
}
