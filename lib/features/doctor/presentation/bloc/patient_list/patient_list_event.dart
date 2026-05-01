part of 'patient_list_bloc.dart';

abstract class PatientListEvent extends Equatable {
  const PatientListEvent();
  @override
  List<Object?> get props => [];
}

class PatientListStarted extends PatientListEvent {
  const PatientListStarted();
}

class PatientListSearched extends PatientListEvent {
  final String query;
  const PatientListSearched(this.query);
  @override
  List<Object?> get props => [query];
}

class PatientListNextPage extends PatientListEvent {
  const PatientListNextPage();
}
