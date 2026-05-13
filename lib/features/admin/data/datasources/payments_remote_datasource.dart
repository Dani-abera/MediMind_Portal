import '../../../../core/network/dio_client.dart';
import '../../domain/entities/payment.dart';
import '../models/payment_model.dart';

class PaymentsRemoteDataSource {
  final DioClient _client;
  PaymentsRemoteDataSource(this._client);

  Future<List<PaymentModel>> getPayments(
    String centerId, {
    AdminPaymentStatus? status,
    DateTime? from,
    DateTime? to,
    String? method,
    double? minAmount,
    double? maxAmount,
    int page = 1,
    int pageSize = 20,
  }) async {
    final resp = await _client.dio.get(
      '/payments',
      queryParameters: {
        'centerId': centerId,
        if (status != null) 'status': status.name,
        if (from != null) 'startDate': from.toIso8601String(),
        if (to != null) 'endDate': to.toIso8601String(),
        if (method != null) 'method': method,
        if (minAmount != null) 'minAmount': minAmount,
        if (maxAmount != null) 'maxAmount': maxAmount,
        'page': page,
        'pageSize': pageSize,
      },
    );
    final data = resp.data['data'] as List? ?? [];
    return data
        .map((e) => PaymentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<String?> getReceiptUrl(String paymentId) async {
    final resp = await _client.dio.get('/payments/$paymentId/receipt');
    return resp.data['url'] as String?;
  }

  Future<void> markPaymentResolved(String paymentId) async {
    // No backend endpoint for manual resolve — operation is logged client-side only.
    // Backend payment status is managed exclusively by Chapa webhook.
  }
}
