import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/platform_center.dart';
import '../../domain/repositories/platform_centers_repository.dart';
import '../datasources/platform_centers_datasource.dart';

class PlatformCentersRepositoryImpl implements PlatformCentersRepository {
  final PlatformCentersDatasource _remote;
  final NetworkInfo _network;
  PlatformCentersRepositoryImpl(this._remote, this._network);

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
  Future<Either<Failure, ({List<PlatformCenter> centers, int total})>> getCenters({
    String? status,
    int page = 1,
    int pageSize = 20,
  }) =>
      _guard(() => _remote.getCenters(status: status, page: page, pageSize: pageSize));

  @override
  Future<Either<Failure, PlatformCenter>> getCenterDetail(String centerId) =>
      _guard(() => _remote.getCenterDetail(centerId));

  @override
  Future<Either<Failure, void>> approveCenter(String centerId, {required DateTime trialEndDate, String? notes}) =>
      _guard(() => _remote.approveCenter(centerId, trialEndDate: trialEndDate, notes: notes));

  @override
  Future<Either<Failure, void>> rejectCenter(String centerId, {required String reason}) =>
      _guard(() => _remote.rejectCenter(centerId, reason: reason));

  @override
  Future<Either<Failure, void>> suspendCenter(String centerId, {required String reason, DateTime? suspendUntil}) =>
      _guard(() => _remote.suspendCenter(centerId, reason: reason, suspendUntil: suspendUntil));

  @override
  Future<Either<Failure, void>> reactivateCenter(String centerId) =>
      _guard(() => _remote.reactivateCenter(centerId));

  @override
  Future<Either<Failure, void>> changeSubscription(String centerId, {required String plan, required DateTime startDate, required DateTime endDate, required String reason}) =>
      _guard(() => _remote.changeSubscription(centerId, plan: plan, startDate: startDate, endDate: endDate, reason: reason));

  @override
  Future<Either<Failure, PlatformCenter>> verifyPayment(String centerId) =>
      _guard(() => _remote.verifyPayment(centerId));
}
