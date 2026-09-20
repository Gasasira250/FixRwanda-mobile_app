class Review {
  const Review({
    required this.id,
    required this.bookingId,
    required this.customerId,
    required this.professionalId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  final String id;
  final String bookingId;
  final String customerId;
  final String professionalId;
  final int rating;
  final String comment;
  final DateTime createdAt;
}

class DuplicateReviewException implements Exception {
  DuplicateReviewException([this.message = 'This booking already has a review.']);
  final String message;
  @override
  String toString() => message;
}

class ReviewNotAllowedException implements Exception {
  ReviewNotAllowedException([
    this.message = 'Only completed bookings can be reviewed.',
  ]);
  final String message;
  @override
  String toString() => message;
}
