part of 'export_wizard_bloc.dart';

abstract class ExportWizardEvent extends Equatable {
  const ExportWizardEvent();
  @override List<Object?> get props => [];
}

class ExportWizardStarted extends ExportWizardEvent {
  final String centerId;
  const ExportWizardStarted(this.centerId);
  @override List<Object?> get props => [centerId];
}

class ExportDataTypeSelected extends ExportWizardEvent {
  final ExportDataType dataType;
  const ExportDataTypeSelected(this.dataType);
  @override List<Object?> get props => [dataType];
}

class ExportDateRangeSelected extends ExportWizardEvent {
  final DateRangePreset preset;
  final DateTime? customFrom;
  final DateTime? customTo;
  const ExportDateRangeSelected(this.preset, {this.customFrom, this.customTo});
  @override List<Object?> get props => [preset, customFrom, customTo];
}

class ExportFormatSelected extends ExportWizardEvent {
  final ExportFormat format;
  final String? doctorFilter;
  final String? statusFilter;
  const ExportFormatSelected(this.format, {this.doctorFilter, this.statusFilter});
  @override List<Object?> get props => [format, doctorFilter, statusFilter];
}

class ExportGenerateRequested extends ExportWizardEvent {
  const ExportGenerateRequested();
}

class ExportWizardReset extends ExportWizardEvent {
  const ExportWizardReset();
}

class ExportWizardStepBack extends ExportWizardEvent {
  const ExportWizardStepBack();
}
