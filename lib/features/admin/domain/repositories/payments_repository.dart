import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/payment.dart';

abstract class PaymentsRepository {
  Future<Either<Failure, List<Payment>>> getPayments(
    String centerId, {
    AdminPaymentStatus? status,
    DateTime? from,
    DateTime? to,
    String? method,
    double? minAmount,
    double? maxAmount,
    int page,
    int pageSize,
  });

  Future<Either<Failure, String?>> getReceiptUrl(String paymentId);

  Future<Either<Failure, void>> markPaymentResolved(String paymentId);
}
