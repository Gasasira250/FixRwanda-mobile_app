enum BookingStatus {
  confirmed,
  enRoute,
  arrived,
  inProgress,
  completed,
  cancelled,
}

enum PaymentMethod { mtnMomo, airtelMoney, card }

class BookingDraft {
  const BookingDraft({
    required this.professionalId,
    required this.professionalName,
    required this.trade,
    required this.service,
    required this.scheduledAt,
    required this.location,
    required this.description,
    required this.serviceFeeRwf,
  });

  final String professionalId;
  final String professionalName;
  final String trade;
  final String service;
  final DateTime scheduledAt;
  final String location;
  final String description;
  final int serviceFeeRwf;

  Map<String, dynamic> toJson(PaymentMethod method) {
    return {
      'professionalId': professionalId,
      'service': service,
      'scheduledAt': scheduledAt.toIso8601String(),
      'location': location,
      'description': description,
      'paymentMethod': method.name,
    };
  }
}

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

  factory CancellationQuote.fromJson(Map<String, dynamic> json) {
    return CancellationQuote(
      canCancel: json['canCancel'] as bool? ?? false,
      cancellationFeeRwf: json['cancellationFeeRwf'] as int? ?? 0,
      refundAmountRwf: json['refundAmountRwf'] as int? ?? 0,
      title: json['title'] as String? ?? 'Cancellation',
      message: json['message'] as String? ?? '',
    );
  }
}

class Booking {
  const Booking({
    required this.id,
    required this.professionalId,
    required this.professionalName,
    required this.trade,
    required this.service,
    required this.scheduledAt,
    required this.location,
    required this.description,
    required this.serviceFeeRwf,
    required this.status,
    required this.paymentMethod,
    required this.paid,
    required this.createdAt,
    this.paymentReference,
    this.paymentStatus,
    this.cancellationFeeRwf,
    this.refundAmountRwf,
    this.cancelledAt,
  });

  final String id;
  final String professionalId;
  final String professionalName;
  final String trade;
  final String service;
  final DateTime scheduledAt;
  final String location;
  final String description;
  final int serviceFeeRwf;
  final BookingStatus status;
  final PaymentMethod paymentMethod;
  final bool paid;
  final DateTime createdAt;
  final String? paymentReference;
  final String? paymentStatus;
  final int? cancellationFeeRwf;
  final int? refundAmountRwf;
  final DateTime? cancelledAt;

  bool get isUpcoming =>
      status == BookingStatus.confirmed ||
      status == BookingStatus.enRoute ||
      status == BookingStatus.arrived ||
      status == BookingStatus.inProgress;

  bool get isPast =>
      status == BookingStatus.completed || status == BookingStatus.cancelled;

  String get statusLabel {
    switch (status) {
      case BookingStatus.confirmed:
        return 'CONFIRMED';
      case BookingStatus.enRoute:
        return 'EN ROUTE';
      case BookingStatus.arrived:
        return 'ARRIVED';
      case BookingStatus.inProgress:
        return 'IN PROGRESS';
      case BookingStatus.completed:
        return 'COMPLETED';
      case BookingStatus.cancelled:
        return 'CANCELLED';
    }
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      professionalId: json['professionalId'] as String,
      professionalName: json['professionalName'] as String,
      trade: json['trade'] as String? ?? '',
      service: json['service'] as String,
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      location: json['location'] as String,
      description: json['description'] as String? ?? '',
      serviceFeeRwf: json['serviceFeeRwf'] as int,
      status: BookingStatus.values.firstWhere(
        (value) => value.name == json['status'],
        orElse: () => BookingStatus.confirmed,
      ),
      paymentMethod: PaymentMethod.values.firstWhere(
        (value) => value.name == json['paymentMethod'],
        orElse: () => PaymentMethod.mtnMomo,
      ),
      paid: json['paid'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      paymentReference: json['paymentReference'] as String?,
      paymentStatus: json['paymentStatus'] as String?,
      cancellationFeeRwf: json['cancellationFeeRwf'] as int?,
      refundAmountRwf: json['refundAmountRwf'] as int?,
      cancelledAt: json['cancelledAt'] == null
          ? null
          : DateTime.parse(json['cancelledAt'] as String),
    );
  }

  Booking copyWith({
    BookingStatus? status,
    int? cancellationFeeRwf,
    int? refundAmountRwf,
    DateTime? cancelledAt,
  }) {
    return Booking(
      id: id,
      professionalId: professionalId,
      professionalName: professionalName,
      trade: trade,
      service: service,
      scheduledAt: scheduledAt,
      location: location,
      description: description,
      serviceFeeRwf: serviceFeeRwf,
      status: status ?? this.status,
      paymentMethod: paymentMethod,
      paid: paid,
      createdAt: createdAt,
      paymentReference: paymentReference,
      paymentStatus: paymentStatus,
      cancellationFeeRwf: cancellationFeeRwf ?? this.cancellationFeeRwf,
      refundAmountRwf: refundAmountRwf ?? this.refundAmountRwf,
      cancelledAt: cancelledAt ?? this.cancelledAt,
    );
  }
}

extension PaymentMethodLabel on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.mtnMomo:
        return 'MTN MoMo';
      case PaymentMethod.airtelMoney:
        return 'Airtel Money';
      case PaymentMethod.card:
        return 'Visa / Mastercard';
    }
  }

  String get hint {
    switch (this) {
      case PaymentMethod.mtnMomo:
        return 'Pay with MTN Mobile Money';
      case PaymentMethod.airtelMoney:
        return 'Pay with Airtel Money';
      case PaymentMethod.card:
        return 'Pay with a debit or credit card';
    }
  }
}
