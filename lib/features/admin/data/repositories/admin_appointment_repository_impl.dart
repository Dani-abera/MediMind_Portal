import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/admin_appointment.dart';
import '../../domain/repositories/admin_appointment_repository.dart';
import '../datasources/admin_appointment_remote_datasource.dart';

class AdminAppointmentRepositoryImpl implements AdminAppointmentRepository {
  final AdminAppointmentRemoteDataSource _remote;
  final NetworkInfo _network;
  AdminAppointmentRepositoryImpl(this._remote, this._network);

  Future<Either<Failure, void>> _guard(Future<void> Function() fn) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try { await fn(); return const Right(null); }
    on UnauthorizedException catch (e) { return Left(UnauthorizedFailure(e.message)); }
    on ForbiddenException catch (e) { return Left(ForbiddenFailure(e.message)); }
    on BadRequestException catch (e) { return Left(BadRequestFailure(e.message)); }
    on ValidationException catch (e) { return Left(ValidationFailure(e.message)); }
    on ConflictException catch (e) { return Left(ConflictFailure(e.message)); }
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
    on ConflictException catch (e) { return Left(ConflictFailure(e.message)); }
    on NetworkTimeoutException catch (e) { return Left(TimeoutFailure(e.message)); }
    on ServerException catch (e) { return Left(ServerFailure(e.message)); }
    on AppException catch (e) { return Left(UnknownFailure(e.message)); }
    catch (e) { return Left(UnknownFailure(e.toString())); }
  }

  @override
  Future<Either<Failure, List<AdminAppointment>>> getAppointments({
    String? status, String? doctorId, DateTime? from, DateTime? to,
    bool pendingOnly = false, String? search, int page = 1, int pageSize = 20}) =>
    _guardResult(() => _remote.getAppointments(
      status: status, doctorId: doctorId, from: from, to: to,
      pendingOnly: pendingOnly, search: search, page: page, pageSize: pageSize));

  @override
  Future<Either<Failure, AdminAppointment>> getAppointmentDetail(String id) =>
    _guardResult(() => _remote.getAppointmentDetail(id));

  @override
  Future<Either<Failure, void>> approveAppointment(String id) =>
    _guard(() => _remote.approveAppointment(id));

  @override
  Future<Either<Failure, void>> rejectAppointment(String id, {String? reason}) =>
    _guard(() => _remote.rejectAppointment(id, reason: reason));

  @override
  Future<Either<Failure, void>> cancelAppointment(String id, {String? reason}) =>
    _guard(() => _remote.cancelAppointment(id, reason: reason));

  @override
  Future<Either<Failure, void>> bulkApprove(List<String> ids) =>
    _guard(() => _remote.bulkApprove(ids));
}
