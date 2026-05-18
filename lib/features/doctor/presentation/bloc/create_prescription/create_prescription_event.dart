part of 'create_prescription_bloc.dart';

abstract class CreatePrescriptionEvent extends Equatable {
  const CreatePrescriptionEvent();
  @override
  List<Object?> get props => [];
}

class CreatePrescriptionSubmitted extends CreatePrescriptionEvent {
  final CreatePrescriptionParams params;
  const CreatePrescriptionSubmitted(this.params);
  @override
  List<Object?> get props => [params];
}

class CreatePrescriptionFromTemplate extends CreatePrescriptionEvent {
  final String templateId;
  final String? appointmentId;
  const CreatePrescriptionFromTemplate({
    required this.templateId,
    this.appointmentId,
  });
  @override
  List<Object?> get props => [templateId, appointmentId];
}
