part of 'patient_detail_bloc.dart';

abstract class PatientDetailState extends Equatable {
  const PatientDetailState();
  @override
  List<Object?> get props => [];
}

class PatientDetailInitial extends PatientDetailState {
  const PatientDetailInitial();
}

class PatientDetailLoading extends PatientDetailState {
  const PatientDetailLoading();
}

class PatientDetailLoaded extends PatientDetailState {
  final Patient patient;
  final List<HealthRecord> records;
  final Prediction? latestPrediction;
  final Map<String, dynamic> medicalHistory;
  const PatientDetailLoaded({
    required this.patient,
    required this.records,
    this.latestPrediction,
    required this.medicalHistory,
  });
  @override
  List<Object?> get props => [patient, records, latestPrediction, medicalHistory];
}

class PatientDetailError extends PatientDetailState {
  final String message;
  const PatientDetailError(this.message);
  @override
  List<Object?> get props => [message];
}
