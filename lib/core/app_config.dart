class AppConfig {
  AppConfig._();

  static const String market = 'Kigali, Rwanda';
  static const String language = 'English';
  static const String currency = 'RWF';
  static const int transportFeeRwf = 2000;
  static const double commissionRate = 0.15;
  static const double minCommissionRate = 0.10;
  static const double maxCommissionRate = 0.15;
  static const double providerPayoutRate = 0.85;
  static const Duration broadcastTimeout = Duration(minutes: 15);
  static const bool useLivePaymentProviders = false;
  static const bool useLiveIdentitySdk = false;
  static const bool allowCashPayouts = false;
  static const String realtimeServerUrl = '';
}
