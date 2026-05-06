import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/platform_audit_entry.dart';
import '../repositories/platform_audit_repository.dart';

class GetPlatformAuditLogUseCase {
  final PlatformAuditRepository _repo;
  GetPlatformAuditLogUseCase(this._repo);

  Future<Either<Failure, ({List<PlatformAuditEntry> entries, int total})>> call({
    String? centerId,
    String? userId,
    DateTime? from,
    DateTime? to,
    int page = 1,
    int pageSize = 50,
  }) =>
      _repo.getAuditLog(
        centerId: centerId,
        userId: userId,
        from: from,
        to: to,
        page: page,
        pageSize: pageSize,
      );
}
