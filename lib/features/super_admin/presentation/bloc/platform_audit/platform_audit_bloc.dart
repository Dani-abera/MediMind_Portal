import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import '../../../domain/entities/platform_audit_entry.dart';
import '../../../domain/usecases/get_platform_audit_log_usecase.dart';
import '../../../domain/usecases/export_platform_audit_usecase.dart';

part 'platform_audit_event.dart';
part 'platform_audit_state.dart';

class PlatformAuditBloc extends Bloc<PlatformAuditEvent, PlatformAuditState> {
  final GetPlatformAuditLogUseCase _getAuditLog;
  final ExportPlatformAuditUseCase _exportAuditLog;

  String? _centerIdFilter;
  String? _userIdFilter;
  DateTime? _from;
  DateTime? _to;
  int _page = 1;
  static const _pageSize = 50;

  PlatformAuditBloc({
    required GetPlatformAuditLogUseCase getAuditLog,
    required ExportPlatformAuditUseCase exportAuditLog,
  })  : _getAuditLog = getAuditLog,
        _exportAuditLog = exportAuditLog,
        super(const PlatformAuditInitial()) {
    on<PlatformAuditStarted>(_onStarted, transformer: droppable());
    on<PlatformAuditFiltered>(_onFiltered, transformer: droppable());
    on<PlatformAuditPageChanged>(_onPageChanged, transformer: droppable());
    on<PlatformAuditRefreshed>(_onRefreshed, transformer: droppable());
    on<PlatformAuditExportRequested>(_onExport, transformer: droppable());
  }

  Future<void> _fetch(Emitter<PlatformAuditState> emit) async {
    emit(const PlatformAuditLoading());
    final result = await _getAuditLog(
      centerId: _centerIdFilter,
      userId: _userIdFilter,
      from: _from,
      to: _to,
      page: _page,
      pageSize: _pageSize,
    );
    result.fold(
      (f) => emit(PlatformAuditError(f.message)),
      (r) => emit(PlatformAuditLoaded(entries: r.entries, total: r.total, page: _page)),
    );
  }

  Future<void> _onStarted(PlatformAuditStarted event, Emitter<PlatformAuditState> emit) async {
    _centerIdFilter = event.centerId;
    _page = 1;
    await _fetch(emit);
  }

  Future<void> _onFiltered(PlatformAuditFiltered event, Emitter<PlatformAuditState> emit) async {
    _centerIdFilter = event.centerId;
    _userIdFilter = event.userId;
    _from = event.from;
    _to = event.to;
    _page = 1;
    await _fetch(emit);
  }

  Future<void> _onPageChanged(PlatformAuditPageChanged event, Emitter<PlatformAuditState> emit) async {
    _page = event.page;
    await _fetch(emit);
  }

  Future<void> _onRefreshed(PlatformAuditRefreshed event, Emitter<PlatformAuditState> emit) async {
    await _fetch(emit);
  }

  Future<void> _onExport(PlatformAuditExportRequested event, Emitter<PlatformAuditState> emit) async {
    emit(const PlatformAuditExporting());
    final result = await _exportAuditLog(centerId: _centerIdFilter);
    result.fold(
      (f) => emit(PlatformAuditError(f.message)),
      (_) => emit(const PlatformAuditExportDone()),
    );
  }
}
