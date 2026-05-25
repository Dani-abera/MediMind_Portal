import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/platform_center.dart';

abstract class PlatformCentersRepository {
  Future<Either<Failure, ({List<PlatformCenter> centers, int total})>> getCenters({
    String? status,
    int page = 1,
    int pageSize = 20,
  });
  Future<Either<Failure, PlatformCenter>> getCenterDetail(String centerId);
  Future<Either<Failure, void>> approveCenter(String centerId, {required DateTime trialEndDate, String? notes});
  Future<Either<Failure, void>> rejectCenter(String centerId, {required String reason});
  Future<Either<Failure, void>> suspendCenter(String centerId, {required String reason, DateTime? suspendUntil});
  Future<Either<Failure, void>> reactivateCenter(String centerId);
  Future<Either<Failure, void>> changeSubscription(String centerId, {required String plan, required DateTime startDate, required DateTime endDate, required String reason});
  Future<Either<Failure, PlatformCenter>> verifyPayment(String centerId);
}
