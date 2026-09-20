class AuthException implements Exception {
  AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

class MarketplaceException implements Exception {
  MarketplaceException(this.message);
  final String message;
  @override
  String toString() => message;
}
