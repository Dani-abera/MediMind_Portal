part of 'create_prescription_bloc.dart';

abstract class CreatePrescriptionState extends Equatable {
  const CreatePrescriptionState();
  @override
  List<Object?> get props => [];
}

class CreatePrescriptionInitial extends CreatePrescriptionState {
  const CreatePrescriptionInitial();
}

class CreatePrescriptionInProgress extends CreatePrescriptionState {
  const CreatePrescriptionInProgress();
}

class CreatePrescriptionSuccess extends CreatePrescriptionState {
  final Prescription prescription;
  const CreatePrescriptionSuccess(this.prescription);
  @override
  List<Object?> get props => [prescription];
}

class CreatePrescriptionFailure extends CreatePrescriptionState {
  final String message;
  const CreatePrescriptionFailure(this.message);
  @override
  List<Object?> get props => [message];
}
