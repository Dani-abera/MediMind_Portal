part of 'patient_center_detail_bloc.dart';
abstract class PatientCenterDetailState extends Equatable { const PatientCenterDetailState(); @override List<Object?> get props => []; }
class PatientCenterDetailInitial extends PatientCenterDetailState { const PatientCenterDetailInitial(); }
class PatientCenterDetailLoading extends PatientCenterDetailState { const PatientCenterDetailLoading(); }
class PatientCenterDetailLoaded extends PatientCenterDetailState {
  final PatientCenterDetail detail;
  const PatientCenterDetailLoaded(this.detail);
  @override List<Object?> get props => [detail];
}
class PatientCenterDetailError extends PatientCenterDetailState { final String message; const PatientCenterDetailError(this.message); @override List<Object?> get props => [message]; }
