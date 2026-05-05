import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import '../../../domain/entities/admin_appointment.dart';
import '../../../domain/usecases/get_all_appointments_usecase.dart';
import '../../../domain/usecases/cancel_appointment_admin_usecase.dart';

part 'all_appointments_event.dart';
part 'all_appointments_state.dart';

class AllAppointmentsBloc extends Bloc<AllAppointmentsEvent, AllAppointmentsState> {
  final GetAllAppointmentsUseCase _getAll;
  final CancelAppointmentAdminUseCase _cancel;

  AllApptsFilter _filters = const AllApptsFilter();
  int _page = 1;
  static const int _pageSize = 20;

  AllAppointmentsBloc({
    required GetAllAppointmentsUseCase getAll,
    required CancelAppointmentAdminUseCase cancel,
  })  : _getAll = getAll,
        _cancel = cancel,
        super(const AllApptsInitial()) {
    on<AllApptsStarted>(_onStarted, transformer: droppable());
    on<AllApptsFiltered>(_onFiltered, transformer: droppable());
    on<AllApptsPageChanged>(_onPageChanged, transformer: droppable());
    on<AllApptCancelled>(_onCancelled, transformer: droppable());
  }

  Future<void> _fetch(Emitter<AllAppointmentsState> emit) async {
    final result = await _getAll(
      status: _filters.status,
      doctorId: _filters.doctorId,
      from: _filters.from,
      to: _filters.to,
      page: _page,
      pageSize: _pageSize,
    );
    result.fold(
      (f) => emit(AllApptsError(f.message)),
      (items) => emit(AllApptsLoaded(
        appointments: items,
        page: _page,
        pageSize: _pageSize,
        total: items.length,
        filters: _filters,
      )),
    );
  }

  Future<void> _onStarted(AllApptsStarted _, Emitter<AllAppointmentsState> emit) async {
    emit(const AllApptsLoading());
    await _fetch(emit);
  }

  Future<void> _onFiltered(AllApptsFiltered event, Emitter<AllAppointmentsState> emit) async {
    _filters = AllApptsFilter(
      status: event.status,
      doctorId: event.doctorId,
      from: event.from,
      to: event.to,
      paymentStatus: event.paymentStatus,
      search: event.search,
      todayOnly: event.todayOnly,
    );
    _page = 1;
    emit(const AllApptsLoading());
    await _fetch(emit);
  }

  Future<void> _onPageChanged(AllApptsPageChanged event, Emitter<AllAppointmentsState> emit) async {
    _page = event.page;
    await _fetch(emit);
  }

  Future<void> _onCancelled(AllApptCancelled event, Emitter<AllAppointmentsState> emit) async {
    emit(const AllApptsActionInProgress());
    final result = await _cancel(event.id, reason: event.reason);
    result.fold(
      (f) => emit(AllApptsError(f.message)),
      (_) async => await _fetch(emit),
    );
  }
}
