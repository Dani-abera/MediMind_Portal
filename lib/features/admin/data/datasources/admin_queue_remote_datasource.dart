import '../../../../core/network/dio_client.dart';
import '../../domain/entities/queue_item.dart';
import '../models/queue_item_model.dart';

class AdminQueueRemoteDataSource {
  final DioClient _client;
  String _lastCenterId = '';

  AdminQueueRemoteDataSource(this._client);

  Future<List<QueueItemModel>> getQueue(String centerId) async {
    _lastCenterId = centerId;
    final resp = await _client.dio.get('/queue/center/$centerId');
    final body = resp.data as Map<String, dynamic>;
    final waiting = (body['waitingPatients'] as List? ?? [])
        .map((e) => QueueItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final current = body['currentConsultation'];
    if (current != null) {
      waiting.insert(0, QueueItemModel.fromJson(current as Map<String, dynamic>));
    }
    return waiting;
  }

  Future<QueueItemModel> callNext() async {
    final resp = await _client.dio.post(
      '/queue/call-next',
      data: {'centerId': _lastCenterId},
    );
    return QueueItemModel.fromJson(resp.data as Map<String, dynamic>);
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
      data: {'appointmentId': appointmentId, 'centerId': _lastCenterId},
    );
    return QueueItemModel.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<QueueStats> getQueueStats(String centerId) async {
    final items = await getQueue(centerId);
    return queueStatsFromItems(items);
  }
}
