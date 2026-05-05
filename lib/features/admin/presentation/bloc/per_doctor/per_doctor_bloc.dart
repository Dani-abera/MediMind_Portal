import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import '../../../domain/entities/analytics_data.dart';
import '../../../domain/usecases/get_doctor_analytics_usecase.dart';

part 'per_doctor_event.dart';
part 'per_doctor_state.dart';

class PerDoctorBloc extends Bloc<PerDoctorEvent, PerDoctorState> {
  final GetDoctorAnalyticsUseCase _getDoctorAnalytics;

  String _centerId = '';
  String _doctorId = '';
  DateRangeSelection _range = DateRangeSelection.preset(DateRangePreset.last30);
  final List<String> _compareIds = [];

  PerDoctorBloc({required GetDoctorAnalyticsUseCase getDoctorAnalytics})
      : _getDoctorAnalytics = getDoctorAnalytics,
        super(const PerDoctorInitial()) {
    on<PerDoctorStarted>(_onStarted, transformer: droppable());
    on<PerDoctorSelected>(_onSelected, transformer: droppable());
    on<PerDoctorDateRangeChanged>(_onDateRangeChanged, transformer: droppable());
    on<PerDoctorCompareAdded>(_onCompareAdded, transformer: droppable());
    on<PerDoctorCompareRemoved>(_onCompareRemoved, transformer: droppable());
  }

  Future<void> _fetchMain(Emitter<PerDoctorState> emit) async {
    if (_doctorId.isEmpty) return;
    final result = await _getDoctorAnalytics(_centerId, _doctorId, from: _range.from, to: _range.to);
    await result.fold(
      (f) async => emit(PerDoctorError(f.message)),
      (detail) async {
        final comparisons = await _fetchComparisons();
        emit(PerDoctorLoaded(detail: detail, range: _range, comparisons: comparisons));
      },
    );
  }

  Future<List<DoctorAnalyticsDetail>> _fetchComparisons() async {
    final results = await Future.wait(
      _compareIds.map((id) => _getDoctorAnalytics(_centerId, id, from: _range.from, to: _range.to)),
    );
    return results.whereType<dynamic>().fold<List<DoctorAnalyticsDetail>>([], (acc, r) {
      r.fold((f) => null, (d) => acc.add(d as DoctorAnalyticsDetail));
      return acc;
    });
  }

  Future<void> _onStarted(PerDoctorStarted event, Emitter<PerDoctorState> emit) async {
    _centerId = event.centerId;
    _doctorId = event.doctorId;
    emit(const PerDoctorLoading());
    await _fetchMain(emit);
  }

  Future<void> _onSelected(PerDoctorSelected event, Emitter<PerDoctorState> emit) async {
    _doctorId = event.doctorId;
    _compareIds.clear();
    emit(const PerDoctorLoading());
    await _fetchMain(emit);
  }

  Future<void> _onDateRangeChanged(PerDoctorDateRangeChanged event, Emitter<PerDoctorState> emit) async {
    _range = event.preset == DateRangePreset.custom && event.customFrom != null
        ? DateRangeSelection(preset: DateRangePreset.custom, from: event.customFrom!, to: event.customTo ?? DateTime.now())
        : DateRangeSelection.preset(event.preset);
    emit(const PerDoctorLoading());
    await _fetchMain(emit);
  }

  Future<void> _onCompareAdded(PerDoctorCompareAdded event, Emitter<PerDoctorState> emit) async {
    if (!_compareIds.contains(event.doctorId)) _compareIds.add(event.doctorId);
    emit(const PerDoctorLoading());
    await _fetchMain(emit);
  }

  Future<void> _onCompareRemoved(PerDoctorCompareRemoved event, Emitter<PerDoctorState> emit) async {
    _compareIds.remove(event.doctorId);
    emit(const PerDoctorLoading());
    await _fetchMain(emit);
  }
}
