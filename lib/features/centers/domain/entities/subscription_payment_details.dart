class SubscriptionPaymentDetails {
  final String paymentId;
  final String paymentRef;
  final double amount;
  final String currency;
  final String planName;
  final String billingCycle;
  final String checkoutUrl;

  const SubscriptionPaymentDetails({
    required this.paymentId,
    required this.paymentRef,
    required this.amount,
    required this.currency,
    required this.planName,
    required this.billingCycle,
    required this.checkoutUrl,
  });
}
