import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/platform_user.dart';
import '../../domain/repositories/platform_users_repository.dart';
import '../datasources/platform_users_datasource.dart';

class PlatformUsersRepositoryImpl implements PlatformUsersRepository {
  final PlatformUsersDatasource _remote;
  final NetworkInfo _network;
  PlatformUsersRepositoryImpl(this._remote, this._network);

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
  Future<Either<Failure, ({List<PlatformUser> users, int total})>> getUsers({
    String? userType,
    String? status,
    DateTime? from,
    DateTime? to,
    int page = 1,
    int pageSize = 20,
  }) =>
      _guard(() => _remote.getUsers(
            userType: userType,
            status: status,
            from: from,
            to: to,
            page: page,
            pageSize: pageSize,
          ));

  @override
  Future<Either<Failure, void>> suspendUser(String userId, {required String reason, DateTime? suspendUntil}) =>
      _guard(() => _remote.suspendUser(userId, reason: reason, suspendUntil: suspendUntil));

  @override
  Future<Either<Failure, void>> reactivateUser(String userId) =>
      _guard(() => _remote.reactivateUser(userId));

  @override
  Future<Either<Failure, void>> forceLogoutUser(String userId) =>
      _guard(() => _remote.forceLogoutUser(userId));

  @override
  Future<Either<Failure, void>> deleteUser(String userId) =>
      _guard(() => _remote.deleteUser(userId));
}
