import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/platform_audit_repository.dart';

class ExportPlatformAuditUseCase {
  final PlatformAuditRepository _repo;
  ExportPlatformAuditUseCase(this._repo);

  Future<Either<Failure, void>> call({String? centerId}) =>
      _repo.exportAuditLog(centerId: centerId);
}
