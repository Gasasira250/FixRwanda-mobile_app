enum PaymentMethod {
  mtnMomo,
  airtelMoney,
  card,
}

enum PaymentStatus {
  pending,
  success,
  failed,
}

class Payment {
  final String id;
  final String bookingId;
  final PaymentMethod method;
  final int amount;
  final PaymentStatus status;
  final DateTime createdAt;
  final String? transactionReference;

  const Payment({
    required this.id,
    required this.bookingId,
    required this.method,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.transactionReference,
  });

  Payment copyWith({
    String? id,
    String? bookingId,
    PaymentMethod? method,
    int? amount,
    PaymentStatus? status,
    DateTime? createdAt,
    String? transactionReference,
  }) {
    return Payment(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      method: method ?? this.method,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      transactionReference:
          transactionReference ?? this.transactionReference,
    );
  }
}