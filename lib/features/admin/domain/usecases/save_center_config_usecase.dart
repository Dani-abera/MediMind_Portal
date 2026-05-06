import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/center_config.dart';
import '../repositories/center_settings_repository.dart';

class SaveCenterConfigUseCase {
  final CenterSettingsRepository _repo;
  SaveCenterConfigUseCase(this._repo);

  Future<Either<Failure, CenterConfig>> call(String centerId, CenterConfig config) =>
      _repo.saveCenterConfig(centerId, config);
}
