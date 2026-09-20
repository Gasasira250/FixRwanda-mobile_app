import '../models/user.dart';

abstract class AuthRepository {
  Future<User?> restoreSession();
  Future<User> login({required String identifier, required String password});
  Future<User> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    required UserRole role,
  });
  Future<void> logout();
}
