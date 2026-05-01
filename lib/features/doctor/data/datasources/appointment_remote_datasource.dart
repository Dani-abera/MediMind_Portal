import '../../../../core/network/dio_client.dart';
import '../models/appointment_model.dart';
import '../models/appointment_note_model.dart';

class AppointmentRemoteDataSource {
  final DioClient _client;

  AppointmentRemoteDataSource(this._client);

  Future<List<AppointmentModel>> getAppointments({
    String? status,
    DateTime? from,
    DateTime? to,
    int page = 1,
    int pageSize = 20,
  }) async {
    final resp = await _client.dio.get(
      '/api/v1/doctor/appointments',
      queryParameters: {
        if (status != null) 'status': status,
        if (from != null) 'from': from.toIso8601String(),
        if (to != null) 'to': to.toIso8601String(),
        'page': page,
        'pageSize': pageSize,
      },
    );
    final data = resp.data['data'] as List<dynamic>;
    return data
        .map((e) => AppointmentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AppointmentModel> getAppointmentById(String id) async {
    final resp = await _client.dio.get('/api/v1/doctor/appointments/$id');
    return AppointmentModel.fromJson(resp.data['data'] as Map<String, dynamic>);
  }

  Future<AppointmentNoteModel> addNote({
    required String appointmentId,
    required String content,
  }) async {
    final resp = await _client.dio.post(
      '/api/v1/doctor/appointments/$appointmentId/notes',
      data: {'content': content},
    );
    return AppointmentNoteModel.fromJson(
        resp.data['data'] as Map<String, dynamic>);
  }

  Future<List<AppointmentNoteModel>> getNotes(String appointmentId) async {
    final resp = await _client.dio
        .get('/api/v1/doctor/appointments/$appointmentId/notes');
    final data = resp.data['data'] as List<dynamic>;
    return data
        .map((e) => AppointmentNoteModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> cancelAppointment(String id) async {
    await _client.dio.post('/api/v1/doctor/appointments/$id/cancel');
  }

  Future<void> markComplete(String id) async {
    await _client.dio.post('/api/v1/doctor/appointments/$id/complete');
  }
}
