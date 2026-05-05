import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/admin_dashboard_data.dart';
import '../../domain/repositories/admin_dashboard_repository.dart';
import '../datasources/admin_dashboard_remote_datasource.dart';

class AdminDashboardRepositoryImpl implements AdminDashboardRepository {
  final AdminDashboardRemoteDataSource _remote;
  final NetworkInfo _network;
  AdminDashboardRepositoryImpl(this._remote, this._network);

  Future<Either<Failure, T>> _guardResult<T>(Future<T> Function() fn) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try { return Right(await fn()); }
    on UnauthorizedException catch (e) { return Left(UnauthorizedFailure(e.message)); }
    on ForbiddenException catch (e) { return Left(ForbiddenFailure(e.message)); }
    on BadRequestException catch (e) { return Left(BadRequestFailure(e.message)); }
    on ValidationException catch (e) { return Left(ValidationFailure(e.message)); }
    on NetworkTimeoutException catch (e) { return Left(TimeoutFailure(e.message)); }
    on ServerException catch (e) { return Left(ServerFailure(e.message)); }
    on AppException catch (e) { return Left(UnknownFailure(e.message)); }
    catch (e) { return Left(UnknownFailure(e.toString())); }
  }

  @override Future<Either<Failure, AdminDashboardData>> getDashboardData(String centerId) =>
    _guardResult(() => _remote.getDashboardData(centerId));
}
