part of 'platform_audit_bloc.dart';

abstract class PlatformAuditEvent extends Equatable {
  const PlatformAuditEvent();
  @override
  List<Object?> get props => [];
}

class PlatformAuditStarted extends PlatformAuditEvent {
  final String? centerId;
  const PlatformAuditStarted({this.centerId});
  @override
  List<Object?> get props => [centerId];
}

class PlatformAuditFiltered extends PlatformAuditEvent {
  final String? centerId;
  final String? userId;
  final DateTime? from;
  final DateTime? to;
  const PlatformAuditFiltered({this.centerId, this.userId, this.from, this.to});
  @override
  List<Object?> get props => [centerId, userId, from, to];
}

class PlatformAuditPageChanged extends PlatformAuditEvent {
  final int page;
  const PlatformAuditPageChanged(this.page);
  @override
  List<Object?> get props => [page];
}

class PlatformAuditRefreshed extends PlatformAuditEvent {
  const PlatformAuditRefreshed();
}

class PlatformAuditExportRequested extends PlatformAuditEvent {
  const PlatformAuditExportRequested();
}
