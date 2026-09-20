class CommissionBreakdown {
  const CommissionBreakdown({
    required this.grossAmount,
    required this.commissionRate,
    required this.commissionAmount,
    required this.professionalPayout,
    required this.platformRevenue,
  });

  final int grossAmount;
  final double commissionRate;
  final int commissionAmount;
  final int professionalPayout;
  final int platformRevenue;
}
