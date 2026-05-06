part of 'platform_audit_bloc.dart';

abstract class PlatformAuditState extends Equatable {
  const PlatformAuditState();
  @override
  List<Object?> get props => [];
}

class PlatformAuditInitial extends PlatformAuditState {
  const PlatformAuditInitial();
}

class PlatformAuditLoading extends PlatformAuditState {
  const PlatformAuditLoading();
}

class PlatformAuditLoaded extends PlatformAuditState {
  final List<PlatformAuditEntry> entries;
  final int total;
  final int page;
  const PlatformAuditLoaded({required this.entries, required this.total, this.page = 1});
  @override
  List<Object?> get props => [entries, total, page];
}

class PlatformAuditExporting extends PlatformAuditState {
  const PlatformAuditExporting();
}

class PlatformAuditExportDone extends PlatformAuditState {
  const PlatformAuditExportDone();
}

class PlatformAuditError extends PlatformAuditState {
  final String message;
  const PlatformAuditError(this.message);
  @override
  List<Object?> get props => [message];
}
