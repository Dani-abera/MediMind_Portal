import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/admin_doctor_repository.dart';
class AddDoctorToCenterUseCase {
  final AdminDoctorRepository _repo;
  AddDoctorToCenterUseCase(this._repo);
  Future<Either<Failure, void>> call(String centerId, String licenseNumber) => _repo.addDoctor(centerId, licenseNumber);
}
