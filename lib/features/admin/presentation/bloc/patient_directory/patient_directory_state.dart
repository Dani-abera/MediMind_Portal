part of 'patient_directory_bloc.dart';
abstract class PatientDirState extends Equatable { const PatientDirState(); @override List<Object?> get props => []; }
class PatientDirInitial extends PatientDirState { const PatientDirInitial(); }
class PatientDirLoading extends PatientDirState { const PatientDirLoading(); }
class PatientDirLoaded extends PatientDirState {
  final List<PatientAtCenter> patients;
  final int page, pageSize, total;
  final String search;
  final DateTime? from, to;
  const PatientDirLoaded({required this.patients, required this.page, required this.pageSize, required this.total, required this.search, this.from, this.to});
  @override List<Object?> get props => [patients, page, pageSize, total, search, from, to];
}
class PatientDirError extends PatientDirState { final String message; const PatientDirError(this.message); @override List<Object?> get props => [message]; }
