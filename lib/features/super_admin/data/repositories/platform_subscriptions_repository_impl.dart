import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/platform_subscription.dart';
import '../../domain/repositories/platform_subscriptions_repository.dart';
import '../datasources/platform_subscriptions_datasource.dart';

class PlatformSubscriptionsRepositoryImpl implements PlatformSubscriptionsRepository {
  final PlatformSubscriptionsDatasource _remote;
  final NetworkInfo _network;
  PlatformSubscriptionsRepositoryImpl(this._remote, this._network);

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
  Future<Either<Failure, ({List<PlatformSubscription> subscriptions, int total})>> getSubscriptions({
    String? plan,
    String? status,
    int page = 1,
    int pageSize = 20,
  }) =>
      _guard(() => _remote.getSubscriptions(plan: plan, status: status, page: page, pageSize: pageSize));

  @override
  Future<Either<Failure, void>> changePlan(String centerId, {required String plan, required DateTime startDate, required DateTime endDate, required String reason}) =>
      _guard(() => _remote.changePlan(centerId, plan: plan, startDate: startDate, endDate: endDate, reason: reason));
}
