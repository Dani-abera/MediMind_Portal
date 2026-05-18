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
    String? search,
    int page = 1,
    int pageSize = 20,
  }) async {
    final resp = await _client.dio.get(
      '/appointments',
      queryParameters: {
        if (status != null) 'status': status,
        if (pendingOnly) 'status': 'pending',
        if (doctorId != null) 'doctorId': doctorId,
        if (from != null) 'startDate': from.toIso8601String().substring(0, 10),
        if (to != null) 'endDate': to.toIso8601String().substring(0, 10),
        if (search != null && search.isNotEmpty) 'search': search,
        'page': page,
        'pageSize': pageSize,
      },
    );
    final _raw = resp.data;
    final data = _raw is List
        ? _raw
        : ((_raw as Map<String, dynamic>)['items'] ?? _raw['data'] ?? <dynamic>[]) as List;
    return data
        .map((e) => AdminAppointmentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AdminAppointmentModel> getAppointmentDetail(String id) async {
    final resp = await _client.dio.get('/appointments/$id');
    return AdminAppointmentModel.fromJson(
      resp.data as Map<String, dynamic>,
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
      data: {'cancellationReason': reason ?? 'Cancelled by admin'},
    );
  }

  Future<void> bulkApprove(List<String> ids) async {
    await _client.dio.post('/appointments/bulk-approve', data: {'ids': ids});
  }
}
