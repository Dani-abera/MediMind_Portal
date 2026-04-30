import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_tokens.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  // Doctor
  Future<Either<Failure, void>> doctorRequestOtp(String badgeNumber);
  Future<Either<Failure, ({User user, AuthTokens tokens})>> doctorVerifyOtp({
    required String badgeNumber,
    required String otpCode,
  });

  // Admin
  Future<Either<Failure, ({User user, AuthTokens tokens, bool requires2fa})>>
      adminLogin({required String email, required String password});
  Future<Either<Failure, ({User user, AuthTokens tokens})>> adminVerifyOtp({
    required String email,
    required String otpCode,
  });

  // Super Admin
  Future<Either<Failure, ({User user, AuthTokens tokens, bool requires2fa})>>
      superAdminLogin({required String email, required String password});
  Future<Either<Failure, ({User user, AuthTokens tokens})>>
      superAdminVerify2fa({
    required String email,
    required String totpCode,
  });

  // Token management
  Future<Either<Failure, AuthTokens>> refreshToken(String refreshToken);
  Future<Either<Failure, void>> logout();

  // Password
  Future<Either<Failure, void>> requestPasswordReset(String email);
  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String newPassword,
  });
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  // Profile
  Future<Either<Failure, User>> getCurrentUser();
}
