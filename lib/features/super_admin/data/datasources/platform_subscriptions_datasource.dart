import '../../../../core/network/dio_client.dart';
import '../../domain/entities/platform_subscription.dart';
import '../models/platform_subscription_model.dart';

class PlatformSubscriptionsDatasource {
  final DioClient _client;
  PlatformSubscriptionsDatasource(this._client);

  Future<({List<PlatformSubscription> subscriptions, int total})> getSubscriptions({
    String? plan,
    String? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    final resp = await _client.dio.get('/api/v1/super-admin/subscriptions', queryParameters: {
      if (plan != null) 'plan': plan,
      if (status != null) 'status': status,
      'page': page,
      'pageSize': pageSize,
    });
    final data = resp.data as Map<String, dynamic>;
    final items = (data['data'] as List? ?? [])
        .map((e) => PlatformSubscriptionModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return (subscriptions: items, total: data['total'] as int? ?? items.length);
  }

  Future<void> changePlan(String centerId, {
    required String plan,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  }) async {
    await _client.dio.patch('/api/v1/super-admin/subscriptions/$centerId/plan', data: {
      'plan': plan,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'reason': reason,
    });
  }
}
