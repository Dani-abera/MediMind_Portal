import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/platform_doctor.dart';
import '../repositories/platform_doctors_repository.dart';

class GetPlatformDoctorDetailUseCase {
  final PlatformDoctorsRepository _repo;
  GetPlatformDoctorDetailUseCase(this._repo);

  Future<Either<Failure, PlatformDoctor>> call(String doctorId) =>
      _repo.getDoctorDetail(doctorId);
}
