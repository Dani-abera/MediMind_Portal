import '../../domain/entities/subscription_payment_details.dart';

class SubscriptionPaymentDetailsModel extends SubscriptionPaymentDetails {
  const SubscriptionPaymentDetailsModel({
    required super.paymentId,
    required super.paymentRef,
    required super.amount,
    required super.currency,
    required super.planName,
    required super.billingCycle,
  });

  factory SubscriptionPaymentDetailsModel.fromJson(Map<String, dynamic> j) =>
      SubscriptionPaymentDetailsModel(
        paymentId: j['paymentId'] as String? ?? '',
        paymentRef: j['paymentRef'] as String? ?? '',
        amount: (j['amount'] as num?)?.toDouble() ?? 0.0,
        currency: j['currency'] as String? ?? 'ETB',
        planName: j['planName'] as String? ?? '',
        billingCycle: j['billingCycle'] as String? ?? 'Monthly',
      );
}
