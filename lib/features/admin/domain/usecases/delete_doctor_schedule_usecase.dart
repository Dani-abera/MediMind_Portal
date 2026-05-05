import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/admin_doctor_repository.dart';
class DeleteDoctorScheduleUseCase {
  final AdminDoctorRepository _repo;
  DeleteDoctorScheduleUseCase(this._repo);
  Future<Either<Failure, void>> call(String scheduleId) => _repo.deleteSchedule(scheduleId);
}
