import '../models/booking.dart';
import '../models/professional.dart';

abstract class AdminRepository {
  Future<List<Professional>> pendingVerifications();
  Future<Professional> setOverallVerification(
    String professionalId,
    VerificationStatus status,
  );
  Future<List<Booking>> disputedBookings();
  Future<Booking> adminRefund(String bookingId);
  Future<Booking> adminPayout(String bookingId);
}
