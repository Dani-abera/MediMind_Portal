import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import '../../../domain/usecases/get_appointments_usecase.dart';
import '../../../domain/entities/appointment.dart';

part 'appointment_list_event.dart';
part 'appointment_list_state.dart';

class AppointmentListBloc
    extends Bloc<AppointmentListEvent, AppointmentListState> {
  final GetAppointmentsUseCase _getAppointments;

  static const int _pageSize = 20;

  String? _currentStatus;
  DateTime? _currentFrom;
  DateTime? _currentTo;

  AppointmentListBloc({required GetAppointmentsUseCase getAppointments})
      : _getAppointments = getAppointments,
        super(const AppointmentListInitial()) {
    on<AppointmentListStarted>(_onStarted, transformer: droppable());
    on<AppointmentListFiltered>(_onFiltered, transformer: droppable());
    on<AppointmentListNextPage>(_onNextPage, transformer: droppable());
  }

  Future<void> _onStarted(
    AppointmentListStarted event,
    Emitter<AppointmentListState> emit,
  ) async {
    _currentStatus = null;
    _currentFrom = null;
    _currentTo = null;
    emit(const AppointmentListLoading());
    final result = await _getAppointments(
      GetAppointmentsParams(page: 1, pageSize: _pageSize),
    );
    result.fold(
      (f) => emit(AppointmentListError(f.message)),
      (appointments) => emit(AppointmentListLoaded(
        appointments: appointments,
        hasMore: appointments.length == _pageSize,
        page: 1,
      )),
    );
  }

  Future<void> _onFiltered(
    AppointmentListFiltered event,
    Emitter<AppointmentListState> emit,
  ) async {
    _currentStatus = event.status;
    _currentFrom = event.from;
    _currentTo = event.to;
    emit(const AppointmentListLoading());
    final result = await _getAppointments(
      GetAppointmentsParams(
        status: event.status,
        from: event.from,
        to: event.to,
        page: 1,
        pageSize: _pageSize,
      ),
    );
    result.fold(
      (f) => emit(AppointmentListError(f.message)),
      (appointments) => emit(AppointmentListLoaded(
        appointments: appointments,
        hasMore: appointments.length == _pageSize,
        page: 1,
      )),
    );
  }

  Future<void> _onNextPage(
    AppointmentListNextPage event,
    Emitter<AppointmentListState> emit,
  ) async {
    final current = state;
    if (current is! AppointmentListLoaded || !current.hasMore) return;
    final nextPage = current.page + 1;
    final result = await _getAppointments(
      GetAppointmentsParams(
        status: _currentStatus,
        from: _currentFrom,
        to: _currentTo,
        page: nextPage,
        pageSize: _pageSize,
      ),
    );
    result.fold(
      (f) => emit(AppointmentListError(f.message)),
      (appointments) => emit(AppointmentListLoaded(
        appointments: [...current.appointments, ...appointments],
        hasMore: appointments.length == _pageSize,
        page: nextPage,
      )),
    );
  }
}
