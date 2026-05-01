import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import '../../../domain/usecases/get_patients_usecase.dart';
import '../../../domain/entities/patient_summary.dart';

part 'patient_list_event.dart';
part 'patient_list_state.dart';

class PatientListBloc extends Bloc<PatientListEvent, PatientListState> {
  final GetPatientsUseCase _getPatients;

  static const int _pageSize = 20;

  String _currentQuery = '';

  PatientListBloc({required GetPatientsUseCase getPatients})
      : _getPatients = getPatients,
        super(const PatientListInitial()) {
    on<PatientListStarted>(_onStarted, transformer: droppable());
    on<PatientListSearched>(_onSearched, transformer: restartable());
    on<PatientListNextPage>(_onNextPage, transformer: droppable());
  }

  Future<void> _onStarted(
    PatientListStarted event,
    Emitter<PatientListState> emit,
  ) async {
    _currentQuery = '';
    emit(const PatientListLoading());
    final result = await _getPatients(
      const GetPatientsParams(page: 1, pageSize: _pageSize),
    );
    result.fold(
      (f) => emit(PatientListError(f.message)),
      (patients) => emit(PatientListLoaded(
        patients: patients,
        hasMore: patients.length == _pageSize,
        page: 1,
        query: '',
      )),
    );
  }

  Future<void> _onSearched(
    PatientListSearched event,
    Emitter<PatientListState> emit,
  ) async {
    _currentQuery = event.query;
    emit(const PatientListLoading());
    final result = await _getPatients(
      GetPatientsParams(
        search: event.query.isEmpty ? null : event.query,
        page: 1,
        pageSize: _pageSize,
      ),
    );
    result.fold(
      (f) => emit(PatientListError(f.message)),
      (patients) => emit(PatientListLoaded(
        patients: patients,
        hasMore: patients.length == _pageSize,
        page: 1,
        query: event.query,
      )),
    );
  }

  Future<void> _onNextPage(
    PatientListNextPage event,
    Emitter<PatientListState> emit,
  ) async {
    final current = state;
    if (current is! PatientListLoaded || !current.hasMore) return;
    final nextPage = current.page + 1;
    final result = await _getPatients(
      GetPatientsParams(
        search: _currentQuery.isEmpty ? null : _currentQuery,
        page: nextPage,
        pageSize: _pageSize,
      ),
    );
    result.fold(
      (f) => emit(PatientListError(f.message)),
      (patients) => emit(PatientListLoaded(
        patients: [...current.patients, ...patients],
        hasMore: patients.length == _pageSize,
        page: nextPage,
        query: _currentQuery,
      )),
    );
  }
}
