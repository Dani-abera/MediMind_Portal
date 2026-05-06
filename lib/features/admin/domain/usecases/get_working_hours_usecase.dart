import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/working_hours.dart';
import '../repositories/center_settings_repository.dart';

class GetWorkingHoursUseCase {
  final CenterSettingsRepository _repo;
  GetWorkingHoursUseCase(this._repo);

  Future<Either<Failure, WorkingHours>> call(String centerId) =>
      _repo.getWorkingHours(centerId);
}
