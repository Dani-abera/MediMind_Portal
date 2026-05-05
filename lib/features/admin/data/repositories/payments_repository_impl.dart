import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/payment.dart';
import '../../domain/repositories/payments_repository.dart';
import '../datasources/payments_remote_datasource.dart';

class PaymentsRepositoryImpl implements PaymentsRepository {
  final PaymentsRemoteDataSource _remote;
  final NetworkInfo _network;
  PaymentsRepositoryImpl(this._remote, this._network);

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() fn) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try { return Right(await fn()); }
    on ForbiddenException catch (e) { return Left(ForbiddenFailure(e.message)); }
    on ServerException catch (e) { return Left(ServerFailure(e.message)); }
    on AppException catch (e) { return Left(UnknownFailure(e.message)); }
    catch (e) { return Left(UnknownFailure(e.toString())); }
  }

  @override
  Future<Either<Failure, List<Payment>>> getPayments(
    String centerId, {
    AdminPaymentStatus? status,
    DateTime? from,
    DateTime? to,
    String? method,
    double? minAmount,
    double? maxAmount,
    int page = 1,
    int pageSize = 20,
  }) =>
      _guard(() => _remote.getPayments(centerId,
          status: status, from: from, to: to, method: method,
          minAmount: minAmount, maxAmount: maxAmount, page: page, pageSize: pageSize));

  @override
  Future<Either<Failure, String?>> getReceiptUrl(String paymentId) =>
      _guard(() => _remote.getReceiptUrl(paymentId));

  @override
  Future<Either<Failure, void>> markPaymentResolved(String paymentId) =>
      _guard(() => _remote.markPaymentResolved(paymentId));
}
