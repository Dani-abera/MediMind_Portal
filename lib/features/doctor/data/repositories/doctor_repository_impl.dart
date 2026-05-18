import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/center_affiliation.dart';
import '../../domain/entities/doctor_profile.dart';
import '../../domain/entities/doctor_schedule.dart';
import '../../domain/entities/queue_entry.dart';
import '../../domain/repositories/doctor_repository.dart';
import '../datasources/doctor_remote_datasource.dart';

class DoctorRepositoryImpl implements DoctorRepository {
  final DoctorRemoteDataSource _remote;
  final NetworkInfo _network;

  DoctorRepositoryImpl(this._remote, this._network);

  Future<Either<Failure, T>> _guardResult<T>(Future<T> Function() fn) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      return Right(await fn());
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on ForbiddenException catch (e) {
      return Left(ForbiddenFailure(e.message));
    } on BadRequestException catch (e) {
      return Left(BadRequestFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ConflictException catch (e) {
      return Left(ConflictFailure(e.message));
    } on NetworkTimeoutException catch (e) {
      return Left(TimeoutFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AppException catch (e) {
      return Left(UnknownFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DoctorProfile>> getProfile() =>
      _guardResult(() => _remote.getProfile());

  @override
  Future<Either<Failure, DoctorProfile>> updateProfile(
          Map<String, dynamic> data) =>
      _guardResult(() => _remote.updateProfile(data));

  @override
  Future<Either<Failure, List<CenterAffiliation>>> getCenters() =>
      _guardResult(() => _remote.getCenters());

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getTodayAppointments() =>
      _guardResult(() => _remote.getTodayAppointments());

  @override
  Future<Either<Failure, List<QueueEntry>>> getQueue(String centerId) =>
      _guardResult(() => _remote.getQueue(centerId));

  @override
  Future<Either<Failure, List<DoctorSchedule>>> getSchedules() =>
      _guardResult(() => _remote.getSchedules());
}
