import 'payment.dart';

enum BookingStatus {
  pending,
  broadcasting,
  accepted,
  enRoute,
  arrived,
  inProgress,
  awaitingOtp,
  completed,
  disputed,
  cancelled,
  expired,
}

class Booking {
  final String id;
  final String customerId;
  final String professionalId;
  final String serviceId;
  final String serviceName;
  final String category;
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
  final String? escrowId;
  final String? district;
  final String? sector;
  final DateTime? broadcastExpiresAt;
  final int broadcastRound;
  final List<String> offeredProviderIds;
  final List<String> currentOfferIds;
  final String? completionOtp;
  final String? startJobPhotoRef;
  final DateTime? startedAt;
  final double? providerLatitude;
  final double? providerLongitude;
  final DateTime? lastLocationAt;
  final PaymentState paymentState;
  final int platformFeeRwf;
  final String? afterPhotoUrl;
  final String? disputeReason;

  const Booking({
    required this.id,
    required this.customerId,
    this.professionalId = '',
    required this.serviceId,
    required this.serviceName,
    this.category = '',
    this.professionalName = 'Waiting for a verified professional',
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
    this.escrowId,
    this.district,
    this.sector,
    this.broadcastExpiresAt,
    this.broadcastRound = 0,
    this.offeredProviderIds = const [],
    this.currentOfferIds = const [],
    this.completionOtp,
    this.startJobPhotoRef,
    this.startedAt,
    this.providerLatitude,
    this.providerLongitude,
    this.lastLocationAt,
    this.paymentState = PaymentState.initiated,
    this.platformFeeRwf = 0,
    this.afterPhotoUrl,
    this.disputeReason,
  });

  bool get isAssigned => professionalId.isNotEmpty;

  String? get beforePhotoUrl => startJobPhotoRef;

  Booking copyWith({
    String? id,
    String? customerId,
    String? professionalId,
    String? serviceId,
    String? serviceName,
    String? category,
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
    String? escrowId,
    String? district,
    String? sector,
    DateTime? broadcastExpiresAt,
    int? broadcastRound,
    List<String>? offeredProviderIds,
    List<String>? currentOfferIds,
    String? completionOtp,
    String? startJobPhotoRef,
    DateTime? startedAt,
    double? providerLatitude,
    double? providerLongitude,
    DateTime? lastLocationAt,
    PaymentState? paymentState,
    int? platformFeeRwf,
    String? afterPhotoUrl,
    String? disputeReason,
  }) {
    return Booking(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      professionalId: professionalId ?? this.professionalId,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      category: category ?? this.category,
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
      escrowId: escrowId ?? this.escrowId,
      district: district ?? this.district,
      sector: sector ?? this.sector,
      broadcastExpiresAt: broadcastExpiresAt ?? this.broadcastExpiresAt,
      broadcastRound: broadcastRound ?? this.broadcastRound,
      offeredProviderIds: offeredProviderIds ?? this.offeredProviderIds,
      currentOfferIds: currentOfferIds ?? this.currentOfferIds,
      completionOtp: completionOtp ?? this.completionOtp,
      startJobPhotoRef: startJobPhotoRef ?? this.startJobPhotoRef,
      startedAt: startedAt ?? this.startedAt,
      providerLatitude: providerLatitude ?? this.providerLatitude,
      providerLongitude: providerLongitude ?? this.providerLongitude,
      lastLocationAt: lastLocationAt ?? this.lastLocationAt,
      paymentState: paymentState ?? this.paymentState,
      platformFeeRwf: platformFeeRwf ?? this.platformFeeRwf,
      afterPhotoUrl: afterPhotoUrl ?? this.afterPhotoUrl,
      disputeReason: disputeReason ?? this.disputeReason,
    );
  }
}
