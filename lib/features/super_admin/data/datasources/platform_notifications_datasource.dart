import '../../../../core/network/dio_client.dart';
import '../../domain/entities/platform_notification.dart';
import '../models/platform_notification_model.dart';

class PlatformNotificationsDatasource {
  final DioClient _client;
  PlatformNotificationsDatasource(this._client);

  Future<({List<PlatformNotification> items, int total})> getNotifications({
    int page = 1,
    int pageSize = 20,
  }) async {
    final resp = await _client.dio.get(
      '/super-admin/notifications',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    final data = resp.data as Map<String, dynamic>;
    final items = (data['items'] as List? ?? [])
        .map((e) => PlatformNotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return (items: items, total: (data['totalCount'] as int?) ?? items.length);
  }

  Future<void> markRead(String id) async {
    await _client.dio.patch('/super-admin/notifications/$id/read');
  }

  Future<void> markAllRead() async {
    await _client.dio.patch('/super-admin/notifications/read-all');
  }
}
