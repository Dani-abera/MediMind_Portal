import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/admin_doctor_repository.dart';
class RemoveDoctorFromCenterUseCase {
  final AdminDoctorRepository _repo;
  RemoveDoctorFromCenterUseCase(this._repo);
  Future<Either<Failure, void>> call(String centerId, String doctorId) => _repo.removeDoctor(centerId, doctorId);
}
