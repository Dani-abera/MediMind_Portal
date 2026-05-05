import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/patient_at_center.dart';
import '../../domain/repositories/admin_patient_repository.dart';
import '../datasources/admin_patient_remote_datasource.dart';

class AdminPatientRepositoryImpl implements AdminPatientRepository {
  final AdminPatientRemoteDataSource _remote;
  final NetworkInfo _network;
  AdminPatientRepositoryImpl(this._remote, this._network);

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

  @override Future<Either<Failure, List<PatientAtCenter>>> getPatients(String centerId,
    {String? search, DateTime? from, DateTime? to, int page = 1, int pageSize = 20}) =>
    _guardResult(() => _remote.getPatients(centerId, search: search, from: from, to: to, page: page, pageSize: pageSize));

  @override Future<Either<Failure, PatientCenterDetail>> getPatientDetail(String centerId, String patientId) =>
    _guardResult(() => _remote.getPatientDetail(centerId, patientId));
}
