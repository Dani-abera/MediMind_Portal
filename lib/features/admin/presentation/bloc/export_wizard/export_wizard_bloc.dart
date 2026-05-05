import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/analytics_data.dart';
import '../../../domain/usecases/export_analytics_usecase.dart';

part 'export_wizard_event.dart';
part 'export_wizard_state.dart';

class ExportWizardBloc extends Bloc<ExportWizardEvent, ExportWizardState> {
  final ExportAnalyticsCsvUseCase _exportAnalyticsCsv;
  final ExportAnalyticsPdfUseCase _exportAnalyticsPdf;
  final ExportRevenueCsvUseCase _exportRevenueCsv;

  String _centerId = '';

  ExportWizardBloc({
    required ExportAnalyticsCsvUseCase exportAnalyticsCsv,
    required ExportAnalyticsPdfUseCase exportAnalyticsPdf,
    required ExportRevenueCsvUseCase exportRevenueCsv,
  })  : _exportAnalyticsCsv = exportAnalyticsCsv,
        _exportAnalyticsPdf = exportAnalyticsPdf,
        _exportRevenueCsv = exportRevenueCsv,
        super(const ExportWizardIdle()) {
    on<ExportWizardStarted>(_onStarted);
    on<ExportDataTypeSelected>(_onDataTypeSelected);
    on<ExportDateRangeSelected>(_onDateRangeSelected);
    on<ExportFormatSelected>(_onFormatSelected);
    on<ExportGenerateRequested>(_onGenerate);
    on<ExportWizardReset>(_onReset);
    on<ExportWizardStepBack>(_onStepBack);
  }

  void _onStarted(ExportWizardStarted event, Emitter<ExportWizardState> emit) {
    _centerId = event.centerId;
    emit(const ExportWizardStep1());
  }

  void _onDataTypeSelected(ExportDataTypeSelected event, Emitter<ExportWizardState> emit) {
    emit(ExportWizardStep2(
      dataType: event.dataType,
      range: DateRangeSelection.preset(DateRangePreset.last30),
    ));
  }

  void _onDateRangeSelected(ExportDateRangeSelected event, Emitter<ExportWizardState> emit) {
    if (state is! ExportWizardStep2) return;
    final s2 = state as ExportWizardStep2;
    final range = event.preset == DateRangePreset.custom && event.customFrom != null
        ? DateRangeSelection(preset: DateRangePreset.custom, from: event.customFrom!, to: event.customTo ?? DateTime.now())
        : DateRangeSelection.preset(event.preset);
    emit(ExportWizardStep3(dataType: s2.dataType, range: range, format: ExportFormat.csv));
  }

  void _onFormatSelected(ExportFormatSelected event, Emitter<ExportWizardState> emit) {
    if (state is! ExportWizardStep3) return;
    final s3 = state as ExportWizardStep3;
    emit(ExportWizardStep4(
      dataType: s3.dataType,
      range: s3.range,
      format: event.format,
      doctorFilter: event.doctorFilter,
      statusFilter: event.statusFilter,
    ));
  }

  Future<void> _onGenerate(ExportGenerateRequested event, Emitter<ExportWizardState> emit) async {
    if (state is! ExportWizardStep4) return;
    final s4 = state as ExportWizardStep4;
    emit(const ExportWizardExporting());

    final result = await switch ((s4.dataType, s4.format)) {
      (ExportDataType.revenue, _) =>
          _exportRevenueCsv(_centerId, from: s4.range.from, to: s4.range.to),
      (_, ExportFormat.pdf) =>
          _exportAnalyticsPdf(_centerId, from: s4.range.from, to: s4.range.to),
      _ =>
          _exportAnalyticsCsv(_centerId, from: s4.range.from, to: s4.range.to),
    };

    result.fold(
      (f) => emit(ExportWizardFailed(f.message)),
      (_) => emit(const ExportWizardDone()),
    );
  }

  void _onReset(ExportWizardReset event, Emitter<ExportWizardState> emit) {
    emit(const ExportWizardStep1());
  }

  void _onStepBack(ExportWizardStepBack event, Emitter<ExportWizardState> emit) {
    if (state is ExportWizardStep2) emit(const ExportWizardStep1());
    if (state is ExportWizardStep3) {
      final s = state as ExportWizardStep3;
      emit(ExportWizardStep2(dataType: s.dataType, range: s.range));
    }
    if (state is ExportWizardStep4) {
      final s = state as ExportWizardStep4;
      emit(ExportWizardStep3(dataType: s.dataType, range: s.range, format: s.format));
    }
  }
}
