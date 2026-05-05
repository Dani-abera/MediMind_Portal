import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/audit_entry.dart';
import '../../domain/repositories/audit_log_repository.dart';
import '../datasources/audit_log_remote_datasource.dart';

class AuditLogRepositoryImpl implements AuditLogRepository {
  final AuditLogRemoteDataSource _remote;
  final NetworkInfo _network;
  AuditLogRepositoryImpl(this._remote, this._network);

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() fn) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try { return Right(await fn()); }
    on ForbiddenException catch (e) { return Left(ForbiddenFailure(e.message)); }
    on ServerException catch (e) { return Left(ServerFailure(e.message)); }
    on AppException catch (e) { return Left(UnknownFailure(e.message)); }
    catch (e) { return Left(UnknownFailure(e.toString())); }
  }

  @override
  Future<Either<Failure, ({List<AuditEntry> entries, int total})>> getAuditLog(
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
      _guard(() => _remote.getAuditLog(centerId,
          from: from, to: to, userId: userId, actions: actions,
          entityType: entityType, searchQuery: searchQuery,
          page: page, pageSize: pageSize));
}
