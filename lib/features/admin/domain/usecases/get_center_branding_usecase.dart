import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/center_branding.dart';
import '../repositories/center_settings_repository.dart';

class GetCenterBrandingUseCase {
  final CenterSettingsRepository _repo;
  GetCenterBrandingUseCase(this._repo);

  Future<Either<Failure, CenterBranding>> call(String centerId) =>
      _repo.getCenterBranding(centerId);
}
