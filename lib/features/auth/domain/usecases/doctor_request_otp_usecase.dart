import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class DoctorRequestOtpUseCase {
  final AuthRepository _repo;
  const DoctorRequestOtpUseCase(this._repo);

  Future<Either<Failure, void>> call(String badgeNumber) =>
      _repo.doctorRequestOtp(badgeNumber);
}
