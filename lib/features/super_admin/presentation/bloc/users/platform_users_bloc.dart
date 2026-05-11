import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import '../../../domain/entities/platform_user.dart';
import '../../../domain/usecases/get_platform_users_usecase.dart';
import '../../../domain/usecases/suspend_user_usecase.dart';
import '../../../domain/usecases/reactivate_user_usecase.dart';
import '../../../domain/usecases/force_logout_user_usecase.dart';
import '../../../domain/usecases/delete_user_usecase.dart';

part 'platform_users_event.dart';
part 'platform_users_state.dart';

class PlatformUsersBloc extends Bloc<PlatformUsersEvent, PlatformUsersState> {
  final GetPlatformUsersUseCase _getUsers;
  final SuspendUserUseCase _suspend;
  final ReactivateUserUseCase _reactivate;
  final ForceLogoutUserUseCase _forceLogout;
  final DeleteUserUseCase _delete;

  String? _userTypeFilter;
  String? _statusFilter;
  int _page = 1;
  static const _pageSize = 20;

  PlatformUsersBloc({
    required GetPlatformUsersUseCase getUsers,
    required SuspendUserUseCase suspend,
    required ReactivateUserUseCase reactivate,
    required ForceLogoutUserUseCase forceLogout,
    required DeleteUserUseCase delete,
  })  : _getUsers = getUsers,
        _suspend = suspend,
        _reactivate = reactivate,
        _forceLogout = forceLogout,
        _delete = delete,
        super(const PlatformUsersInitial()) {
    on<PlatformUsersStarted>(_onStarted, transformer: droppable());
    on<PlatformUsersFiltered>(_onFiltered, transformer: droppable());
    on<PlatformUsersPageChanged>(_onPageChanged, transformer: droppable());
    on<PlatformUsersRefreshed>(_onRefreshed, transformer: droppable());
    on<UserSuspendRequested>(_onSuspend, transformer: sequential());
    on<UserReactivateRequested>(_onReactivate, transformer: sequential());
    on<UserForceLogoutRequested>(_onForceLogout, transformer: sequential());
    on<UserDeleteRequested>(_onDelete, transformer: sequential());
  }

  Future<void> _fetch(Emitter<PlatformUsersState> emit) async {
    emit(const PlatformUsersLoading());
    final result = await _getUsers(userType: _userTypeFilter, status: _statusFilter, page: _page, pageSize: _pageSize);
    result.fold(
      (f) => emit(PlatformUsersError(f.message)),
      (r) => emit(PlatformUsersLoaded(users: r.users, total: r.total, page: _page)),
    );
  }

  Future<void> _onStarted(PlatformUsersStarted event, Emitter<PlatformUsersState> emit) async {
    _userTypeFilter = event.userTypeFilter;
    _statusFilter = event.statusFilter;
    _page = 1;
    await _fetch(emit);
  }

  Future<void> _onFiltered(PlatformUsersFiltered event, Emitter<PlatformUsersState> emit) async {
    _userTypeFilter = event.userTypeFilter;
    _statusFilter = event.statusFilter;
    _page = 1;
    await _fetch(emit);
  }

  Future<void> _onPageChanged(PlatformUsersPageChanged event, Emitter<PlatformUsersState> emit) async {
    _page = event.page;
    await _fetch(emit);
  }

  Future<void> _onRefreshed(PlatformUsersRefreshed event, Emitter<PlatformUsersState> emit) async {
    emit(const PlatformUsersLoading());
    await _fetch(emit);
  }

  Future<void> _onSuspend(UserSuspendRequested event, Emitter<PlatformUsersState> emit) async {
    final result = await _suspend(event.userId, reason: event.reason);
    result.fold(
      (f) => emit(PlatformUsersActionError(f.message)),
      (_) {
        emit(const PlatformUsersActionSuccess('User suspended'));
        add(const PlatformUsersRefreshed());
      },
    );
  }

  Future<void> _onReactivate(UserReactivateRequested event, Emitter<PlatformUsersState> emit) async {
    final result = await _reactivate(event.userId);
    result.fold(
      (f) => emit(PlatformUsersActionError(f.message)),
      (_) {
        emit(const PlatformUsersActionSuccess('User reactivated'));
        add(const PlatformUsersRefreshed());
      },
    );
  }

  Future<void> _onForceLogout(UserForceLogoutRequested event, Emitter<PlatformUsersState> emit) async {
    final result = await _forceLogout(event.userId);
    result.fold(
      (f) => emit(PlatformUsersActionError(f.message)),
      (_) => emit(const PlatformUsersActionSuccess('User force logged out')),
    );
  }

  Future<void> _onDelete(UserDeleteRequested event, Emitter<PlatformUsersState> emit) async {
    final result = await _delete(event.userId);
    result.fold(
      (f) => emit(PlatformUsersActionError(f.message)),
      (_) {
        emit(const PlatformUsersActionSuccess('User deleted'));
        add(const PlatformUsersRefreshed());
      },
    );
  }
}
