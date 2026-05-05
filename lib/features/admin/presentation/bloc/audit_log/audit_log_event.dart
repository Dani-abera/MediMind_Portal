part of 'audit_log_bloc.dart';

abstract class AuditLogEvent extends Equatable {
  const AuditLogEvent();
  @override List<Object?> get props => [];
}

class AuditLogStarted extends AuditLogEvent {
  final String centerId;
  const AuditLogStarted(this.centerId);
  @override List<Object?> get props => [centerId];
}

class AuditLogFiltered extends AuditLogEvent {
  final AuditLogFilters filters;
  const AuditLogFiltered(this.filters);
  @override List<Object?> get props => [filters];
}

class AuditLogPageChanged extends AuditLogEvent {
  final int page;
  const AuditLogPageChanged(this.page);
  @override List<Object?> get props => [page];
}

class AuditLogExportRequested extends AuditLogEvent {
  const AuditLogExportRequested();
}

class AuditLogRefreshed extends AuditLogEvent {
  const AuditLogRefreshed();
}
