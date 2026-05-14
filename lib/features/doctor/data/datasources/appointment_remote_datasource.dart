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
      '/appointments',
      queryParameters: {
        if (status != null) 'status': status,
        if (from != null) 'startDate': from.toIso8601String().substring(0, 10),
        if (to != null) 'endDate': to.toIso8601String().substring(0, 10),
        'page': page,
        'pageSize': pageSize,
      },
    );
    final data = (resp.data['items'] ?? resp.data['data']) as List<dynamic>;
    return data
        .map((e) => AppointmentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AppointmentModel> getAppointmentById(String id) async {
    final resp = await _client.dio.get('/appointments/$id');
    return AppointmentModel.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<AppointmentNoteModel> addNote({
    required String appointmentId,
    required String content,
  }) async {
    final resp = await _client.dio.post(
      '/appointments/$appointmentId/notes',
      data: {'content': content},
    );
    return AppointmentNoteModel.fromJson(
      resp.data as Map<String, dynamic>,
    );
  }

  Future<List<AppointmentNoteModel>> getNotes(String appointmentId) async {
    final resp = await _client.dio.get(
      '/appointments/$appointmentId/notes',
    );
    final items = resp.data is List
        ? resp.data as List<dynamic>
        : (resp.data['items'] ?? resp.data['data'] ?? []) as List<dynamic>;
    return items
        .map((e) => AppointmentNoteModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> cancelAppointment(String id) async {
    await _client.dio.post(
      '/appointments/$id/cancel',
      data: {'cancellationReason': 'Cancelled by doctor'},
    );
  }

  Future<void> markComplete(String id) async {
    await _client.dio.post('/appointments/$id/complete');
  }
}
