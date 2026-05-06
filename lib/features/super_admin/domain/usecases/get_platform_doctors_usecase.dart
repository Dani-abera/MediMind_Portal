import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/platform_doctor.dart';
import '../repositories/platform_doctors_repository.dart';

class GetPlatformDoctorsUseCase {
  final PlatformDoctorsRepository _repo;
  GetPlatformDoctorsUseCase(this._repo);

  Future<Either<Failure, ({List<PlatformDoctor> doctors, int total})>> call({
    String? status,
    int page = 1,
    int pageSize = 20,
  }) =>
      _repo.getDoctors(status: status, page: page, pageSize: pageSize);
}
