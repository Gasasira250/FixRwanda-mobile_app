import '../models/professional.dart';
import '../models/provider_verification.dart';

abstract class VerificationRepository {
  Future<Professional> submitNidaKyc({
    required String nidaNumber,
    required String selfieRef,
  });
  Future<Professional> submitIremboCertificate({required String documentRef});
  Future<Professional> submitTradeCertificate({
    required TradeCertificateKind kind,
    required String documentRef,
  });
  Map<String, dynamic> verificationFlag(String professionalId);
}
