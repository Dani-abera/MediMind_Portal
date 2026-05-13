import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/doctor_at_center.dart';
import '../repositories/admin_doctor_repository.dart';

class AddScheduleExceptionUseCase {
  final AdminDoctorRepository _repo;
  AddScheduleExceptionUseCase(this._repo);

  Future<Either<Failure, void>> call(String doctorId, String centerId, ScheduleException exception) =>
      _repo.addScheduleException(doctorId, centerId, exception);
}
