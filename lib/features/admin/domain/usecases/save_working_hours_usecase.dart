import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/working_hours.dart';
import '../repositories/center_settings_repository.dart';

class SaveWorkingHoursUseCase {
  final CenterSettingsRepository _repo;
  SaveWorkingHoursUseCase(this._repo);

  Future<Either<Failure, WorkingHours>> call(String centerId, WorkingHours hours) =>
      _repo.saveWorkingHours(centerId, hours);
}
