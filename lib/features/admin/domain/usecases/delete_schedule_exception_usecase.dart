import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/admin_doctor_repository.dart';

class DeleteScheduleExceptionUseCase {
  final AdminDoctorRepository _repo;
  DeleteScheduleExceptionUseCase(this._repo);

  Future<Either<Failure, void>> call(String doctorId, String centerId, DateTime date) =>
      _repo.deleteScheduleException(doctorId, centerId, date);
}
