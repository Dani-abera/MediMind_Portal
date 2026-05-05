import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/doctor_at_center.dart';
import '../repositories/admin_doctor_repository.dart';
class GetDoctorsAtCenterUseCase {
  final AdminDoctorRepository _repo;
  GetDoctorsAtCenterUseCase(this._repo);
  Future<Either<Failure, List<DoctorAtCenter>>> call(String centerId) => _repo.getDoctors(centerId);
}
