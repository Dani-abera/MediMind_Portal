part of 'patient_list_bloc.dart';

abstract class PatientListState extends Equatable {
  const PatientListState();
  @override
  List<Object?> get props => [];
}

class PatientListInitial extends PatientListState {
  const PatientListInitial();
}

class PatientListLoading extends PatientListState {
  const PatientListLoading();
}

class PatientListLoaded extends PatientListState {
  final List<PatientSummary> patients;
  final bool hasMore;
  final int page;
  final String query;
  const PatientListLoaded({
    required this.patients,
    required this.hasMore,
    required this.page,
    required this.query,
  });
  @override
  List<Object?> get props => [patients, hasMore, page, query];
}

class PatientListError extends PatientListState {
  final String message;
  const PatientListError(this.message);
  @override
  List<Object?> get props => [message];
}
