import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/platform_dashboard_data.dart';
import '../../domain/entities/platform_analytics.dart';
import '../../domain/repositories/platform_analytics_repository.dart';
import '../datasources/platform_analytics_datasource.dart';

class PlatformAnalyticsRepositoryImpl implements PlatformAnalyticsRepository {
  final PlatformAnalyticsDatasource _remote;
  final NetworkInfo _network;
  PlatformAnalyticsRepositoryImpl(this._remote, this._network);

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
  Future<Either<Failure, PlatformDashboardData>> getDashboardData() =>
      _guard(() => _remote.getDashboardData());

  @override
  Future<Either<Failure, PlatformAnalytics>> getAnalytics({String period = 'last30'}) =>
      _guard(() => _remote.getAnalytics(period: period));
}
