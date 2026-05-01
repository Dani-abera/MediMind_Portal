part of 'patient_detail_bloc.dart';

abstract class PatientDetailEvent extends Equatable {
  const PatientDetailEvent();
  @override
  List<Object?> get props => [];
}

class PatientDetailStarted extends PatientDetailEvent {
  final String id;
  const PatientDetailStarted(this.id);
  @override
  List<Object?> get props => [id];
}

class PatientDetailRefreshed extends PatientDetailEvent {
  const PatientDetailRefreshed();
}
