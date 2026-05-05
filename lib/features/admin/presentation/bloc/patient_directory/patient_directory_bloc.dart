import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import '../../../domain/entities/patient_at_center.dart';
import '../../../domain/usecases/get_patients_at_center_usecase.dart';

part 'patient_directory_event.dart';
part 'patient_directory_state.dart';

class PatientDirectoryBloc extends Bloc<PatientDirEvent, PatientDirState> {
  final GetPatientsAtCenterUseCase _getPatients;
  String _centerId = '';
  String _search = '';
  DateTime? _from;
  DateTime? _to;
  int _page = 1;
  static const int _pageSize = 20;

  PatientDirectoryBloc({required GetPatientsAtCenterUseCase getPatients})
      : _getPatients = getPatients,
        super(const PatientDirInitial()) {
    on<PatientDirStarted>(_onStarted, transformer: droppable());
    on<PatientDirSearched>(_onSearched, transformer: restartable());
    on<PatientDirFiltered>(_onFiltered, transformer: droppable());
    on<PatientDirPageChanged>(_onPageChanged, transformer: droppable());
  }

  Future<void> _fetch(Emitter<PatientDirState> emit) async {
    final result = await _getPatients(_centerId,
        search: _search.isEmpty ? null : _search,
        from: _from, to: _to, page: _page, pageSize: _pageSize);
    result.fold(
      (f) => emit(PatientDirError(f.message)),
      (patients) => emit(PatientDirLoaded(
        patients: patients, page: _page, pageSize: _pageSize,
        total: patients.length, search: _search, from: _from, to: _to,
      )),
    );
  }

  Future<void> _onStarted(PatientDirStarted event, Emitter<PatientDirState> emit) async {
    _centerId = event.centerId;
    emit(const PatientDirLoading());
    await _fetch(emit);
  }

  Future<void> _onSearched(PatientDirSearched event, Emitter<PatientDirState> emit) async {
    _search = event.query;
    _page = 1;
    emit(const PatientDirLoading());
    await _fetch(emit);
  }

  Future<void> _onFiltered(PatientDirFiltered event, Emitter<PatientDirState> emit) async {
    _from = event.from;
    _to = event.to;
    _page = 1;
    emit(const PatientDirLoading());
    await _fetch(emit);
  }

  Future<void> _onPageChanged(PatientDirPageChanged event, Emitter<PatientDirState> emit) async {
    _page = event.page;
    await _fetch(emit);
  }
}
