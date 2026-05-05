import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/admin_staff.dart';
import '../../domain/repositories/admin_staff_repository.dart';
import '../datasources/admin_staff_remote_datasource.dart';

class AdminStaffRepositoryImpl implements AdminStaffRepository {
  final AdminStaffRemoteDataSource _remote;
  final NetworkInfo _network;
  AdminStaffRepositoryImpl(this._remote, this._network);

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

  @override Future<Either<Failure, List<AdminStaff>>> getAdmins(String centerId) =>
    _guardResult(() => _remote.getAdmins(centerId));
  @override Future<Either<Failure, void>> addAdmin({
    required String centerId, required String name,
    required String email, required String phone, required AdminRole role}) =>
    _guard(() => _remote.addAdmin(centerId: centerId, name: name, email: email, phone: phone, role: role));
  @override Future<Either<Failure, void>> deactivateAdmin(String centerId, String adminId) =>
    _guard(() => _remote.deactivateAdmin(centerId, adminId));
}
