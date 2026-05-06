import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/platform_subscriptions_repository.dart';

class ChangePlanUseCase {
  final PlatformSubscriptionsRepository _repo;
  ChangePlanUseCase(this._repo);

  Future<Either<Failure, void>> call(String centerId, {required String plan, required DateTime startDate, required DateTime endDate, required String reason}) =>
      _repo.changePlan(centerId, plan: plan, startDate: startDate, endDate: endDate, reason: reason);
}
