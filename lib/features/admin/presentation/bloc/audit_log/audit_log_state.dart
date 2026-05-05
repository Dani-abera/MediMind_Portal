part of 'audit_log_bloc.dart';

abstract class AuditLogState extends Equatable {
  const AuditLogState();
  @override List<Object?> get props => [];
}

class AuditLogInitial extends AuditLogState { const AuditLogInitial(); }
class AuditLogLoading extends AuditLogState { const AuditLogLoading(); }

class AuditLogLoaded extends AuditLogState {
  final List<AuditEntry> entries;
  final int total;
  final AuditLogFilters filters;
  final int page;
  final int pageSize;
  const AuditLogLoaded({
    required this.entries,
    required this.total,
    required this.filters,
    this.page = 1,
    this.pageSize = 50,
  });
  @override List<Object?> get props => [entries, total, filters, page, pageSize];
}

class AuditLogError extends AuditLogState {
  final String message;
  const AuditLogError(this.message);
  @override List<Object?> get props => [message];
}

class AuditLogExporting extends AuditLogState { const AuditLogExporting(); }
class AuditLogExportDone extends AuditLogState { const AuditLogExportDone(); }
