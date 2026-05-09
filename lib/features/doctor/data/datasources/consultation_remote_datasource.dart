import '../../../../core/network/dio_client.dart';
import '../models/video_consultation_model.dart';

class ConsultationRemoteDataSource {
  final DioClient _client;

  ConsultationRemoteDataSource(this._client);

  Future<VideoConsultationModel> initiate(String appointmentId) async {
    final resp = await _client.dio.post(
      '/doctor/consultations',
      data: {'appointmentId': appointmentId},
    );
    return VideoConsultationModel.fromJson(
      resp.data['data'] as Map<String, dynamic>,
    );
  }

  Future<VideoConsultationModel> join(String consultationId) async {
    final resp = await _client.dio.post(
      '/doctor/consultations/$consultationId/join',
    );
    return VideoConsultationModel.fromJson(
      resp.data['data'] as Map<String, dynamic>,
    );
  }

  Future<void> end(String consultationId) async {
    await _client.dio.post('/doctor/consultations/$consultationId/end');
  }

  Future<VideoConsultationModel> getById(String id) async {
    final resp = await _client.dio.get('/doctor/consultations/$id');
    return VideoConsultationModel.fromJson(
      resp.data['data'] as Map<String, dynamic>,
    );
  }

  Future<List<VideoConsultationModel>> getActive() async {
    final resp = await _client.dio.get('/doctor/consultations/active');
    final data = resp.data['data'] as List<dynamic>;
    return data
        .map((e) => VideoConsultationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<VideoConsultationModel>> getToday() async {
    final resp = await _client.dio.get('/doctor/consultations/today');
    final data = resp.data['data'] as List<dynamic>;
    return data
        .map((e) => VideoConsultationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<VideoConsultationModel>> getPast({
    int page = 1,
    int pageSize = 20,
  }) async {
    final resp = await _client.dio.get(
      '/doctor/consultations',
      queryParameters: {'past': true, 'page': page, 'pageSize': pageSize},
    );
    final data = resp.data['data'] as List<dynamic>;
    return data
        .map((e) => VideoConsultationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Map<String, dynamic>>> getChat(String consultationId) async {
    final resp = await _client.dio.get(
      '/doctor/consultations/$consultationId/chat',
    );
    final data = resp.data['data'] as List<dynamic>;
    return data.map((e) => e as Map<String, dynamic>).toList();
  }
}
