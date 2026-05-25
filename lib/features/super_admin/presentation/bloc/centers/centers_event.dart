part of 'centers_bloc.dart';

abstract class CentersEvent extends Equatable {
  const CentersEvent();
  @override
  List<Object?> get props => [];
}

class CentersStarted extends CentersEvent {
  final String? statusFilter;
  const CentersStarted({this.statusFilter});
  @override
  List<Object?> get props => [statusFilter];
}

class CentersFiltered extends CentersEvent {
  final String? statusFilter;
  const CentersFiltered({this.statusFilter});
  @override
  List<Object?> get props => [statusFilter];
}

class CentersPageChanged extends CentersEvent {
  final int page;
  const CentersPageChanged(this.page);
  @override
  List<Object?> get props => [page];
}

class CentersRefreshed extends CentersEvent {
  const CentersRefreshed();
}

class CenterApproveRequested extends CentersEvent {
  final String centerId;
  final DateTime trialEndDate;
  final String? notes;
  const CenterApproveRequested(this.centerId, this.trialEndDate, {this.notes});
  @override
  List<Object?> get props => [centerId, trialEndDate, notes];
}

class CenterRejectRequested extends CentersEvent {
  final String centerId;
  final String reason;
  const CenterRejectRequested(this.centerId, this.reason);
  @override
  List<Object?> get props => [centerId, reason];
}

class CenterSuspendRequested extends CentersEvent {
  final String centerId;
  final String reason;
  final DateTime? suspendUntil;
  const CenterSuspendRequested(this.centerId, this.reason, {this.suspendUntil});
  @override
  List<Object?> get props => [centerId, reason, suspendUntil];
}

class CenterReactivateRequested extends CentersEvent {
  final String centerId;
  const CenterReactivateRequested(this.centerId);
  @override
  List<Object?> get props => [centerId];
}

class CenterVerifyPaymentRequested extends CentersEvent {
  final String centerId;
  const CenterVerifyPaymentRequested(this.centerId);
  @override
  List<Object?> get props => [centerId];
}
