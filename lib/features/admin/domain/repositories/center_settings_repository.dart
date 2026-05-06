import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/center_config.dart';
import '../entities/working_hours.dart';
import '../entities/booking_rules.dart';
import '../entities/center_branding.dart';

abstract class CenterSettingsRepository {
  Future<Either<Failure, CenterConfig>> getCenterConfig(String centerId);
  Future<Either<Failure, CenterConfig>> saveCenterConfig(String centerId, CenterConfig config);
  Future<Either<Failure, WorkingHours>> getWorkingHours(String centerId);
  Future<Either<Failure, WorkingHours>> saveWorkingHours(String centerId, WorkingHours hours);
  Future<Either<Failure, BookingRules>> getBookingRules(String centerId);
  Future<Either<Failure, BookingRules>> saveBookingRules(String centerId, BookingRules rules);
  Future<Either<Failure, CenterBranding>> getCenterBranding(String centerId);
  Future<Either<Failure, CenterBranding>> saveCenterBranding(String centerId, CenterBranding branding);
  Future<Either<Failure, String>> uploadCenterImage(String centerId, String imageType, String filePath);
}
