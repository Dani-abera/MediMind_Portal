import '../repositories/center_repository.dart';

class InitiateSubscriptionPaymentUseCase {
  final CenterRepository _repository;

  InitiateSubscriptionPaymentUseCase(this._repository);

  Future<String> call(String centerId, String planId) =>
      _repository.initiateSubscriptionPayment(centerId, planId);
}
