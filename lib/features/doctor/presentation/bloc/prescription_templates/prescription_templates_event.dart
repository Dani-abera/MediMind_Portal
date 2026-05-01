part of 'prescription_templates_bloc.dart';

abstract class PrescriptionTemplatesEvent extends Equatable {
  const PrescriptionTemplatesEvent();
  @override
  List<Object?> get props => [];
}

class PrescriptionTemplatesStarted extends PrescriptionTemplatesEvent {
  const PrescriptionTemplatesStarted();
}

class PrescriptionTemplateDeleted extends PrescriptionTemplatesEvent {
  final String id;
  const PrescriptionTemplateDeleted(this.id);
  @override
  List<Object?> get props => [id];
}
