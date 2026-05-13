import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../centers/domain/entities/subscription_plan.dart';
import '../../../../centers/domain/usecases/get_subscription_plans_usecase.dart';

part 'subscription_plans_state.dart';

class SubscriptionPlansCubit extends Cubit<SubscriptionPlansState> {
  final GetSubscriptionPlansUseCase _getPlans;

  SubscriptionPlansCubit({required GetSubscriptionPlansUseCase getPlans})
      : _getPlans = getPlans,
        super(const SubscriptionPlansInitial());

  Future<void> loadPlans() async {
    emit(const SubscriptionPlansLoading());
    try {
      final plans = await _getPlans();
      emit(SubscriptionPlansLoaded(plans));
    } catch (e) {
      emit(SubscriptionPlansError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
