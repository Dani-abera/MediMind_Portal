import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import '../../../domain/entities/audit_entry.dart';
import '../../../domain/usecases/get_audit_log_usecase.dart';
import '../../../../../core/utils/export_utils.dart';

part 'audit_log_event.dart';
part 'audit_log_state.dart';

class AuditLogBloc extends Bloc<AuditLogEvent, AuditLogState> {
  final GetAuditLogUseCase _getAuditLog;

  String _centerId = '';
  AuditLogFilters _filters = const AuditLogFilters();
  int _page = 1;
  static const _pageSize = 50;

  AuditLogBloc({required GetAuditLogUseCase getAuditLog})
      : _getAuditLog = getAuditLog,
        super(const AuditLogInitial()) {
    on<AuditLogStarted>(_onStarted, transformer: droppable());
    on<AuditLogFiltered>(_onFiltered, transformer: droppable());
    on<AuditLogPageChanged>(_onPageChanged, transformer: droppable());
    on<AuditLogExportRequested>(_onExport, transformer: droppable());
    on<AuditLogRefreshed>(_onRefreshed, transformer: droppable());
  }

  Future<void> _fetch(Emitter<AuditLogState> emit) async {
    final result = await _getAuditLog(
      _centerId,
      from: _filters.from,
      to: _filters.to,
      userId: _filters.userId,
      actions: _filters.actions.isEmpty ? null : _filters.actions,
      entityType: _filters.entityType,
      searchQuery: _filters.searchQuery,
      page: _page,
      pageSize: _pageSize,
    );
    result.fold(
      (f) => emit(AuditLogError(f.message)),
      (r) => emit(AuditLogLoaded(entries: r.entries, total: r.total, filters: _filters, page: _page)),
    );
  }

  Future<void> _onStarted(AuditLogStarted event, Emitter<AuditLogState> emit) async {
    _centerId = event.centerId;
    emit(const AuditLogLoading());
    await _fetch(emit);
  }

  Future<void> _onFiltered(AuditLogFiltered event, Emitter<AuditLogState> emit) async {
    _filters = event.filters;
    _page = 1;
    emit(const AuditLogLoading());
    await _fetch(emit);
  }

  Future<void> _onPageChanged(AuditLogPageChanged event, Emitter<AuditLogState> emit) async {
    _page = event.page;
    emit(const AuditLogLoading());
    await _fetch(emit);
  }

  Future<void> _onExport(AuditLogExportRequested event, Emitter<AuditLogState> emit) async {
    if (state is! AuditLogLoaded) return;
    final loaded = state as AuditLogLoaded;
    emit(const AuditLogExporting());

    final headers = ['Timestamp', 'User', 'Role', 'Action', 'Entity Type', 'Entity ID', 'IP Address'];
    final rows = loaded.entries.map((e) => [
      e.timestamp.toIso8601String(),
      e.userName,
      e.userRole,
      e.action.label,
      e.entityType,
      e.entityId,
      e.ipAddress,
    ]).toList();

    await ExportUtils.exportToCsv([headers, ...rows], 'audit_log_${DateTime.now().millisecondsSinceEpoch}');
    emit(const AuditLogExportDone());
    // Return to loaded state after export
    if (state is AuditLogExportDone) {
      emit(AuditLogLoaded(entries: loaded.entries, total: loaded.total, filters: loaded.filters, page: loaded.page));
    }
  }

  Future<void> _onRefreshed(AuditLogRefreshed event, Emitter<AuditLogState> emit) async {
    emit(const AuditLogLoading());
    await _fetch(emit);
  }
}
