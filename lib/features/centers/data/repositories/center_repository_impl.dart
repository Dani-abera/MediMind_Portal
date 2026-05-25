import '../../domain/entities/center.dart';
import '../../domain/entities/subscription_plan.dart';
import '../../domain/entities/subscription_payment_details.dart';
import '../../domain/repositories/center_repository.dart';
import '../datasources/center_remote_datasource.dart';

class CenterRepositoryImpl implements CenterRepository {
  final CenterRemoteDataSource _remoteDataSource;

  CenterRepositoryImpl(this._remoteDataSource);

  @override
  Future<HealthcareCenter> registerCenter(Map<String, dynamic> data) =>
      _remoteDataSource.registerCenter(data);

  @override
  Future<HealthcareCenter> getMyCenter() => _remoteDataSource.getMyCenter();

  @override
  Future<List<SubscriptionPlan>> getSubscriptionPlans() =>
      _remoteDataSource.getSubscriptionPlans();

  @override
  Future<SubscriptionPaymentDetails> initiateSubscriptionPayment(
          String centerId, String planId, String billingCycle) =>
      _remoteDataSource.initiateSubscriptionPayment(centerId, planId, billingCycle);
}
