import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_tokens.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class AdminVerifyOtpUseCase {
  final AuthRepository _repo;
  const AdminVerifyOtpUseCase(this._repo);

  Future<Either<Failure, ({User user, AuthTokens tokens})>> call({
    required String email,
    required String otpCode,
  }) =>
      _repo.adminVerifyOtp(email: email, otpCode: otpCode);
}
