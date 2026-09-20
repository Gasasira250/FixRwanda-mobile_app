import '../models/booking.dart';

/// Cancellation and refund rules for FixRwanda.
///
/// The live API is the source of truth. This class is used for offline
/// mode and Flutter unit tests, and it must stay in lockstep with
/// `backend/src/refunds.js`.
class RefundPolicy {
  static const transportFeeRwf = 2000;

  static CancellationQuote quote(Booking booking) {
    if (booking.status == BookingStatus.cancelled) {
      return CancellationQuote(
        canCancel: false,
        cancellationFeeRwf: booking.cancellationFeeRwf ?? 0,
        refundAmountRwf: booking.refundAmountRwf ?? 0,
        title: 'Already cancelled',
        message: 'This booking is already cancelled.',
      );
    }

    if (booking.status == BookingStatus.completed) {
      return const CancellationQuote(
        canCancel: false,
        cancellationFeeRwf: 0,
        refundAmountRwf: 0,
        title: "Cancellation isn't available",
        message: 'Completed bookings cannot be cancelled.',
      );
    }

    if (booking.status == BookingStatus.confirmed) {
      return CancellationQuote(
        canCancel: true,
        cancellationFeeRwf: 0,
        refundAmountRwf: booking.serviceFeeRwf,
        title: 'Cancel booking',
        message:
            'The professional has not started travelling. You will receive a full refund of ${booking.serviceFeeRwf} RWF.',
      );
    }

    if (booking.status == BookingStatus.inProgress) {
      final refund = (booking.serviceFeeRwf / 2).floor();
      return CancellationQuote(
        canCancel: true,
        cancellationFeeRwf: booking.serviceFeeRwf - refund,
        refundAmountRwf: refund,
        title: 'Job already in progress',
        message:
            'Work has started. Half of the service fee is refunded; the rest covers time already spent.',
      );
    }

    final refund = booking.serviceFeeRwf - transportFeeRwf;
    final onTheWay = booking.status == BookingStatus.enRoute;
    return CancellationQuote(
      canCancel: true,
      cancellationFeeRwf: transportFeeRwf,
      refundAmountRwf: refund < 0 ? 0 : refund,
      title: onTheWay
          ? 'Professional is already on the way'
          : 'Professional is already on site',
      message:
          'A $transportFeeRwf RWF transport fee is withheld. Refund: ${refund < 0 ? 0 : refund} RWF.',
    );
  }

  static String? nextProfessionalActionLabel(BookingStatus status) {
    return switch (status) {
      BookingStatus.confirmed => 'Start journey',
      BookingStatus.enRoute => 'Mark arrived',
      BookingStatus.arrived => 'Start job',
      BookingStatus.inProgress => 'Complete job',
      BookingStatus.completed || BookingStatus.cancelled => null,
    };
  }

  static BookingStatus? nextStatus(BookingStatus status) {
    return switch (status) {
      BookingStatus.confirmed => BookingStatus.enRoute,
      BookingStatus.enRoute => BookingStatus.arrived,
      BookingStatus.arrived => BookingStatus.inProgress,
      BookingStatus.inProgress => BookingStatus.completed,
      BookingStatus.completed || BookingStatus.cancelled => null,
    };
  }
}
