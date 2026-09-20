import '../models/review.dart';

abstract class ReviewRepository {
  Future<List<Review>> getReviewsForProfessional(String professionalId);
  Future<Review?> getReviewForBooking(String bookingId);
  Future<Review> addReview({
    required String bookingId,
    required int rating,
    required String comment,
  });
}
