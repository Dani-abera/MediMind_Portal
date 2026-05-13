import '../entities/subscription_plan.dart';
import '../repositories/center_repository.dart';

class GetSubscriptionPlansUseCase {
  final CenterRepository _repository;

  GetSubscriptionPlansUseCase(this._repository);

  Future<List<SubscriptionPlan>> call() => _repository.getSubscriptionPlans();
}
