import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/platform_audit_entry.dart';

abstract class PlatformAuditRepository {
  Future<Either<Failure, ({List<PlatformAuditEntry> entries, int total})>> getAuditLog({
    String? centerId,
    String? userId,
    DateTime? from,
    DateTime? to,
    int page = 1,
    int pageSize = 50,
  });
  Future<Either<Failure, void>> exportAuditLog({String? centerId});
}
