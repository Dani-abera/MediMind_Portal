import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/center_config.dart';
import '../repositories/center_settings_repository.dart';

class GetCenterConfigUseCase {
  final CenterSettingsRepository _repo;
  GetCenterConfigUseCase(this._repo);

  Future<Either<Failure, CenterConfig>> call(String centerId) =>
      _repo.getCenterConfig(centerId);
}
