import 'package:flutter_test/flutter_test.dart';
import 'package:fixrwanda/domain/commission_service.dart';

void main() {
  test('applies 10 percent commission by default', () {
    const service = CommissionService();
    final breakdown = service.calculate(20000);
    expect(breakdown.commissionAmount, 2000);
    expect(breakdown.professionalPayout, 18000);
    expect(breakdown.platformRevenue, 2000);
  });

  test('clamps commission to 10-15 percent', () {
    const high = CommissionService(rate: 0.5);
    expect(high.calculate(10000).commissionRate, 0.15);
    const low = CommissionService(rate: 0.01);
    expect(low.calculate(10000).commissionRate, 0.10);
  });
}
