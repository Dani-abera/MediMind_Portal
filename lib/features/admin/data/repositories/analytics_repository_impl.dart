import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/analytics_data.dart';
import '../../domain/entities/revenue_data.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../datasources/analytics_remote_datasource.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsRemoteDataSource _remote;
  final NetworkInfo _network;
  AnalyticsRepositoryImpl(this._remote, this._network);

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() fn) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try { return Right(await fn()); }
    on UnauthorizedException catch (e) { return Left(UnauthorizedFailure(e.message)); }
    on ForbiddenException catch (e) { return Left(ForbiddenFailure(e.message)); }
    on ServerException catch (e) { return Left(ServerFailure(e.message)); }
    on AppException catch (e) { return Left(UnknownFailure(e.message)); }
    catch (e) { return Left(UnknownFailure(e.toString())); }
  }

  @override
  Future<Either<Failure, AnalyticsSummary>> getAnalyticsSummary(
    String centerId, {
    required DateTime from,
    required DateTime to,
    bool comparePrevious = false,
  }) =>
      _guard(() => _remote.getAnalyticsSummary(centerId,
          from: from, to: to, comparePrevious: comparePrevious));

  @override
  Future<Either<Failure, DoctorAnalyticsDetail>> getDoctorAnalytics(
    String centerId,
    String doctorId, {
    required DateTime from,
    required DateTime to,
  }) =>
      _guard(() => _remote.getDoctorAnalytics(centerId, doctorId, from: from, to: to));

  @override
  Future<Either<Failure, RevenueSummary>> getRevenueSummary(
    String centerId, {
    required DateTime from,
    required DateTime to,
    required RevenueGroupBy groupBy,
    bool comparePrevious = false,
  }) =>
      _guard(() => _remote.getRevenueSummary(centerId,
          from: from, to: to, groupBy: groupBy, comparePrevious: comparePrevious));

  @override
  Future<Either<Failure, String>> exportAnalyticsCsv(String centerId, {
    required DateTime from,
    required DateTime to,
  }) =>
      _guard(() => _remote.exportAnalyticsCsv(centerId, from: from, to: to));

  @override
  Future<Either<Failure, String>> exportAnalyticsPdf(String centerId, {
    required DateTime from,
    required DateTime to,
  }) =>
      _guard(() => _remote.exportAnalyticsPdf(centerId, from: from, to: to));

  @override
  Future<Either<Failure, String>> exportRevenueCsv(String centerId, {
    required DateTime from,
    required DateTime to,
  }) =>
      _guard(() => _remote.exportRevenueCsv(centerId, from: from, to: to));
}
