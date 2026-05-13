import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/doctor_at_center.dart';
import '../repositories/admin_doctor_repository.dart';

class GetScheduleExceptionsUseCase {
  final AdminDoctorRepository _repo;
  GetScheduleExceptionsUseCase(this._repo);

  Future<Either<Failure, List<ScheduleException>>> call(String doctorId, String centerId) =>
      _repo.getScheduleExceptions(doctorId, centerId);
}
