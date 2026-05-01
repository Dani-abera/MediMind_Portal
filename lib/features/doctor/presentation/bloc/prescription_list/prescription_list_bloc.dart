import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import '../../../domain/usecases/get_prescriptions_usecase.dart';
import '../../../domain/entities/prescription.dart';

part 'prescription_list_event.dart';
part 'prescription_list_state.dart';

class PrescriptionListBloc
    extends Bloc<PrescriptionListEvent, PrescriptionListState> {
  final GetPrescriptionsUseCase _getPrescriptions;

  static const int _pageSize = 20;

  String? _currentStatus;
  String? _currentPatientId;

  PrescriptionListBloc({required GetPrescriptionsUseCase getPrescriptions})
      : _getPrescriptions = getPrescriptions,
        super(const PrescriptionListInitial()) {
    on<PrescriptionListStarted>(_onStarted, transformer: droppable());
    on<PrescriptionListFiltered>(_onFiltered, transformer: droppable());
    on<PrescriptionListNextPage>(_onNextPage, transformer: droppable());
  }

  Future<void> _onStarted(
    PrescriptionListStarted event,
    Emitter<PrescriptionListState> emit,
  ) async {
    _currentStatus = null;
    _currentPatientId = null;
    emit(const PrescriptionListLoading());
    final result = await _getPrescriptions(
      const GetPrescriptionsParams(page: 1, pageSize: _pageSize),
    );
    result.fold(
      (f) => emit(PrescriptionListError(f.message)),
      (prescriptions) => emit(PrescriptionListLoaded(
        prescriptions: prescriptions,
        hasMore: prescriptions.length == _pageSize,
        page: 1,
      )),
    );
  }

  Future<void> _onFiltered(
    PrescriptionListFiltered event,
    Emitter<PrescriptionListState> emit,
  ) async {
    _currentStatus = event.status;
    _currentPatientId = event.patientId;
    emit(const PrescriptionListLoading());
    final result = await _getPrescriptions(
      GetPrescriptionsParams(
        status: event.status,
        patientId: event.patientId,
        page: 1,
        pageSize: _pageSize,
      ),
    );
    result.fold(
      (f) => emit(PrescriptionListError(f.message)),
      (prescriptions) => emit(PrescriptionListLoaded(
        prescriptions: prescriptions,
        hasMore: prescriptions.length == _pageSize,
        page: 1,
      )),
    );
  }

  Future<void> _onNextPage(
    PrescriptionListNextPage event,
    Emitter<PrescriptionListState> emit,
  ) async {
    final current = state;
    if (current is! PrescriptionListLoaded || !current.hasMore) return;
    final nextPage = current.page + 1;
    final result = await _getPrescriptions(
      GetPrescriptionsParams(
        status: _currentStatus,
        patientId: _currentPatientId,
        page: nextPage,
        pageSize: _pageSize,
      ),
    );
    result.fold(
      (f) => emit(PrescriptionListError(f.message)),
      (prescriptions) => emit(PrescriptionListLoaded(
        prescriptions: [...current.prescriptions, ...prescriptions],
        hasMore: prescriptions.length == _pageSize,
        page: nextPage,
      )),
    );
  }
}
