import '../models/booking.dart';
import '../models/payment.dart';

class CreateBookingInput {
  const CreateBookingInput({
    required this.professionalId,
    required this.serviceId,
    required this.serviceName,
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
  final DateTime scheduledDate;
  final String scheduledTime;
  final String customerAddress;
  final int servicePrice;
  final String? district;
  final String? sector;
}

abstract class BookingRepository {
  Future<List<Booking>> getBookingsForCustomer(String customerId);
  Future<Booking?> getBookingById(String id);
  Future<Booking> createBooking(CreateBookingInput input);
  Future<Booking> cancelBooking(String bookingId);
  Future<Booking> updateStatus(String bookingId, BookingStatus status);
  Future<Payment> payBooking({
    required String bookingId,
    required PaymentMethod method,
    required String phoneNumber,
  });
  Payment? paymentFor(String bookingId);
}
