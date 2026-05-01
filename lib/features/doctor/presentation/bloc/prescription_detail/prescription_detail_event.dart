part of 'prescription_detail_bloc.dart';

abstract class PrescriptionDetailEvent extends Equatable {
  const PrescriptionDetailEvent();
  @override
  List<Object?> get props => [];
}

class PrescriptionDetailStarted extends PrescriptionDetailEvent {
  final String id;
  const PrescriptionDetailStarted(this.id);
  @override
  List<Object?> get props => [id];
}

class PrescriptionRevoked extends PrescriptionDetailEvent {
  final String reason;
  const PrescriptionRevoked(this.reason);
  @override
  List<Object?> get props => [reason];
}

class PrescriptionMarkedDispensed extends PrescriptionDetailEvent {
  const PrescriptionMarkedDispensed();
}
