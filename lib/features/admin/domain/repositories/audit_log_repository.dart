import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/audit_entry.dart';

abstract class AuditLogRepository {
  Future<Either<Failure, ({List<AuditEntry> entries, int total})>> getAuditLog(
    String centerId, {
    DateTime? from,
    DateTime? to,
    String? userId,
    List<AuditAction>? actions,
    String? entityType,
    String? searchQuery,
    int page,
    int pageSize,
  });
}
