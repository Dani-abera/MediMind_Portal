part of 'subscription_plans_cubit.dart';

abstract class SubscriptionPlansState extends Equatable {
  const SubscriptionPlansState();
  @override
  List<Object?> get props => [];
}

class SubscriptionPlansInitial extends SubscriptionPlansState {
  const SubscriptionPlansInitial();
}

class SubscriptionPlansLoading extends SubscriptionPlansState {
  const SubscriptionPlansLoading();
}

class SubscriptionPlansLoaded extends SubscriptionPlansState {
  final List<SubscriptionPlan> plans;
  const SubscriptionPlansLoaded(this.plans);
  @override
  List<Object?> get props => [plans];
}

class SubscriptionPlansError extends SubscriptionPlansState {
  final String message;
  const SubscriptionPlansError(this.message);
  @override
  List<Object?> get props => [message];
}
