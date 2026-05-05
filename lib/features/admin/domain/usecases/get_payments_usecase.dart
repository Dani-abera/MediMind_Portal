import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/payment.dart';
import '../repositories/payments_repository.dart';

class GetPaymentsUseCase {
  final PaymentsRepository _repo;
  GetPaymentsUseCase(this._repo);

  Future<Either<Failure, List<Payment>>> call(
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
      _repo.getPayments(centerId,
          status: status, from: from, to: to, method: method,
          minAmount: minAmount, maxAmount: maxAmount, page: page, pageSize: pageSize);
}

class GetPaymentReceiptUseCase {
  final PaymentsRepository _repo;
  GetPaymentReceiptUseCase(this._repo);

  Future<Either<Failure, String?>> call(String paymentId) =>
      _repo.getReceiptUrl(paymentId);
}

class MarkPaymentResolvedUseCase {
  final PaymentsRepository _repo;
  MarkPaymentResolvedUseCase(this._repo);

  Future<Either<Failure, void>> call(String paymentId) =>
      _repo.markPaymentResolved(paymentId);
}
