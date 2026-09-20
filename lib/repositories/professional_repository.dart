import '../models/professional.dart';

enum ProfessionalSort { rating, priceLow, priceHigh, jobs }

class ProfessionalFilter {
  const ProfessionalFilter({
    this.query,
    this.category,
    this.location,
    this.minRating,
    this.maxPrice,
    this.verifiedOnly = false,
    this.sort = ProfessionalSort.rating,
  });

  final String? query;
  final String? category;
  final String? location;
  final double? minRating;
  final int? maxPrice;
  final bool verifiedOnly;
  final ProfessionalSort sort;

  ProfessionalFilter copyWith({
    String? query,
    String? category,
    String? location,
    double? minRating,
    int? maxPrice,
    bool? verifiedOnly,
    ProfessionalSort? sort,
    bool clearCategory = false,
  }) {
    return ProfessionalFilter(
      query: query ?? this.query,
      category: clearCategory ? null : (category ?? this.category),
      location: location ?? this.location,
      minRating: minRating ?? this.minRating,
      maxPrice: maxPrice ?? this.maxPrice,
      verifiedOnly: verifiedOnly ?? this.verifiedOnly,
      sort: sort ?? this.sort,
    );
  }
}

abstract class ProfessionalRepository {
  Future<List<Professional>> getProfessionals();
  Future<List<Professional>> searchProfessionals(String query);
  Future<List<Professional>> filterProfessionals(ProfessionalFilter filter);
  Future<Professional?> getProfessionalById(String id);
}
