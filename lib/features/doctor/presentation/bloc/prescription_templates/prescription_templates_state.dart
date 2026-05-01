part of 'prescription_templates_bloc.dart';

abstract class PrescriptionTemplatesState extends Equatable {
  const PrescriptionTemplatesState();
  @override
  List<Object?> get props => [];
}

class PrescriptionTemplatesInitial extends PrescriptionTemplatesState {
  const PrescriptionTemplatesInitial();
}

class PrescriptionTemplatesLoading extends PrescriptionTemplatesState {
  const PrescriptionTemplatesLoading();
}

class PrescriptionTemplatesLoaded extends PrescriptionTemplatesState {
  final List<PrescriptionTemplate> templates;
  const PrescriptionTemplatesLoaded(this.templates);
  @override
  List<Object?> get props => [templates];
}

class PrescriptionTemplatesError extends PrescriptionTemplatesState {
  final String message;
  const PrescriptionTemplatesError(this.message);
  @override
  List<Object?> get props => [message];
}

class PrescriptionTemplateDeleteInProgress extends PrescriptionTemplatesState {
  const PrescriptionTemplateDeleteInProgress();
}

class PrescriptionTemplateDeleteSuccess extends PrescriptionTemplatesState {
  const PrescriptionTemplateDeleteSuccess();
}
