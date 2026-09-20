import '../models/professional.dart';

abstract class AdminRepository {
  Future<List<Professional>> pendingVerifications();
  Future<Professional> setOverallVerification(
    String professionalId,
    VerificationStatus status,
  );
}
