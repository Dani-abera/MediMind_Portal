import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import '../../../domain/entities/admin_dashboard_data.dart';
import '../../../domain/usecases/get_admin_dashboard_usecase.dart';
import '../../../../../core/network/user_context.dart';

part 'admin_dashboard_event.dart';
part 'admin_dashboard_state.dart';

class AdminDashboardBloc extends Bloc<AdminDashboardEvent, AdminDashboardState> {
  final GetAdminDashboardUseCase _getDashboardData;
  Timer? _refreshTimer;

  AdminDashboardBloc({required GetAdminDashboardUseCase getDashboardData})
      : _getDashboardData = getDashboardData,
        super(const AdminDashboardInitial()) {
    on<AdminDashboardStarted>(_onStarted, transformer: droppable());
    on<AdminDashboardRefreshed>(_onRefreshed, transformer: droppable());
    on<AdminDashboardQueueUpdated>(_onQueueUpdated);
  }

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    return super.close();
  }

  Future<void> _onStarted(
    AdminDashboardStarted event,
    Emitter<AdminDashboardState> emit,
  ) async {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      add(const AdminDashboardRefreshed());
    });
    emit(const AdminDashboardLoading());
    final centerId = UserContext().centerId ?? '';
    final result = await _getDashboardData(centerId);
    result.fold(
      (f) => emit(AdminDashboardError(f.message)),
      (data) => emit(AdminDashboardLoaded(data, DateTime.now())),
    );
  }

  Future<void> _onRefreshed(
    AdminDashboardRefreshed event,
    Emitter<AdminDashboardState> emit,
  ) async {
    emit(const AdminDashboardLoading());
    final centerId = UserContext().centerId ?? '';
    final result = await _getDashboardData(centerId);
    result.fold(
      (f) => emit(AdminDashboardError(f.message)),
      (data) => emit(AdminDashboardLoaded(data, DateTime.now())),
    );
  }

  void _onQueueUpdated(
    AdminDashboardQueueUpdated event,
    Emitter<AdminDashboardState> emit,
  ) {
    if (state is AdminDashboardLoaded) {
      final current = (state as AdminDashboardLoaded);
      emit(AdminDashboardLoaded(
        current.data.copyWith(queueLength: event.queueLength),
        current.lastRefreshed,
      ));
    }
  }
}
