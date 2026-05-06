import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/platform_doctors_repository.dart';

class SuspendPlatformDoctorUseCase {
  final PlatformDoctorsRepository _repo;
  SuspendPlatformDoctorUseCase(this._repo);

  Future<Either<Failure, void>> call(String doctorId, {required String reason}) =>
      _repo.suspendDoctor(doctorId, reason: reason);
}
