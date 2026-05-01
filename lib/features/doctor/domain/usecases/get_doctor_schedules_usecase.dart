import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/doctor_repository.dart';
import '../entities/doctor_schedule.dart';

class GetDoctorSchedulesUseCase {
  final DoctorRepository _repo;
  GetDoctorSchedulesUseCase(this._repo);
  Future<Either<Failure, List<DoctorSchedule>>> call() => _repo.getSchedules();
}
