import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import '../../../domain/entities/analytics_data.dart';
import '../../../domain/usecases/get_analytics_summary_usecase.dart';
import '../../../domain/usecases/export_analytics_usecase.dart';
import '../../../../../core/network/user_context.dart';
import '../../../../../core/utils/export_utils.dart';

part 'analytics_dashboard_event.dart';
part 'analytics_dashboard_state.dart';

class AnalyticsDashboardBloc extends Bloc<AnalyticsDashboardEvent, AnalyticsDashboardState> {
  final GetAnalyticsSummaryUseCase _getSummary;

  String _centerId = '';
  DateRangeSelection _range = DateRangeSelection.preset(DateRangePreset.last30);
  bool _comparePeriod = false;

  AnalyticsDashboardBloc({
    required GetAnalyticsSummaryUseCase getSummary,
  })  : _getSummary = getSummary,
        super(const AnalyticsDashboardInitial()) {
    on<AnalyticsDashboardStarted>(_onStarted, transformer: droppable());
    on<AnalyticsDateRangeChanged>(_onDateRangeChanged, transformer: droppable());
    on<AnalyticsComparePeriodToggled>(_onCompareToggled);
    on<AnalyticsExportRequested>(_onExportRequested, transformer: droppable());
    on<AnalyticsDashboardRefreshed>(_onRefreshed, transformer: droppable());
  }

  Future<void> _fetch(Emitter<AnalyticsDashboardState> emit) async {
    final result = await _getSummary(
      _centerId,
      from: _range.from,
      to: _range.to,
      comparePrevious: _comparePeriod,
    );
    result.fold(
      (f) => emit(AnalyticsDashboardError(f.message)),
      (data) => emit(AnalyticsDashboardLoaded(data: data, range: _range, comparePeriod: _comparePeriod)),
    );
  }

  Future<void> _onStarted(AnalyticsDashboardStarted event, Emitter<AnalyticsDashboardState> emit) async {
    _centerId = event.centerId.isNotEmpty ? event.centerId : (UserContext().centerId ?? '');
    _range = DateRangeSelection.preset(event.preset);
    emit(const AnalyticsDashboardLoading());
    await _fetch(emit);
  }

  Future<void> _onDateRangeChanged(AnalyticsDateRangeChanged event, Emitter<AnalyticsDashboardState> emit) async {
    _range = event.preset == DateRangePreset.custom && event.customFrom != null
        ? DateRangeSelection(preset: DateRangePreset.custom, from: event.customFrom!, to: event.customTo ?? DateTime.now())
        : DateRangeSelection.preset(event.preset);
    emit(const AnalyticsDashboardLoading());
    await _fetch(emit);
  }

  void _onCompareToggled(AnalyticsComparePeriodToggled event, Emitter<AnalyticsDashboardState> emit) {
    _comparePeriod = event.enabled;
    add(const AnalyticsDashboardRefreshed());
  }

  Future<void> _onRefreshed(AnalyticsDashboardRefreshed event, Emitter<AnalyticsDashboardState> emit) async {
    if (state is AnalyticsDashboardLoaded) {
      emit(const AnalyticsDashboardLoading());
    }
    await _fetch(emit);
  }

  Future<void> _onExportRequested(AnalyticsExportRequested event, Emitter<AnalyticsDashboardState> emit) async {
    if (state is! AnalyticsDashboardLoaded) return;
    final loaded = state as AnalyticsDashboardLoaded;
    emit(const AnalyticsExporting());

    final filename = 'analytics_${DateTime.now().millisecondsSinceEpoch}';
    final headers = ['Doctor', 'No-Show Rate (%)', 'Utilization (%)', 'Revenue (ETB)', 'Avg Wait (min)'];
    final rows = loaded.data.doctorStats.map((d) => [
      d.doctorName,
      d.noShowRate.toStringAsFixed(1),
      d.utilizationPercent.toStringAsFixed(1),
      d.revenueEtb.toStringAsFixed(2),
      d.avgWaitMinutes.toStringAsFixed(1),
    ]).toList();

    if (event.format == ExportFormat.pdf) {
      await ExportUtils.exportToPdf(
        'Analytics Report – ${loaded.range.label}',
        rows,
        filename,
        headers: headers,
      );
    } else {
      await ExportUtils.exportToCsv([headers, ...rows], filename);
    }

    emit(const AnalyticsExportDone());
    emit(AnalyticsDashboardLoaded(data: loaded.data, range: loaded.range, comparePeriod: loaded.comparePeriod));
  }
}
