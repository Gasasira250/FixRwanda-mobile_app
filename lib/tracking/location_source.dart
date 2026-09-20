import '../models/booking.dart';
import '../models/payment.dart';

class LocationFix {
  const LocationFix({
    required this.bookingId,
    required this.latitude,
    required this.longitude,
    required this.at,
  });

  final String bookingId;
  final double latitude;
  final double longitude;
  final DateTime at;
}

abstract class LocationSource {
  Future<({double latitude, double longitude})> read({
    required double fallbackLatitude,
    required double fallbackLongitude,
  });
}

class SimulatedLocationSource implements LocationSource {
  SimulatedLocationSource({this.step = 0.0008});

  final double step;
  double _ticks = 0;

  @override
  Future<({double latitude, double longitude})> read({
    required double fallbackLatitude,
    required double fallbackLongitude,
  }) async {
    _ticks += 1;
    return (
      latitude: fallbackLatitude + (_ticks * step),
      longitude: fallbackLongitude + (_ticks * step * 0.5),
    );
  }
}

BookingStatus productionStatus(BookingStatus status) {
  return switch (status) {
    BookingStatus.pending || BookingStatus.broadcasting => BookingStatus.pending,
    BookingStatus.accepted => BookingStatus.accepted,
    BookingStatus.enRoute || BookingStatus.arrived => BookingStatus.enRoute,
    BookingStatus.inProgress || BookingStatus.awaitingOtp =>
      BookingStatus.inProgress,
    BookingStatus.completed => BookingStatus.completed,
    BookingStatus.disputed => BookingStatus.disputed,
    BookingStatus.cancelled || BookingStatus.expired => BookingStatus.cancelled,
  };
}

String productionStatusName(BookingStatus status) {
  return switch (productionStatus(status)) {
    BookingStatus.pending => 'REQUESTED',
    BookingStatus.accepted => 'ACCEPTED',
    BookingStatus.enRoute => 'EN_ROUTE',
    BookingStatus.inProgress => 'IN_PROGRESS',
    BookingStatus.completed => 'COMPLETED',
    BookingStatus.disputed => 'DISPUTED',
    BookingStatus.cancelled => 'CANCELLED',
    _ => status.name.toUpperCase(),
  };
}

PaymentState paymentStateFromEscrow(String escrowStatus) {
  return switch (escrowStatus) {
    'held' => PaymentState.heldInEscrow,
    'released' => PaymentState.disbursedToProvider,
    'refunded' => PaymentState.refunded,
    _ => PaymentState.initiated,
  };
}
