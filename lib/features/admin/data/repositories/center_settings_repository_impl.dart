import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/center_config.dart';
import '../../domain/entities/working_hours.dart';
import '../../domain/entities/booking_rules.dart';
import '../../domain/entities/center_branding.dart';
import '../../domain/repositories/center_settings_repository.dart';
import '../datasources/center_settings_remote_datasource.dart';
import '../models/center_config_model.dart';
import '../models/working_hours_model.dart';
import '../models/booking_rules_model.dart';
import '../models/center_branding_model.dart';

class CenterSettingsRepositoryImpl implements CenterSettingsRepository {
  final CenterSettingsRemoteDataSource _remote;
  final NetworkInfo _network;
  CenterSettingsRepositoryImpl(this._remote, this._network);

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() fn) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      return Right(await fn());
    } on NotFoundException catch (_) {
      return const Left(NotFoundFailure('Healthcare center not found'));
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
  Future<Either<Failure, CenterConfig>> getCenterConfig(String centerId) =>
      _guard(() => _remote.getCenterConfig(centerId));

  @override
  Future<Either<Failure, CenterConfig>> saveCenterConfig(String centerId, CenterConfig config) =>
      _guard(() => _remote.saveCenterConfig(
            centerId,
            CenterConfigModel(
              id: config.id,
              centerId: config.centerId,
              name: config.name,
              phone: config.phone,
              email: config.email,
              city: config.city,
              region: config.region,
              fullAddress: config.fullAddress,
              licenseNumber: config.licenseNumber,
              latitude: config.latitude,
              longitude: config.longitude,
              specializations: config.specializations,
              services: config.services,
            ),
          ));

  @override
  Future<Either<Failure, WorkingHours>> getWorkingHours(String centerId) =>
      _guard(() => _remote.getWorkingHours(centerId));

  @override
  Future<Either<Failure, WorkingHours>> saveWorkingHours(String centerId, WorkingHours hours) =>
      _guard(() => _remote.saveWorkingHours(
            centerId,
            WorkingHoursModel(days: hours.days),
          ));

  @override
  Future<Either<Failure, BookingRules>> getBookingRules(String centerId) =>
      _guard(() => _remote.getBookingRules(centerId));

  @override
  Future<Either<Failure, BookingRules>> saveBookingRules(String centerId, BookingRules rules) =>
      _guard(() => _remote.saveBookingRules(
            centerId,
            BookingRulesModel(
              slotDurationMinutes: rules.slotDurationMinutes,
              advanceBookingDays: rules.advanceBookingDays,
              cancellationHoursMin: rules.cancellationHoursMin,
              autoApproveAll: rules.autoApproveAll,
              autoApproveKnownPatients: rules.autoApproveKnownPatients,
              reminder24h: rules.reminder24h,
              reminder2h: rules.reminder2h,
            ),
          ));

  @override
  Future<Either<Failure, CenterBranding>> getCenterBranding(String centerId) =>
      _guard(() => _remote.getCenterBranding(centerId));

  @override
  Future<Either<Failure, CenterBranding>> saveCenterBranding(String centerId, CenterBranding branding) =>
      _guard(() => _remote.saveCenterBranding(
            centerId,
            CenterBrandingModel(
              centerId: branding.centerId,
              logoUrl: branding.logoUrl,
              coverUrl: branding.coverUrl,
              description: branding.description,
            ),
          ));

  @override
  Future<Either<Failure, String>> uploadCenterImage(String centerId, String imageType, String filePath) =>
      _guard(() => _remote.uploadCenterImage(centerId, imageType, filePath));
}
