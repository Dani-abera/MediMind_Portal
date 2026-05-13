import '../entities/center.dart';
import '../entities/subscription_plan.dart';

abstract class CenterRepository {
  Future<HealthcareCenter> registerCenter(Map<String, dynamic> data);
  Future<HealthcareCenter> getMyCenter();
  Future<List<SubscriptionPlan>> getSubscriptionPlans();
  Future<String> initiateSubscriptionPayment(String centerId, String planId);
}
