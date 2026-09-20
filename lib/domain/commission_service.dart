import '../core/app_config.dart';
import '../models/commission.dart';

class CommissionService {
  const CommissionService({this.rate = AppConfig.commissionRate});

  final double rate;

  CommissionBreakdown calculate(int grossAmountRwf) {
    final clamped = rate.clamp(
      AppConfig.minCommissionRate,
      AppConfig.maxCommissionRate,
    );
    final commission = (grossAmountRwf * clamped).round();
    final payout = grossAmountRwf - commission;
    return CommissionBreakdown(
      grossAmount: grossAmountRwf,
      commissionRate: clamped,
      commissionAmount: commission,
      professionalPayout: payout < 0 ? 0 : payout,
      platformRevenue: commission,
    );
  }
}
