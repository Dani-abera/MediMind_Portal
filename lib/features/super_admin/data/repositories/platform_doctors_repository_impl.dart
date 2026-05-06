import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/platform_doctor.dart';
import '../../domain/repositories/platform_doctors_repository.dart';
import '../datasources/platform_doctors_datasource.dart';

class PlatformDoctorsRepositoryImpl implements PlatformDoctorsRepository {
  final PlatformDoctorsDatasource _remote;
  final NetworkInfo _network;
  PlatformDoctorsRepositoryImpl(this._remote, this._network);

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
  Future<Either<Failure, ({List<PlatformDoctor> doctors, int total})>> getDoctors({
    String? status,
    int page = 1,
    int pageSize = 20,
  }) =>
      _guard(() => _remote.getDoctors(status: status, page: page, pageSize: pageSize));

  @override
  Future<Either<Failure, PlatformDoctor>> getDoctorDetail(String doctorId) =>
      _guard(() => _remote.getDoctorDetail(doctorId));

  @override
  Future<Either<Failure, void>> verifyDoctorLicense(String doctorId, {String? notes}) =>
      _guard(() => _remote.verifyDoctorLicense(doctorId, notes: notes));

  @override
  Future<Either<Failure, void>> suspendDoctor(String doctorId, {required String reason}) =>
      _guard(() => _remote.suspendDoctor(doctorId, reason: reason));
}
