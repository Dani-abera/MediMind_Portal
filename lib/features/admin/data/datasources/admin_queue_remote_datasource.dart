import '../../../../core/network/dio_client.dart';
import '../../domain/entities/queue_item.dart';
import '../models/queue_item_model.dart';

class AdminQueueRemoteDataSource {
  final DioClient _client;
  AdminQueueRemoteDataSource(this._client);

  Future<List<QueueItemModel>> getQueue(String centerId) async {
    final resp = await _client.dio.get('/api/v1/queue/center/$centerId');
    final data = resp.data['data'] as List? ?? [];
    return data.map((e) => QueueItemModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<QueueItemModel> callNext() async {
    final resp = await _client.dio.post('/api/v1/queue/call-next');
    return QueueItemModel.fromJson(resp.data['data'] as Map<String, dynamic>);
  }

  Future<void> markArrived(String queueId) async {
    await _client.dio.post('/api/v1/queue/$queueId/arrived');
  }

  Future<void> markComplete(String queueId) async {
    await _client.dio.post('/api/v1/queue/$queueId/complete');
  }

  Future<void> markNoShow(String queueId) async {
    await _client.dio.post('/api/v1/queue/$queueId/no-show');
  }

  Future<void> skip(String queueId) async {
    await _client.dio.post('/api/v1/queue/$queueId/skip');
  }

  Future<QueueItemModel> insertEmergency(String appointmentId) async {
    final resp = await _client.dio.post('/api/v1/queue/emergency',
        data: {'appointmentId': appointmentId});
    return QueueItemModel.fromJson(resp.data['data'] as Map<String, dynamic>);
  }

  Future<QueueStats> getQueueStats(String centerId) async {
    final items = await getQueue(centerId);
    return queueStatsFromItems(items);
  }
}
