import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/platform_subscription.dart';

abstract class PlatformSubscriptionsRepository {
  Future<Either<Failure, ({List<PlatformSubscription> subscriptions, int total})>> getSubscriptions({
    String? plan,
    String? status,
    int page = 1,
    int pageSize = 20,
  });
  Future<Either<Failure, void>> changePlan(String centerId, {required String plan, required DateTime startDate, required DateTime endDate, required String reason});
}
