import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/health_record.dart';
import '../../domain/entities/patient.dart';
import '../../domain/entities/patient_summary.dart';
import '../../domain/entities/prediction.dart';
import '../../domain/repositories/patient_repository.dart';
import '../datasources/patient_remote_datasource.dart';

class PatientRepositoryImpl implements PatientRepository {
  final PatientRemoteDataSource _remote;
  final NetworkInfo _network;

  PatientRepositoryImpl(this._remote, this._network);

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
  Future<Either<Failure, List<PatientSummary>>> getPatients({
    String? search,
    bool? hasChronicConditions,
    int page = 1,
    int pageSize = 20,
  }) =>
      _guardResult(() => _remote.getPatients(
            search: search,
            hasChronicConditions: hasChronicConditions,
            page: page,
            pageSize: pageSize,
          ));

  @override
  Future<Either<Failure, Patient>> getPatientById(String id) =>
      _guardResult(() => _remote.getPatientById(id));

  @override
  Future<Either<Failure, List<HealthRecord>>> getHealthRecords(
          String patientId) =>
      _guardResult(() => _remote.getHealthRecords(patientId));

  @override
  Future<Either<Failure, Prediction?>> getLatestPrediction(
          String patientId) async {
    final result = await _guardResult(() => _remote.getPredictions(patientId));
    return result.map((list) => list.isEmpty ? null : list.first);
  }

  @override
  Future<Either<Failure, List<Prediction>>> getPredictions(
          String patientId) =>
      _guardResult(() => _remote.getPredictions(patientId));

  @override
  Future<Either<Failure, Map<String, dynamic>>> getMedicalHistory(
          String patientId) =>
      _guardResult(() => _remote.getMedicalHistory(patientId));
}
