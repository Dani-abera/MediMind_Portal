import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/platform_subscription.dart';
import '../repositories/platform_subscriptions_repository.dart';

class GetPlatformSubscriptionsUseCase {
  final PlatformSubscriptionsRepository _repo;
  GetPlatformSubscriptionsUseCase(this._repo);

  Future<Either<Failure, ({List<PlatformSubscription> subscriptions, int total})>> call({
    String? plan,
    String? status,
    int page = 1,
    int pageSize = 20,
  }) =>
      _repo.getSubscriptions(plan: plan, status: status, page: page, pageSize: pageSize);
}
