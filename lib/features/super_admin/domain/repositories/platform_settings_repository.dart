import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/platform_settings.dart';

abstract class PlatformSettingsRepository {
  Future<Either<Failure, PlatformSettings>> getSettings();
  Future<Either<Failure, PlatformSettings>> saveSettings(PlatformSettings settings);
}
