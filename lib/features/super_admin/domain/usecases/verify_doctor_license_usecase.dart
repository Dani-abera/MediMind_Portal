import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/platform_doctors_repository.dart';

class VerifyDoctorLicenseUseCase {
  final PlatformDoctorsRepository _repo;
  VerifyDoctorLicenseUseCase(this._repo);

  Future<Either<Failure, void>> call(String doctorId, {String? notes}) =>
      _repo.verifyDoctorLicense(doctorId, notes: notes);
}
