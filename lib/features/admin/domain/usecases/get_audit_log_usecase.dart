import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/audit_entry.dart';
import '../repositories/audit_log_repository.dart';

class GetAuditLogUseCase {
  final AuditLogRepository _repo;
  GetAuditLogUseCase(this._repo);

  Future<Either<Failure, ({List<AuditEntry> entries, int total})>> call(
    String centerId, {
    DateTime? from,
    DateTime? to,
    String? userId,
    List<AuditAction>? actions,
    String? entityType,
    String? searchQuery,
    int page = 1,
    int pageSize = 50,
  }) =>
      _repo.getAuditLog(centerId,
          from: from, to: to, userId: userId, actions: actions,
          entityType: entityType, searchQuery: searchQuery,
          page: page, pageSize: pageSize);
}
