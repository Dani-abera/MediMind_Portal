import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/doctor_at_center.dart';
import '../repositories/admin_doctor_repository.dart';
class ConfigureDoctorScheduleUseCase {
  final AdminDoctorRepository _repo;
  ConfigureDoctorScheduleUseCase(this._repo);
  Future<Either<Failure, void>> call(DoctorScheduleConfig config) => _repo.configureSchedule(config);
}
