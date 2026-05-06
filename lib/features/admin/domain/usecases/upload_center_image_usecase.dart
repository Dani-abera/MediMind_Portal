import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/center_settings_repository.dart';

class UploadCenterImageUseCase {
  final CenterSettingsRepository _repo;
  UploadCenterImageUseCase(this._repo);

  Future<Either<Failure, String>> call(String centerId, String imageType, String filePath) =>
      _repo.uploadCenterImage(centerId, imageType, filePath);
}
