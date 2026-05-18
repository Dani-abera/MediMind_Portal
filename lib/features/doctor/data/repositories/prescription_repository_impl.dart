import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/prescription.dart';
import '../../domain/entities/prescription_template.dart';
import '../../domain/repositories/prescription_repository.dart';
import '../datasources/prescription_remote_datasource.dart';

class PrescriptionRepositoryImpl implements PrescriptionRepository {
  final PrescriptionRemoteDataSource _remote;
  final NetworkInfo _network;

  PrescriptionRepositoryImpl(this._remote, this._network);

  Future<Either<Failure, void>> _guard(Future<void> Function() fn) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      await fn();
      return const Right(null);
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
  Future<Either<Failure, List<Prescription>>> getPrescriptions({
    String? status,
    String? patientId,
    DateTime? from,
    DateTime? to,
    int page = 1,
    int pageSize = 20,
  }) =>
      _guardResult(() => _remote.getPrescriptions(
            status: status,
            patientId: patientId,
            from: from,
            to: to,
            page: page,
            pageSize: pageSize,
          ));

  @override
  Future<Either<Failure, Prescription>> getPrescriptionById(String id) =>
      _guardResult(() => _remote.getPrescriptionById(id));

  @override
  Future<Either<Failure, Prescription>> createPrescription(
          CreatePrescriptionParams params) =>
      _guardResult(() => _remote.createPrescription(params));

  @override
  Future<Either<Failure, String>> getPrescriptionPdfUrl(String id) =>
      _guardResult(() async {
        final resp = await _remote.getPrescriptionPdfUrl(id);
        return resp;
      });

  @override
  Future<Either<Failure, void>> markDispensed(String id) =>
      _guard(() => _remote.markDispensed(id));

  @override
  Future<Either<Failure, void>> revoke(String id, String reason) =>
      _guard(() => _remote.revoke(id, reason));

  @override
  Future<Either<Failure, List<PrescriptionTemplate>>> getTemplates() =>
      _guardResult(() => _remote.getTemplates());

  @override
  Future<Either<Failure, PrescriptionTemplate>> createTemplate(
          Map<String, dynamic> data) =>
      _guardResult(() => _remote.createTemplate(data));

  @override
  Future<Either<Failure, PrescriptionTemplate>> updateTemplate(
          String id, Map<String, dynamic> data) =>
      _guardResult(() => _remote.updateTemplate(id, data));

  @override
  Future<Either<Failure, void>> deleteTemplate(String id) =>
      _guard(() => _remote.deleteTemplate(id));

  @override
  Future<Either<Failure, Prescription>> createFromTemplate(
          String templateId, String? appointmentId) =>
      _guardResult(
          () => _remote.createFromTemplate(templateId, appointmentId));
}
