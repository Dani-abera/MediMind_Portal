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
    // POST /join to register as participant and receive Agora RTC token + roomId
    // along with the RTM token + matching userId used for in-call chat.
    final joinResp = await _client.dio.post('/video-consultations/$consultationId/join');
    final joinData = joinResp.data as Map<String, dynamic>;
    final agoraToken = (joinData['agoraToken'] as String? ?? '').replaceAll(RegExp(r'\s+'), '');
    final agoraAppId = (joinData['agoraAppId'] as String? ?? '').trim();
    final agoraRtmToken = (joinData['agoraRtmToken'] as String? ?? '').replaceAll(RegExp(r'\s+'), '');
    final agoraRtmUserId = (joinData['agoraRtmUserId'] as String? ?? '').trim();
    final roomId = joinData['roomId'] as String? ?? consultationId;

    // GET full session data for display info (patient name, doctor info, etc.)
    final session = await getById(consultationId);

    // Return the session enriched with the tokens that were returned by the join call.
    return VideoConsultationModel(
      id: session.id,
      appointmentId: session.appointmentId,
      doctorId: session.doctorId,
      patientId: session.patientId,
      patientName: session.patientName,
      status: session.status,
      startedAt: session.startedAt,
      endedAt: session.endedAt,
      signalingRoomId: roomId,
      joinToken: agoraToken,
      agoraAppId: agoraAppId.isEmpty ? null : agoraAppId,
      agoraRtmToken: agoraRtmToken.isEmpty ? null : agoraRtmToken,
      agoraRtmUserId: agoraRtmUserId.isEmpty ? null : agoraRtmUserId,
    );
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

  Future<void> sendMessage(String consultationId, String content) async {
    await _client.dio.post(
      '/video-consultations/$consultationId/messages',
      data: {'content': content},
    );
  }
}
