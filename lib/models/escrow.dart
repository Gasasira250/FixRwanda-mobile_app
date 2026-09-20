enum EscrowStatus {
  none,
  held,
  released,
  refunded,
}

class EscrowHold {
  const EscrowHold({
    required this.id,
    required this.bookingId,
    required this.amountRwf,
    required this.status,
    required this.createdAt,
    this.providerPayoutRwf = 0,
    this.marketplaceFeeRwf = 0,
    this.providerReference,
    this.releasedAt,
    this.refundedAt,
  });

  final String id;
  final String bookingId;
  final int amountRwf;
  final EscrowStatus status;
  final DateTime createdAt;
  final int providerPayoutRwf;
  final int marketplaceFeeRwf;
  final String? providerReference;
  final DateTime? releasedAt;
  final DateTime? refundedAt;

  EscrowHold copyWith({
    EscrowStatus? status,
    int? providerPayoutRwf,
    int? marketplaceFeeRwf,
    String? providerReference,
    DateTime? releasedAt,
    DateTime? refundedAt,
  }) {
    return EscrowHold(
      id: id,
      bookingId: bookingId,
      amountRwf: amountRwf,
      status: status ?? this.status,
      createdAt: createdAt,
      providerPayoutRwf: providerPayoutRwf ?? this.providerPayoutRwf,
      marketplaceFeeRwf: marketplaceFeeRwf ?? this.marketplaceFeeRwf,
      providerReference: providerReference ?? this.providerReference,
      releasedAt: releasedAt ?? this.releasedAt,
      refundedAt: refundedAt ?? this.refundedAt,
    );
  }
}
