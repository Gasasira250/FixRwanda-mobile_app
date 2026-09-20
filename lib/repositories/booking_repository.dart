import '../models/booking.dart';
import '../models/job_message.dart';
import '../models/payment.dart';

class CreateBookingInput {
  const CreateBookingInput({
    this.professionalId = '',
    required this.serviceId,
    required this.serviceName,
    required this.category,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.customerAddress,
    required this.servicePrice,
    this.district,
    this.sector,
  });

  final String professionalId;
  final String serviceId;
  final String serviceName;
  final String category;
  final DateTime scheduledDate;
  final String scheduledTime;
  final String customerAddress;
  final int servicePrice;
  final String? district;
  final String? sector;
}

abstract class BookingRepository {
  Future<List<Booking>> getBookingsForCustomer(String customerId);
  Future<List<Booking>> openBroadcastsForProfessional(String professionalId);
  Future<List<Booking>> assignedJobsForProfessional(String professionalId);
  Future<Booking?> getBookingById(String id);
  Future<Booking> createBooking(CreateBookingInput input);
  Future<Booking> cancelBooking(String bookingId);
  Future<Booking> updateStatus(String bookingId, BookingStatus status);
  Future<Booking> acceptJob(String bookingId);
  Future<Booking> startTravel(String bookingId);
  Future<Booking> markArrived(String bookingId);
  Future<Booking> startJob(String bookingId, {required String photoRef});
  Future<Booking> markWorkFinished(String bookingId, {required String otp});
  Future<Booking> confirmCompletionWithOtp(String bookingId, String otp);
  Future<Booking> uploadAfterPhoto(String bookingId, {required String photoRef});
  Future<Booking> openDispute(String bookingId, {required String reason});
  Future<JobMessage> sendJobMessage({
    required String bookingId,
    required String body,
  });
  List<JobMessage> messagesFor(String bookingId);
  Future<Booking> pushLocation({
    required String bookingId,
    required double latitude,
    required double longitude,
  });
  Future<int> expireStaleBroadcasts({DateTime? now});
  Future<Payment> payBooking({
    required String bookingId,
    required PaymentMethod method,
    required String phoneNumber,
  });
  Payment? paymentFor(String bookingId);
}
