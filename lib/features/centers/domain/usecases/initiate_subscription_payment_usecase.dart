import '../entities/subscription_payment_details.dart';
import '../repositories/center_repository.dart';

class InitiateSubscriptionPaymentUseCase {
  final CenterRepository _repository;

  InitiateSubscriptionPaymentUseCase(this._repository);

  Future<SubscriptionPaymentDetails> call(String centerId, String planId, String billingCycle) =>
      _repository.initiateSubscriptionPayment(centerId, planId, billingCycle);
}
