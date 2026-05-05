import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import '../../../domain/entities/admin_staff.dart';
import '../../../domain/usecases/get_admins_usecase.dart';
import '../../../domain/usecases/add_admin_usecase.dart';
import '../../../domain/usecases/deactivate_admin_usecase.dart';
import '../../../../../core/network/user_context.dart';

part 'admin_staff_event.dart';
part 'admin_staff_state.dart';

class AdminStaffBloc extends Bloc<AdminStaffEvent, AdminStaffState> {
  final GetAdminsUseCase _getAdmins;
  final AddAdminUseCase _addAdmin;
  final DeactivateAdminUseCase _deactivate;
  String _centerId = '';

  AdminStaffBloc({
    required GetAdminsUseCase getAdmins,
    required AddAdminUseCase addAdmin,
    required DeactivateAdminUseCase deactivate,
  })  : _getAdmins = getAdmins,
        _addAdmin = addAdmin,
        _deactivate = deactivate,
        super(const AdminStaffInitial()) {
    on<AdminStaffStarted>(_onStarted, transformer: droppable());
    on<AdminStaffRefreshed>(_onRefreshed, transformer: droppable());
    on<AdminAddedToStaff>(_onAdminAdded, transformer: droppable());
    on<AdminDeactivatedFromStaff>(_onDeactivated, transformer: droppable());
  }

  Future<void> _fetch(Emitter<AdminStaffState> emit) async {
    final currentUserId = UserContext().userId ?? '';
    final result = await _getAdmins(_centerId);
    result.fold(
      (f) => emit(AdminStaffError(f.message)),
      (staff) => emit(AdminStaffLoaded(staff: staff, currentUserId: currentUserId)),
    );
  }

  Future<void> _onStarted(AdminStaffStarted event, Emitter<AdminStaffState> emit) async {
    _centerId = event.centerId;
    emit(const AdminStaffLoading());
    await _fetch(emit);
  }

  Future<void> _onRefreshed(AdminStaffRefreshed _, Emitter<AdminStaffState> emit) async {
    await _fetch(emit);
  }

  Future<void> _onAdminAdded(AdminAddedToStaff event, Emitter<AdminStaffState> emit) async {
    emit(const AdminStaffActionInProgress());
    final result = await _addAdmin(
        centerId: _centerId, name: event.name, email: event.email,
        phone: event.phone, role: event.role);
    await result.fold(
      (f) async => emit(AdminStaffError(f.message)),
      (_) async {
        emit(const AdminStaffActionSuccess('Invitation sent successfully'));
        await _fetch(emit);
      },
    );
  }

  Future<void> _onDeactivated(AdminDeactivatedFromStaff event, Emitter<AdminStaffState> emit) async {
    final currentUserId = state is AdminStaffLoaded
        ? (state as AdminStaffLoaded).currentUserId
        : (UserContext().userId ?? '');
    if (event.adminId == currentUserId) {
      emit(const AdminStaffError('Cannot deactivate your own account'));
      return;
    }
    emit(const AdminStaffActionInProgress());
    final result = await _deactivate(_centerId, event.adminId);
    await result.fold(
      (f) async => emit(AdminStaffError(f.message)),
      (_) async {
        emit(const AdminStaffActionSuccess('Admin deactivated'));
        await _fetch(emit);
      },
    );
  }
}
