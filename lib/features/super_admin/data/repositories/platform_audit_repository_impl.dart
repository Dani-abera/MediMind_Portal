import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/platform_audit_entry.dart';
import '../../domain/repositories/platform_audit_repository.dart';
import '../datasources/platform_audit_datasource.dart';

class PlatformAuditRepositoryImpl implements PlatformAuditRepository {
  final PlatformAuditDatasource _remote;
  final NetworkInfo _network;
  PlatformAuditRepositoryImpl(this._remote, this._network);

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() fn) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      return Right(await fn());
    } on ForbiddenException catch (e) {
      return Left(ForbiddenFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AppException catch (e) {
      return Left(UnknownFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ({List<PlatformAuditEntry> entries, int total})>> getAuditLog({
    String? centerId,
    String? userId,
    DateTime? from,
    DateTime? to,
    int page = 1,
    int pageSize = 50,
  }) =>
      _guard(() => _remote.getAuditLog(
            centerId: centerId,
            userId: userId,
            from: from,
            to: to,
            page: page,
            pageSize: pageSize,
          ));

  @override
  Future<Either<Failure, void>> exportAuditLog({String? centerId}) =>
      _guard(() => _remote.exportAuditLog(centerId: centerId));
}
