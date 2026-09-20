import '../core/app_config.dart';
import '../models/escrow.dart';
import '../models/payment.dart';

class EscrowRequest {
  const EscrowRequest({
    required this.bookingId,
    required this.amountRwf,
    required this.method,
    this.phoneNumber,
  });

  final String bookingId;
  final int amountRwf;
  final PaymentMethod method;
  final String? phoneNumber;
}

abstract class EscrowProvider {
  String get name;
  Future<EscrowHold> hold(EscrowRequest request);
  Future<EscrowHold> release(EscrowHold hold, {required int marketplaceFeeRwf});
  Future<EscrowHold> refund(EscrowHold hold, {int feeRwf = 0});
}

bool _shouldFail(EscrowRequest request) {
  final phone = request.phoneNumber?.replaceAll(RegExp(r'\D'), '') ?? '';
  return phone.endsWith('0000');
}

class MockMtnMoMoEscrow implements EscrowProvider {
  @override
  String get name => 'MTN MoMo Collection/Disbursement';

  @override
  Future<EscrowHold> hold(EscrowRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (_shouldFail(request)) {
      throw Exception('MTN MoMo pre-authorisation was declined.');
    }
    return EscrowHold(
      id: 'escrow-mtn-${DateTime.now().millisecondsSinceEpoch}',
      bookingId: request.bookingId,
      amountRwf: request.amountRwf,
      status: EscrowStatus.held,
      createdAt: DateTime.now(),
      providerReference: 'mtn-hold-${request.bookingId}',
    );
  }

  @override
  Future<EscrowHold> release(
    EscrowHold hold, {
    required int marketplaceFeeRwf,
  }) async {
    final payout = hold.amountRwf - marketplaceFeeRwf;
    return hold.copyWith(
      status: EscrowStatus.released,
      marketplaceFeeRwf: marketplaceFeeRwf,
      providerPayoutRwf: payout < 0 ? 0 : payout,
      releasedAt: DateTime.now(),
      providerReference: 'mtn-payout-${hold.bookingId}',
    );
  }

  @override
  Future<EscrowHold> refund(EscrowHold hold, {int feeRwf = 0}) async {
    return hold.copyWith(
      status: EscrowStatus.refunded,
      marketplaceFeeRwf: feeRwf,
      providerPayoutRwf: 0,
      refundedAt: DateTime.now(),
      providerReference: 'mtn-refund-${hold.bookingId}',
    );
  }
}

class MockIremboPayEscrow implements EscrowProvider {
  @override
  String get name => 'IremboPay';

  @override
  Future<EscrowHold> hold(EscrowRequest request) {
    return MockMtnMoMoEscrow().hold(request);
  }

  @override
  Future<EscrowHold> release(
    EscrowHold hold, {
    required int marketplaceFeeRwf,
  }) {
    return MockMtnMoMoEscrow().release(
      hold,
      marketplaceFeeRwf: marketplaceFeeRwf,
    );
  }

  @override
  Future<EscrowHold> refund(EscrowHold hold, {int feeRwf = 0}) {
    return MockMtnMoMoEscrow().refund(hold, feeRwf: feeRwf);
  }
}

class EscrowService {
  EscrowService(this._provider, {this.commissionRate = AppConfig.commissionRate});

  final EscrowProvider _provider;
  final double commissionRate;

  Future<EscrowHold> hold(EscrowRequest request) => _provider.hold(request);

  Future<EscrowHold> releaseToProvider(EscrowHold hold) {
    if (hold.status != EscrowStatus.held) {
      throw StateError('Escrow is not held.');
    }
    final fee = (hold.amountRwf * commissionRate).round();
    return _provider.release(hold, marketplaceFeeRwf: fee);
  }

  Future<EscrowHold> refundToClient(EscrowHold hold, {int feeRwf = 0}) {
    if (hold.status != EscrowStatus.held) {
      throw StateError('Escrow is not held.');
    }
    return _provider.refund(hold, feeRwf: feeRwf);
  }
}

EscrowService buildMockEscrowService() {
  return EscrowService(MockMtnMoMoEscrow());
}
