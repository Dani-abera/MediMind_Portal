import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import '../../../domain/entities/platform_dashboard_data.dart';
import '../../../domain/usecases/get_platform_dashboard_usecase.dart';

part 'platform_dashboard_event.dart';
part 'platform_dashboard_state.dart';

class PlatformDashboardBloc extends Bloc<PlatformDashboardEvent, PlatformDashboardState> {
  final GetPlatformDashboardUseCase _getDashboard;

  PlatformDashboardBloc({required GetPlatformDashboardUseCase getDashboard})
      : _getDashboard = getDashboard,
        super(const PlatformDashboardInitial()) {
    on<PlatformDashboardStarted>(_onStarted, transformer: droppable());
    on<PlatformDashboardRefreshed>(_onRefreshed, transformer: droppable());
  }

  Future<void> _onStarted(PlatformDashboardStarted event, Emitter<PlatformDashboardState> emit) async {
    emit(const PlatformDashboardLoading());
    final result = await _getDashboard();
    result.fold(
      (f) => emit(PlatformDashboardError(f.message)),
      (data) => emit(PlatformDashboardLoaded(data)),
    );
  }

  Future<void> _onRefreshed(PlatformDashboardRefreshed event, Emitter<PlatformDashboardState> emit) async {
    emit(const PlatformDashboardLoading());
    final result = await _getDashboard();
    result.fold(
      (f) => emit(PlatformDashboardError(f.message)),
      (data) => emit(PlatformDashboardLoaded(data)),
    );
  }
}
