import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import '../../../domain/entities/platform_subscription.dart';
import '../../../domain/usecases/get_platform_subscriptions_usecase.dart';
import '../../../domain/usecases/change_plan_usecase.dart';

part 'platform_subscriptions_event.dart';
part 'platform_subscriptions_state.dart';

class PlatformSubscriptionsBloc extends Bloc<PlatformSubscriptionsEvent, PlatformSubscriptionsState> {
  final GetPlatformSubscriptionsUseCase _getSubscriptions;
  final ChangePlanUseCase _changePlan;

  String? _planFilter;
  String? _statusFilter;
  int _page = 1;
  static const _pageSize = 20;

  PlatformSubscriptionsBloc({
    required GetPlatformSubscriptionsUseCase getSubscriptions,
    required ChangePlanUseCase changePlan,
  })  : _getSubscriptions = getSubscriptions,
        _changePlan = changePlan,
        super(const PlatformSubscriptionsInitial()) {
    on<PlatformSubscriptionsStarted>(_onStarted, transformer: droppable());
    on<PlatformSubscriptionsFiltered>(_onFiltered, transformer: droppable());
    on<PlatformSubscriptionsPageChanged>(_onPageChanged, transformer: droppable());
    on<PlatformSubscriptionsRefreshed>(_onRefreshed, transformer: droppable());
    on<SubscriptionChangePlanRequested>(_onChangePlan, transformer: sequential());
  }

  Future<void> _fetch(Emitter<PlatformSubscriptionsState> emit) async {
    emit(const PlatformSubscriptionsLoading());
    final result = await _getSubscriptions(plan: _planFilter, status: _statusFilter, page: _page, pageSize: _pageSize);
    result.fold(
      (f) => emit(PlatformSubscriptionsError(f.message)),
      (r) => emit(PlatformSubscriptionsLoaded(subscriptions: r.subscriptions, total: r.total, page: _page)),
    );
  }

  Future<void> _onStarted(PlatformSubscriptionsStarted event, Emitter<PlatformSubscriptionsState> emit) async {
    _planFilter = event.planFilter;
    _statusFilter = event.statusFilter;
    _page = 1;
    await _fetch(emit);
  }

  Future<void> _onFiltered(PlatformSubscriptionsFiltered event, Emitter<PlatformSubscriptionsState> emit) async {
    _planFilter = event.planFilter;
    _statusFilter = event.statusFilter;
    _page = 1;
    await _fetch(emit);
  }

  Future<void> _onPageChanged(PlatformSubscriptionsPageChanged event, Emitter<PlatformSubscriptionsState> emit) async {
    _page = event.page;
    await _fetch(emit);
  }

  Future<void> _onRefreshed(PlatformSubscriptionsRefreshed event, Emitter<PlatformSubscriptionsState> emit) async {
    emit(const PlatformSubscriptionsLoading());
    await _fetch(emit);
  }

  Future<void> _onChangePlan(SubscriptionChangePlanRequested event, Emitter<PlatformSubscriptionsState> emit) async {
    final result = await _changePlan(event.centerId, plan: event.plan, startDate: event.startDate, endDate: event.endDate, reason: event.reason);
    result.fold(
      (f) => emit(PlatformSubscriptionsActionError(f.message)),
      (_) {
        emit(const PlatformSubscriptionsActionSuccess('Plan changed successfully'));
        add(const PlatformSubscriptionsRefreshed());
      },
    );
  }
}
