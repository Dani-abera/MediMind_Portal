import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import '../../../domain/usecases/get_dashboard_data_usecase.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardDataUseCase _getDashboardData;

  DashboardBloc({required GetDashboardDataUseCase getDashboardData})
      : _getDashboardData = getDashboardData,
        super(const DashboardInitial()) {
    on<DashboardStarted>(_onStarted, transformer: droppable());
    on<DashboardRefreshed>(_onRefreshed, transformer: droppable());
  }

  Future<void> _onStarted(
    DashboardStarted event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());
    final result = await _getDashboardData();
    result.fold(
      (f) => emit(DashboardError(f.message)),
      (data) => emit(DashboardLoaded(data)),
    );
  }

  Future<void> _onRefreshed(
    DashboardRefreshed event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());
    final result = await _getDashboardData();
    result.fold(
      (f) => emit(DashboardError(f.message)),
      (data) => emit(DashboardLoaded(data)),
    );
  }
}
