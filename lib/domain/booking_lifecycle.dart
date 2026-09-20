import '../models/booking.dart';

class InvalidBookingTransition implements Exception {
  InvalidBookingTransition(this.message);
  final String message;
  @override
  String toString() => message;
}

class BookingLifecycle {
  static const allowed = <BookingStatus, Set<BookingStatus>>{
    BookingStatus.pending: {BookingStatus.confirmed, BookingStatus.cancelled},
    BookingStatus.confirmed: {BookingStatus.enRoute, BookingStatus.cancelled},
    BookingStatus.enRoute: {BookingStatus.arrived, BookingStatus.cancelled},
    BookingStatus.arrived: {BookingStatus.inProgress, BookingStatus.cancelled},
    BookingStatus.inProgress: {BookingStatus.completed},
    BookingStatus.completed: {},
    BookingStatus.cancelled: {},
  };

  static bool canTransition(BookingStatus from, BookingStatus to) {
    return allowed[from]?.contains(to) ?? false;
  }

  static BookingStatus transition(BookingStatus from, BookingStatus to) {
    if (!canTransition(from, to)) {
      throw InvalidBookingTransition(
        'Cannot change a ${from.name} booking to ${to.name}.',
      );
    }
    return to;
  }

  static BookingStatus? nextProfessionalStatus(BookingStatus status) {
    return switch (status) {
      BookingStatus.pending => BookingStatus.confirmed,
      BookingStatus.confirmed => BookingStatus.enRoute,
      BookingStatus.enRoute => BookingStatus.arrived,
      BookingStatus.arrived => BookingStatus.inProgress,
      BookingStatus.inProgress => BookingStatus.completed,
      BookingStatus.completed || BookingStatus.cancelled => null,
    };
  }
}
