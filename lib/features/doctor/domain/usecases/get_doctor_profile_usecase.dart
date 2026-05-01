import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/doctor_repository.dart';
import '../entities/doctor_profile.dart';

class GetDoctorProfileUseCase {
  final DoctorRepository _repo;
  GetDoctorProfileUseCase(this._repo);
  Future<Either<Failure, DoctorProfile>> call() => _repo.getProfile();
}
