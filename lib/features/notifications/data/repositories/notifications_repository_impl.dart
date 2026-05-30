import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/notification_item.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_datasource.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsDatasource _remote;
  final NetworkInfo _network;
  NotificationsRepositoryImpl(this._remote, this._network);

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
  Future<Either<Failure, List<NotificationItem>>> getHistory() =>
      _guard(() => _remote.getHistory());

  @override
  Future<Either<Failure, void>> markRead(String id) =>
      _guard(() => _remote.markRead(id));

  @override
  Future<Either<Failure, void>> markAllRead() =>
      _guard(() => _remote.markAllRead());
}
