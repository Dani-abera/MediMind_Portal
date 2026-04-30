import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_tokens.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class DoctorVerifyOtpUseCase {
  final AuthRepository _repo;
  const DoctorVerifyOtpUseCase(this._repo);

  Future<Either<Failure, ({User user, AuthTokens tokens})>> call({
    required String badgeNumber,
    required String otpCode,
  }) =>
      _repo.doctorVerifyOtp(badgeNumber: badgeNumber, otpCode: otpCode);
}
