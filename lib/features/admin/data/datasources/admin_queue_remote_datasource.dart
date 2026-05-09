import '../../../../core/network/dio_client.dart';
import '../../domain/entities/queue_item.dart';
import '../models/queue_item_model.dart';

class AdminQueueRemoteDataSource {
  final DioClient _client;
  AdminQueueRemoteDataSource(this._client);

  Future<List<QueueItemModel>> getQueue(String centerId) async {
    final resp = await _client.dio.get('/queue/center/$centerId');
    final data = resp.data['data'] as List? ?? [];
    return data
        .map((e) => QueueItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<QueueItemModel> callNext() async {
    final resp = await _client.dio.post('/queue/call-next');
    return QueueItemModel.fromJson(resp.data['data'] as Map<String, dynamic>);
  }

  Future<void> markArrived(String queueId) async {
    await _client.dio.post('/queue/$queueId/arrived');
  }

  Future<void> markComplete(String queueId) async {
    await _client.dio.post('/queue/$queueId/complete');
  }

  Future<void> markNoShow(String queueId) async {
    await _client.dio.post('/queue/$queueId/no-show');
  }

  Future<void> skip(String queueId) async {
    await _client.dio.post('/queue/$queueId/skip');
  }

  Future<QueueItemModel> insertEmergency(String appointmentId) async {
    final resp = await _client.dio.post(
      '/queue/emergency',
      data: {'appointmentId': appointmentId},
    );
    return QueueItemModel.fromJson(resp.data['data'] as Map<String, dynamic>);
  }

  Future<QueueStats> getQueueStats(String centerId) async {
    final items = await getQueue(centerId);
    return queueStatsFromItems(items);
  }
}
