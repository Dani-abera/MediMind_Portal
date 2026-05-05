import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/doctor_at_center.dart';
import '../repositories/admin_doctor_repository.dart';
class GetDoctorScheduleUseCase {
  final AdminDoctorRepository _repo;
  GetDoctorScheduleUseCase(this._repo);
  Future<Either<Failure, DoctorScheduleConfig?>> call(String doctorId, String centerId) =>
      _repo.getDoctorSchedule(doctorId, centerId);
}
