import '../models/payment.dart';

class PaymentRequest {
  const PaymentRequest({
    required this.amountRwf,
    required this.method,
    this.phoneNumber,
    this.bookingId,
  });

  final int amountRwf;
  final PaymentMethod method;
  final String? phoneNumber;
  final String? bookingId;
}

class PaymentResult {
  const PaymentResult({
    required this.status,
    required this.reference,
    this.message,
  });

  final PaymentStatus status;
  final String reference;
  final String? message;

  bool get isSuccess => status == PaymentStatus.success;
}

abstract class PaymentProvider {
  PaymentMethod get method;
  Future<PaymentResult> charge(PaymentRequest request);
}

class PaymentGateway {
  PaymentGateway(this._providers);

  final Map<PaymentMethod, PaymentProvider> _providers;

  Future<PaymentResult> charge(PaymentRequest request) {
    final provider = _providers[request.method];
    if (provider == null) {
      return Future.value(
        PaymentResult(
          status: PaymentStatus.failed,
          reference: 'none',
          message: 'No payment provider configured for ${request.method.name}.',
        ),
      );
    }
    return provider.charge(request);
  }
}
