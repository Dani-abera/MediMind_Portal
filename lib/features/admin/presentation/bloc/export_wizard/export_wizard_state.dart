part of 'export_wizard_bloc.dart';

enum ExportDataType {
  appointments,
  revenue,
  doctorPerformance,
  patientDemographics;

  String get label => switch (this) {
    ExportDataType.appointments        => 'Appointments',
    ExportDataType.revenue             => 'Revenue',
    ExportDataType.doctorPerformance   => 'Doctor Performance',
    ExportDataType.patientDemographics => 'Patient Demographics',
  };
}

abstract class ExportWizardState extends Equatable {
  const ExportWizardState();
  @override List<Object?> get props => [];
}

class ExportWizardIdle extends ExportWizardState { const ExportWizardIdle(); }

class ExportWizardStep1 extends ExportWizardState {
  final ExportDataType? selectedType;
  const ExportWizardStep1({this.selectedType});
  @override List<Object?> get props => [selectedType];
}

class ExportWizardStep2 extends ExportWizardState {
  final ExportDataType dataType;
  final DateRangeSelection range;
  const ExportWizardStep2({required this.dataType, required this.range});
  @override List<Object?> get props => [dataType, range];
}

class ExportWizardStep3 extends ExportWizardState {
  final ExportDataType dataType;
  final DateRangeSelection range;
  final ExportFormat format;
  final String? doctorFilter;
  final String? statusFilter;
  const ExportWizardStep3({
    required this.dataType,
    required this.range,
    required this.format,
    this.doctorFilter,
    this.statusFilter,
  });
  @override List<Object?> get props => [dataType, range, format, doctorFilter, statusFilter];
}

class ExportWizardStep4 extends ExportWizardState {
  final ExportDataType dataType;
  final DateRangeSelection range;
  final ExportFormat format;
  final String? doctorFilter;
  final String? statusFilter;
  const ExportWizardStep4({
    required this.dataType,
    required this.range,
    required this.format,
    this.doctorFilter,
    this.statusFilter,
  });
  @override List<Object?> get props => [dataType, range, format, doctorFilter, statusFilter];
}

class ExportWizardExporting extends ExportWizardState { const ExportWizardExporting(); }

class ExportWizardDone extends ExportWizardState { const ExportWizardDone(); }

class ExportWizardFailed extends ExportWizardState {
  final String message;
  const ExportWizardFailed(this.message);
  @override List<Object?> get props => [message];
}
