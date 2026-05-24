import '../../../../core/error/exceptions.dart';
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
    final raw = resp.data;
    final List<dynamic> data;
    if (raw is List) {
      data = raw;
    } else if (raw is Map<String, dynamic>) {
      data = (raw['items'] ?? raw['data'] ?? []) as List<dynamic>;
    } else {
      data = [];
    }
    return data
        .map((e) => AppointmentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AppointmentModel> getAppointmentById(String id) async {
    final resp = await _client.dio.get('/appointments/$id');
    final data = resp.data;
    if (data is! Map<String, dynamic>) {
      throw ServerException('Unexpected response for appointment $id');
    }
    return AppointmentModel.fromJson(data);
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
    final data = resp.data;
    if (data == null) return [];
    if (data is List) {
      return data
          .map((e) => AppointmentNoteModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (data is Map<String, dynamic>) {
      return [AppointmentNoteModel.fromJson(data)];
    }
    return [];
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

  Future<void> doctorRejectAppointment(String id, String reason) async {
    await _client.dio.post(
      '/appointments/$id/doctor-reject',
      data: {'reason': reason},
    );
  }
}
