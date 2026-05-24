import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/platform_notification.dart';
import '../../domain/repositories/platform_notifications_repository.dart';
import '../datasources/platform_notifications_datasource.dart';

class PlatformNotificationsRepositoryImpl implements PlatformNotificationsRepository {
  final PlatformNotificationsDatasource _remote;
  final NetworkInfo _network;
  PlatformNotificationsRepositoryImpl(this._remote, this._network);

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
  Future<Either<Failure, ({List<PlatformNotification> items, int total})>> getNotifications({
    int page = 1,
    int pageSize = 20,
  }) =>
      _guard(() => _remote.getNotifications(page: page, pageSize: pageSize));

  @override
  Future<Either<Failure, void>> markRead(String id) =>
      _guard(() => _remote.markRead(id));

  @override
  Future<Either<Failure, void>> markAllRead() =>
      _guard(() => _remote.markAllRead());
}
