import '../models/payment.dart';
import 'payment_provider.dart';

bool _shouldFail(PaymentRequest request) {
  final phone = request.phoneNumber?.replaceAll(RegExp(r'\D'), '') ?? '';
  return phone.endsWith('0000');
}

class MockMtnMomoProvider implements PaymentProvider {
  @override
  PaymentMethod get method => PaymentMethod.mtnMomo;

  @override
  Future<PaymentResult> charge(PaymentRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (_shouldFail(request)) {
      return PaymentResult(
        status: PaymentStatus.failed,
        reference: 'mtn-fail-${DateTime.now().millisecondsSinceEpoch}',
        message: 'MTN MoMo request was declined. Check the number and try again.',
      );
    }
    return PaymentResult(
      status: PaymentStatus.success,
      reference: 'mtn-${DateTime.now().millisecondsSinceEpoch}',
      message: 'MTN MoMo payment confirmed.',
    );
  }
}

class MockAirtelMoneyProvider implements PaymentProvider {
  @override
  PaymentMethod get method => PaymentMethod.airtelMoney;

  @override
  Future<PaymentResult> charge(PaymentRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (_shouldFail(request)) {
      return PaymentResult(
        status: PaymentStatus.failed,
        reference: 'airtel-fail-${DateTime.now().millisecondsSinceEpoch}',
        message: 'Airtel Money request was declined. Check the number and try again.',
      );
    }
    return PaymentResult(
      status: PaymentStatus.success,
      reference: 'airtel-${DateTime.now().millisecondsSinceEpoch}',
      message: 'Airtel Money payment confirmed.',
    );
  }
}

class MockCardProvider implements PaymentProvider {
  @override
  PaymentMethod get method => PaymentMethod.card;

  @override
  Future<PaymentResult> charge(PaymentRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (_shouldFail(request)) {
      return PaymentResult(
        status: PaymentStatus.failed,
        reference: 'card-fail-${DateTime.now().millisecondsSinceEpoch}',
        message: 'Card payment was declined.',
      );
    }
    return PaymentResult(
      status: PaymentStatus.success,
      reference: 'card-${DateTime.now().millisecondsSinceEpoch}',
      message: 'Card payment confirmed.',
    );
  }
}

PaymentGateway buildMockPaymentGateway() {
  return PaymentGateway({
    PaymentMethod.mtnMomo: MockMtnMomoProvider(),
    PaymentMethod.airtelMoney: MockAirtelMoneyProvider(),
    PaymentMethod.card: MockCardProvider(),
  });
}
