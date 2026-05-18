import '../../../../core/network/dio_client.dart';
import '../models/video_consultation_model.dart';

class ConsultationRemoteDataSource {
  final DioClient _client;

  ConsultationRemoteDataSource(this._client);

  Future<VideoConsultationModel> initiate(String appointmentId) async {
    final resp = await _client.dio.post(
      '/video-consultations/initiate',
      data: {'appointmentId': appointmentId},
    );
    return VideoConsultationModel.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<VideoConsultationModel> join(String consultationId) async {
    final resp = await _client.dio.post(
      '/video-consultations/$consultationId/join',
    );
    return VideoConsultationModel.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<void> end(String consultationId) async {
    await _client.dio.post('/video-consultations/$consultationId/end');
  }

  Future<VideoConsultationModel> getById(String id) async {
    final resp = await _client.dio.get('/video-consultations/$id');
    return VideoConsultationModel.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<List<VideoConsultationModel>> getActive() async {
    final resp = await _client.dio.get(
      '/video-consultations',
      queryParameters: {'status': 'InProgress'},
    );
    final data = resp.data as List<dynamic>;
    return data
        .map((e) => VideoConsultationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<VideoConsultationModel>> getToday() async {
    final resp = await _client.dio.get(
      '/video-consultations',
      queryParameters: {'today': true},
    );
    final data = resp.data as List<dynamic>;
    return data
        .map((e) => VideoConsultationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<VideoConsultationModel>> getPast({
    int page = 1,
    int pageSize = 20,
  }) async {
    final resp = await _client.dio.get(
      '/video-consultations',
      queryParameters: {
        'status': 'Completed',
        'page': page,
        'pageSize': pageSize,
      },
    );
    final data = resp.data as List<dynamic>;
    return data
        .map((e) => VideoConsultationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Map<String, dynamic>>> getChat(String consultationId) async {
    final resp = await _client.dio.get(
      '/video-consultations/$consultationId/chat',
    );
    final data = resp.data as List<dynamic>;
    return data.map((e) => e as Map<String, dynamic>).toList();
  }
}
