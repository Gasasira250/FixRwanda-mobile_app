import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fixrwanda/data/local_marketplace_store.dart';
import 'package:fixrwanda/models/professional.dart';
import 'package:fixrwanda/repositories/professional_repository.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('filters by category, verified status and sort order', () async {
    final store = LocalMarketplaceStore();
    await store.initialize();

    final plumbing = await store.filterProfessionals(
      const ProfessionalFilter(category: 'Plumbing'),
    );
    expect(plumbing, isNotEmpty);
    expect(plumbing.every((item) => item.category == 'Plumbing'), isTrue);

    final verified = await store.filterProfessionals(
      const ProfessionalFilter(verifiedOnly: true),
    );
    expect(
      verified.every((item) => item.verificationStatus == VerificationStatus.verified),
      isTrue,
    );

    final cheapFirst = await store.filterProfessionals(
      const ProfessionalFilter(sort: ProfessionalSort.priceLow),
    );
    expect(
      cheapFirst.first.startingPrice <= cheapFirst.last.startingPrice,
      isTrue,
    );
  });

  test('search matches name and trade', () async {
    final store = LocalMarketplaceStore();
    final results = await store.searchProfessionals('Aline');
    expect(results.any((item) => item.name.contains('Aline')), isTrue);
  });
}
