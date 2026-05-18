import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/doctor_at_center.dart';
import '../../domain/repositories/admin_doctor_repository.dart';
import '../datasources/admin_doctor_remote_datasource.dart';

class AdminDoctorRepositoryImpl implements AdminDoctorRepository {
  final AdminDoctorRemoteDataSource _remote;
  final NetworkInfo _network;
  AdminDoctorRepositoryImpl(this._remote, this._network);

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

  @override Future<Either<Failure, List<DoctorAtCenter>>> getDoctors(String centerId) =>
    _guardResult(() => _remote.getDoctors(centerId));
  @override Future<Either<Failure, void>> inviteDoctor(String centerId, InviteDoctorDto dto) =>
    _guard(() => _remote.inviteDoctor(centerId, dto));
  @override Future<Either<Failure, void>> addDoctor(String centerId, String licenseNumber) =>
    _guard(() => _remote.addDoctor(centerId, licenseNumber));
  @override Future<Either<Failure, void>> removeDoctor(String centerId, String doctorId) =>
    _guard(() => _remote.removeDoctor(centerId, doctorId));
  @override Future<Either<Failure, void>> configureSchedule(DoctorScheduleConfig config) =>
    _guard(() => _remote.configureSchedule(config));
  @override Future<Either<Failure, DoctorScheduleConfig?>> getDoctorSchedule(String doctorId, String centerId) =>
    _guardResult(() => _remote.getDoctorSchedule(doctorId, centerId));
  @override Future<Either<Failure, void>> deleteSchedule(String scheduleId) =>
    _guard(() => _remote.deleteSchedule(scheduleId));
  @override Future<Either<Failure, List<ScheduleException>>> getScheduleExceptions(String doctorId, String centerId) =>
    _guardResult(() => _remote.getScheduleExceptions(doctorId, centerId));
  @override Future<Either<Failure, void>> addScheduleException(String doctorId, String centerId, ScheduleException exception) =>
    _guard(() => _remote.addScheduleException(doctorId, centerId, exception));
  @override Future<Either<Failure, void>> deleteScheduleException(String doctorId, String centerId, DateTime date) =>
    _guard(() => _remote.deleteScheduleException(doctorId, centerId, date));
  @override Future<Either<Failure, void>> updateConsultationFee(String centerId, String doctorId, double fee) =>
    _guard(() => _remote.updateConsultationFee(centerId, doctorId, fee));
  @override Future<Either<Failure, List<PendingDoctorInvitation>>> getPendingInvitations(String centerId) =>
    _guardResult(() => _remote.getPendingInvitations(centerId));
}
