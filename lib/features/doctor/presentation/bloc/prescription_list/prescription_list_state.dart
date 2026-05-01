part of 'prescription_list_bloc.dart';

abstract class PrescriptionListState extends Equatable {
  const PrescriptionListState();
  @override
  List<Object?> get props => [];
}

class PrescriptionListInitial extends PrescriptionListState {
  const PrescriptionListInitial();
}

class PrescriptionListLoading extends PrescriptionListState {
  const PrescriptionListLoading();
}

class PrescriptionListLoaded extends PrescriptionListState {
  final List<Prescription> prescriptions;
  final bool hasMore;
  final int page;
  const PrescriptionListLoaded({
    required this.prescriptions,
    required this.hasMore,
    required this.page,
  });
  @override
  List<Object?> get props => [prescriptions, hasMore, page];
}

class PrescriptionListError extends PrescriptionListState {
  final String message;
  const PrescriptionListError(this.message);
  @override
  List<Object?> get props => [message];
}
