part of 'patient_center_detail_bloc.dart';
abstract class PatientCenterDetailEvent extends Equatable { const PatientCenterDetailEvent(); @override List<Object?> get props => []; }
class PatientCenterDetailStarted extends PatientCenterDetailEvent {
  final String centerId, patientId;
  const PatientCenterDetailStarted({required this.centerId, required this.patientId});
  @override List<Object?> get props => [centerId, patientId];
}
