import '../entities/center.dart';
import '../entities/subscription_plan.dart';
import '../entities/subscription_payment_details.dart';

abstract class CenterRepository {
  Future<HealthcareCenter> registerCenter(Map<String, dynamic> data);
  Future<HealthcareCenter> getMyCenter();
  Future<List<SubscriptionPlan>> getSubscriptionPlans();
  Future<SubscriptionPaymentDetails> initiateSubscriptionPayment(String centerId, String planId, String billingCycle);
}
