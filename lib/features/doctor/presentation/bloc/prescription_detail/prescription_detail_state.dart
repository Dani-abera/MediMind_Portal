part of 'prescription_detail_bloc.dart';

abstract class PrescriptionDetailState extends Equatable {
  const PrescriptionDetailState();
  @override
  List<Object?> get props => [];
}

class PrescriptionDetailInitial extends PrescriptionDetailState {
  const PrescriptionDetailInitial();
}

class PrescriptionDetailLoading extends PrescriptionDetailState {
  const PrescriptionDetailLoading();
}

class PrescriptionDetailLoaded extends PrescriptionDetailState {
  final Prescription prescription;
  final String? pdfUrl;
  const PrescriptionDetailLoaded({required this.prescription, this.pdfUrl});
  @override
  List<Object?> get props => [prescription, pdfUrl];
}

class PrescriptionDetailActionInProgress extends PrescriptionDetailState {
  const PrescriptionDetailActionInProgress();
}

class PrescriptionDetailActionSuccess extends PrescriptionDetailState {
  final Prescription prescription;
  const PrescriptionDetailActionSuccess(this.prescription);
  @override
  List<Object?> get props => [prescription];
}

class PrescriptionDetailError extends PrescriptionDetailState {
  final String message;
  const PrescriptionDetailError(this.message);
  @override
  List<Object?> get props => [message];
}
