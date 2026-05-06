import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/platform_settings.dart';
import '../../domain/repositories/platform_settings_repository.dart';
import '../datasources/platform_settings_datasource.dart';
import '../models/platform_settings_model.dart';

class PlatformSettingsRepositoryImpl implements PlatformSettingsRepository {
  final PlatformSettingsDatasource _remote;
  final NetworkInfo _network;
  PlatformSettingsRepositoryImpl(this._remote, this._network);

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() fn) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      return Right(await fn());
    } on ForbiddenException catch (e) {
      return Left(ForbiddenFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AppException catch (e) {
      return Left(UnknownFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PlatformSettings>> getSettings() =>
      _guard(() => _remote.getSettings());

  @override
  Future<Either<Failure, PlatformSettings>> saveSettings(PlatformSettings settings) =>
      _guard(() => _remote.saveSettings(PlatformSettingsModel(
            trialFeeEtb: settings.trialFeeEtb,
            basicFeeEtb: settings.basicFeeEtb,
            premiumFeeEtb: settings.premiumFeeEtb,
            maxAdvanceBookingDays: settings.maxAdvanceBookingDays,
            maxSlotDurationMinutes: settings.maxSlotDurationMinutes,
            featureFlags: settings.featureFlags,
            maintenanceMode: settings.maintenanceMode,
            maintenanceMessage: settings.maintenanceMessage,
          )));
}
