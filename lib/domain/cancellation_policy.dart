import '../core/app_config.dart';
import '../models/booking.dart';

class CancellationQuote {
  const CancellationQuote({
    required this.canCancel,
    required this.cancellationFeeRwf,
    required this.refundAmountRwf,
    required this.title,
    required this.message,
  });

  final bool canCancel;
  final int cancellationFeeRwf;
  final int refundAmountRwf;
  final String title;
  final String message;
}

class CancellationPolicy {
  static const transportFeeRwf = AppConfig.transportFeeRwf;

  static bool canCancelBooking(Booking booking) {
    switch (booking.status) {
      case BookingStatus.confirmed:
      case BookingStatus.enRoute:
      case BookingStatus.arrived:
      case BookingStatus.pending:
        return true;
      case BookingStatus.inProgress:
      case BookingStatus.completed:
      case BookingStatus.cancelled:
        return false;
    }
  }

  static int calculateCancellationFee(Booking booking) {
    if (!canCancelBooking(booking)) return 0;
    if (booking.status == BookingStatus.confirmed ||
        booking.status == BookingStatus.pending) {
      return 0;
    }
    return transportFeeRwf;
  }

  static int calculateRefundAmount(Booking booking) {
    if (!canCancelBooking(booking)) return 0;
    final fee = calculateCancellationFee(booking);
    final refund = booking.servicePrice - fee;
    return refund < 0 ? 0 : refund;
  }

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
        title: 'Cancellation is not available',
        message: 'Completed bookings cannot be cancelled.',
      );
    }
    if (booking.status == BookingStatus.inProgress) {
      return const CancellationQuote(
        canCancel: false,
        cancellationFeeRwf: 0,
        refundAmountRwf: 0,
        title: 'Work already started',
        message: 'Jobs in progress cannot be cancelled.',
      );
    }
    if (booking.status == BookingStatus.confirmed ||
        booking.status == BookingStatus.pending) {
      return CancellationQuote(
        canCancel: true,
        cancellationFeeRwf: 0,
        refundAmountRwf: booking.servicePrice,
        title: 'Cancel booking',
        message:
            'The professional has not started travelling. Full refund: ${booking.servicePrice} RWF.',
      );
    }
    final refund = calculateRefundAmount(booking);
    final onTheWay = booking.status == BookingStatus.enRoute;
    return CancellationQuote(
      canCancel: true,
      cancellationFeeRwf: transportFeeRwf,
      refundAmountRwf: refund,
      title: onTheWay
          ? 'Professional is already on the way'
          : 'Professional is already on site',
      message:
          'A $transportFeeRwf RWF transport fee is withheld. Refund: $refund RWF.',
    );
  }
}
