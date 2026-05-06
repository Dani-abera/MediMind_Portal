import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/platform_settings.dart';
import '../repositories/platform_settings_repository.dart';

class SavePlatformSettingsUseCase {
  final PlatformSettingsRepository _repo;
  SavePlatformSettingsUseCase(this._repo);

  Future<Either<Failure, PlatformSettings>> call(PlatformSettings settings) =>
      _repo.saveSettings(settings);
}
