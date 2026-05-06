import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import '../../../domain/entities/platform_analytics.dart';
import '../../../domain/usecases/get_platform_analytics_usecase.dart';

part 'platform_analytics_event.dart';
part 'platform_analytics_state.dart';

class PlatformAnalyticsBloc extends Bloc<PlatformAnalyticsEvent, PlatformAnalyticsState> {
  final GetPlatformAnalyticsUseCase _getAnalytics;

  String _period = 'last30';

  PlatformAnalyticsBloc({required GetPlatformAnalyticsUseCase getAnalytics})
      : _getAnalytics = getAnalytics,
        super(const PlatformAnalyticsInitial()) {
    on<PlatformAnalyticsStarted>(_onStarted, transformer: droppable());
    on<PlatformAnalyticsPeriodChanged>(_onPeriodChanged, transformer: droppable());
  }

  Future<void> _fetch(Emitter<PlatformAnalyticsState> emit) async {
    emit(const PlatformAnalyticsLoading());
    final result = await _getAnalytics(period: _period);
    result.fold(
      (f) => emit(PlatformAnalyticsError(f.message)),
      (data) => emit(PlatformAnalyticsLoaded(data)),
    );
  }

  Future<void> _onStarted(PlatformAnalyticsStarted event, Emitter<PlatformAnalyticsState> emit) async {
    await _fetch(emit);
  }

  Future<void> _onPeriodChanged(PlatformAnalyticsPeriodChanged event, Emitter<PlatformAnalyticsState> emit) async {
    _period = event.period;
    await _fetch(emit);
  }
}
