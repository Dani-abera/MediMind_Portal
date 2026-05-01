import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/video_consultation.dart';
import '../../domain/repositories/consultation_repository.dart';
import '../datasources/consultation_remote_datasource.dart';

class ConsultationRepositoryImpl implements ConsultationRepository {
  final ConsultationRemoteDataSource _remote;
  final NetworkInfo _network;

  ConsultationRepositoryImpl(this._remote, this._network);

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
  Future<Either<Failure, VideoConsultation>> initiate(String appointmentId) =>
      _guardResult(() => _remote.initiate(appointmentId));

  @override
  Future<Either<Failure, VideoConsultation>> join(String consultationId) =>
      _guardResult(() => _remote.join(consultationId));

  @override
  Future<Either<Failure, void>> end(String consultationId) =>
      _guard(() => _remote.end(consultationId));

  @override
  Future<Either<Failure, VideoConsultation>> getById(String id) =>
      _guardResult(() => _remote.getById(id));

  @override
  Future<Either<Failure, List<VideoConsultation>>> getActive() =>
      _guardResult(() => _remote.getActive());

  @override
  Future<Either<Failure, List<VideoConsultation>>> getToday() =>
      _guardResult(() => _remote.getToday());

  @override
  Future<Either<Failure, List<VideoConsultation>>> getPast({
    int page = 1,
    int pageSize = 20,
  }) =>
      _guardResult(() => _remote.getPast(page: page, pageSize: pageSize));

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getChat(
          String consultationId) =>
      _guardResult(() => _remote.getChat(consultationId));
}
