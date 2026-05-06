import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/platform_settings.dart';
import '../repositories/platform_settings_repository.dart';

class GetPlatformSettingsUseCase {
  final PlatformSettingsRepository _repo;
  GetPlatformSettingsUseCase(this._repo);

  Future<Either<Failure, PlatformSettings>> call() =>
      _repo.getSettings();
}
