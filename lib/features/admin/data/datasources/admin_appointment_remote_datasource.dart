import '../../../../core/network/dio_client.dart';
import '../models/admin_appointment_model.dart';

class AdminAppointmentRemoteDataSource {
  final DioClient _client;
  AdminAppointmentRemoteDataSource(this._client);

  Future<List<AdminAppointmentModel>> getAppointments({
    String? status,
    String? doctorId,
    DateTime? from,
    DateTime? to,
    bool pendingOnly = false,
    int page = 1,
    int pageSize = 20,
  }) async {
    final resp = await _client.dio.get(
      '/appointments',
      queryParameters: {
        if (status != null) 'status': status,
        if (pendingOnly) 'status': 'pending',
        if (doctorId != null) 'doctorId': doctorId,
        if (from != null) 'from': from.toIso8601String(),
        if (to != null) 'to': to.toIso8601String(),
        'page': page,
        'pageSize': pageSize,
      },
    );
    final data = resp.data['data'] as List? ?? [];
    return data
        .map((e) => AdminAppointmentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AdminAppointmentModel> getAppointmentDetail(String id) async {
    final resp = await _client.dio.get('/appointments/$id');
    return AdminAppointmentModel.fromJson(
      resp.data['data'] as Map<String, dynamic>,
    );
  }

  Future<void> approveAppointment(String id) async {
    await _client.dio.post('/appointments/$id/approve');
  }

  Future<void> rejectAppointment(String id, {String? reason}) async {
    await _client.dio.post(
      '/appointments/$id/reject',
      data: {if (reason != null) 'reason': reason},
    );
  }

  Future<void> cancelAppointment(String id, {String? reason}) async {
    await _client.dio.post(
      '/appointments/$id/cancel',
      data: {if (reason != null) 'reason': reason},
    );
  }

  Future<void> bulkApprove(List<String> ids) async {
    await _client.dio.post('/appointments/bulk-approve', data: {'ids': ids});
  }
}
