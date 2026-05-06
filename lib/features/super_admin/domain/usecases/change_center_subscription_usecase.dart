import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/platform_centers_repository.dart';

class ChangeCenterSubscriptionUseCase {
  final PlatformCentersRepository _repo;
  ChangeCenterSubscriptionUseCase(this._repo);

  Future<Either<Failure, void>> call(String centerId, {required String plan, required DateTime startDate, required DateTime endDate, required String reason}) =>
      _repo.changeSubscription(centerId, plan: plan, startDate: startDate, endDate: endDate, reason: reason);
}
