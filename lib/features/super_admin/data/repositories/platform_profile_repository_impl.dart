import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/super_admin_profile.dart';
import '../../domain/repositories/super_admin_profile_repository.dart';
import '../datasources/platform_profile_datasource.dart';
import '../models/super_admin_profile_model.dart';

class PlatformProfileRepositoryImpl implements SuperAdminProfileRepository {
  final PlatformProfileDatasource _remote;
  final NetworkInfo _network;
  PlatformProfileRepositoryImpl(this._remote, this._network);

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
  Future<Either<Failure, SuperAdminProfile>> getProfile() =>
      _guard(() => _remote.getProfile());

  @override
  Future<Either<Failure, SuperAdminProfile>> updateProfile(SuperAdminProfile profile) =>
      _guard(() => _remote.updateProfile(SuperAdminProfileModel(
            fullName: profile.fullName,
            dateOfBirth: profile.dateOfBirth,
            gender: profile.gender,
          )));
}
