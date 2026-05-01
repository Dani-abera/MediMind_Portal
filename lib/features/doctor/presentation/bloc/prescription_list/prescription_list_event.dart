part of 'prescription_list_bloc.dart';

abstract class PrescriptionListEvent extends Equatable {
  const PrescriptionListEvent();
  @override
  List<Object?> get props => [];
}

class PrescriptionListStarted extends PrescriptionListEvent {
  const PrescriptionListStarted();
}

class PrescriptionListFiltered extends PrescriptionListEvent {
  final String? status;
  final String? patientId;
  const PrescriptionListFiltered({this.status, this.patientId});
  @override
  List<Object?> get props => [status, patientId];
}

class PrescriptionListNextPage extends PrescriptionListEvent {
  const PrescriptionListNextPage();
}
