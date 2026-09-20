enum BookingStatus {
  pending,
  confirmed,
  enRoute,
  arrived,
  inProgress,
  completed,
  cancelled,
}

class Booking {
  final String id;
  final String customerId;
  final String professionalId;
  final String serviceId;
  final String serviceName;
  final String professionalName;
  final DateTime scheduledDate;
  final String scheduledTime;
  final String customerAddress;
  final int servicePrice;
  final BookingStatus status;
  final DateTime createdAt;
  final int? cancellationFeeRwf;
  final int? refundAmountRwf;
  final DateTime? cancelledAt;
  final String? paymentId;
  final String? district;
  final String? sector;

  const Booking({
    required this.id,
    required this.customerId,
    required this.professionalId,
    required this.serviceId,
    required this.serviceName,
    required this.professionalName,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.customerAddress,
    required this.servicePrice,
    required this.status,
    required this.createdAt,
    this.cancellationFeeRwf,
    this.refundAmountRwf,
    this.cancelledAt,
    this.paymentId,
    this.district,
    this.sector,
  });

  Booking copyWith({
    String? id,
    String? customerId,
    String? professionalId,
    String? serviceId,
    String? serviceName,
    String? professionalName,
    DateTime? scheduledDate,
    String? scheduledTime,
    String? customerAddress,
    int? servicePrice,
    BookingStatus? status,
    DateTime? createdAt,
    int? cancellationFeeRwf,
    int? refundAmountRwf,
    DateTime? cancelledAt,
    String? paymentId,
    String? district,
    String? sector,
  }) {
    return Booking(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      professionalId: professionalId ?? this.professionalId,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      professionalName: professionalName ?? this.professionalName,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      customerAddress: customerAddress ?? this.customerAddress,
      servicePrice: servicePrice ?? this.servicePrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      cancellationFeeRwf: cancellationFeeRwf ?? this.cancellationFeeRwf,
      refundAmountRwf: refundAmountRwf ?? this.refundAmountRwf,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      paymentId: paymentId ?? this.paymentId,
      district: district ?? this.district,
      sector: sector ?? this.sector,
    );
  }
}
