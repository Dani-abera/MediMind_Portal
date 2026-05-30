import '../../../../core/network/dio_client.dart';
import '../../domain/entities/notification_item.dart';
import '../models/notification_item_model.dart';

class NotificationsDatasource {
  final DioClient _client;
  NotificationsDatasource(this._client);

  Future<List<NotificationItem>> getHistory() async {
    final resp = await _client.dio.get('/notifications/history');
    final data = resp.data as List? ?? [];
    return data
        .map((e) => NotificationItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> markRead(String id) async {
    await _client.dio.post('/notifications/$id/mark-read');
  }

  Future<void> markAllRead() async {
    await _client.dio.post('/notifications/mark-all-read');
  }
}
