import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/queue_item.dart';
import '../../domain/repositories/admin_queue_repository.dart';
import '../datasources/admin_queue_remote_datasource.dart';

class AdminQueueRepositoryImpl implements AdminQueueRepository {
  final AdminQueueRemoteDataSource _remote;
  final NetworkInfo _network;
  AdminQueueRepositoryImpl(this._remote, this._network);

  Future<Either<Failure, void>> _guard(Future<void> Function() fn) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try { await fn(); return const Right(null); }
    on UnauthorizedException catch (e) { return Left(UnauthorizedFailure(e.message)); }
    on ForbiddenException catch (e) { return Left(ForbiddenFailure(e.message)); }
    on BadRequestException catch (e) { return Left(BadRequestFailure(e.message)); }
    on ValidationException catch (e) { return Left(ValidationFailure(e.message)); }
    on NetworkTimeoutException catch (e) { return Left(TimeoutFailure(e.message)); }
    on ServerException catch (e) { return Left(ServerFailure(e.message)); }
    on AppException catch (e) { return Left(UnknownFailure(e.message)); }
    catch (e) { return Left(UnknownFailure(e.toString())); }
  }

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

  @override Future<Either<Failure, List<QueueItem>>> getQueue(String centerId) =>
    _guardResult(() => _remote.getQueue(centerId));
  @override Future<Either<Failure, QueueItem>> callNext() =>
    _guardResult(() => _remote.callNext());
  @override Future<Either<Failure, void>> markArrived(String queueId) =>
    _guard(() => _remote.markArrived(queueId));
  @override Future<Either<Failure, void>> markComplete(String queueId) =>
    _guard(() => _remote.markComplete(queueId));
  @override Future<Either<Failure, void>> markNoShow(String queueId) =>
    _guard(() => _remote.markNoShow(queueId));
  @override Future<Either<Failure, void>> skip(String queueId) =>
    _guard(() => _remote.skip(queueId));
  @override Future<Either<Failure, QueueItem>> insertEmergency(String appointmentId) =>
    _guardResult(() => _remote.insertEmergency(appointmentId));
  @override Future<Either<Failure, QueueStats>> getQueueStats(String centerId) =>
    _guardResult(() => _remote.getQueueStats(centerId));
}
