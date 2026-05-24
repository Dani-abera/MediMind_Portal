import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import '../../../domain/entities/analytics_data.dart';
import '../../../domain/entities/revenue_data.dart';
import '../../../domain/usecases/get_revenue_summary_usecase.dart';
import '../../../../../core/network/user_context.dart';
import '../../../../../core/utils/export_utils.dart';

part 'revenue_event.dart';
part 'revenue_state.dart';

class RevenueBloc extends Bloc<RevenueEvent, RevenueState> {
  final GetRevenueSummaryUseCase _getRevenue;

  String _centerId = '';
  DateRangeSelection _range = DateRangeSelection.preset(DateRangePreset.last30);
  RevenueGroupBy _groupBy = RevenueGroupBy.day;
  bool _comparePeriod = false;

  RevenueBloc({
    required GetRevenueSummaryUseCase getRevenue,
  })  : _getRevenue = getRevenue,
        super(const RevenueInitial()) {
    on<RevenueStarted>(_onStarted, transformer: droppable());
    on<RevenueDateRangeChanged>(_onDateRangeChanged, transformer: droppable());
    on<RevenueGroupByChanged>(_onGroupByChanged, transformer: droppable());
    on<RevenueComparePeriodToggled>(_onCompareToggled);
    on<RevenueExportRequested>(_onExportRequested, transformer: droppable());
    on<RevenueRefreshed>(_onRefreshed, transformer: droppable());
  }

  Future<void> _fetch(Emitter<RevenueState> emit) async {
    final result = await _getRevenue(_centerId,
        from: _range.from, to: _range.to, groupBy: _groupBy, comparePrevious: _comparePeriod);
    result.fold(
      (f) => emit(RevenueError(f.message)),
      (data) => emit(RevenueLoaded(data: data, range: _range, groupBy: _groupBy, comparePeriod: _comparePeriod)),
    );
  }

  Future<void> _onStarted(RevenueStarted event, Emitter<RevenueState> emit) async {
    _centerId = event.centerId.isNotEmpty ? event.centerId : (UserContext().centerId ?? '');
    emit(const RevenueLoading());
    await _fetch(emit);
  }

  Future<void> _onDateRangeChanged(RevenueDateRangeChanged event, Emitter<RevenueState> emit) async {
    _range = event.preset == DateRangePreset.custom && event.customFrom != null
        ? DateRangeSelection(preset: DateRangePreset.custom, from: event.customFrom!, to: event.customTo ?? DateTime.now())
        : DateRangeSelection.preset(event.preset);
    emit(const RevenueLoading());
    await _fetch(emit);
  }

  Future<void> _onGroupByChanged(RevenueGroupByChanged event, Emitter<RevenueState> emit) async {
    _groupBy = event.groupBy;
    emit(const RevenueLoading());
    await _fetch(emit);
  }

  void _onCompareToggled(RevenueComparePeriodToggled event, Emitter<RevenueState> emit) {
    _comparePeriod = event.enabled;
    add(const RevenueRefreshed());
  }

  Future<void> _onRefreshed(RevenueRefreshed event, Emitter<RevenueState> emit) async {
    emit(const RevenueLoading());
    await _fetch(emit);
  }

  Future<void> _onExportRequested(RevenueExportRequested event, Emitter<RevenueState> emit) async {
    if (state is! RevenueLoaded) return;
    final loaded = state as RevenueLoaded;
    emit(const RevenueExporting());

    final headers = ['Date', 'Appointment ID', 'Doctor', 'Patient', 'Amount (ETB)', 'Method', 'Status'];
    final rows = loaded.data.rows.map((r) => [
      r.date.toIso8601String(),
      r.appointmentId,
      r.doctorName,
      r.patientMasked,
      r.amount.toStringAsFixed(2),
      r.method,
      r.status,
    ]).toList();

    await ExportUtils.exportToCsv([headers, ...rows], 'revenue_${DateTime.now().millisecondsSinceEpoch}');

    emit(const RevenueExportDone());
    emit(RevenueLoaded(data: loaded.data, range: loaded.range, groupBy: loaded.groupBy, comparePeriod: loaded.comparePeriod));
  }
}
