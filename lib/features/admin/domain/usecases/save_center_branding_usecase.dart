import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/center_branding.dart';
import '../repositories/center_settings_repository.dart';

class SaveCenterBrandingUseCase {
  final CenterSettingsRepository _repo;
  SaveCenterBrandingUseCase(this._repo);

  Future<Either<Failure, CenterBranding>> call(String centerId, CenterBranding branding) =>
      _repo.saveCenterBranding(centerId, branding);
}
