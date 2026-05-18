import '../../../../core/network/dio_client.dart';
import '../models/patient_at_center_model.dart';

class AdminPatientRemoteDataSource {
  final DioClient _client;
  AdminPatientRemoteDataSource(this._client);

  Future<List<PatientAtCenterModel>> getPatients(
    String centerId, {
    String? search,
    DateTime? from,
    DateTime? to,
    int page = 1,
    int pageSize = 20,
  }) async {
    final resp = await _client.dio.get(
      '/healthcare-centers/$centerId/patients',
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (from != null) 'from': from.toIso8601String(),
        if (to != null) 'to': to.toIso8601String(),
        'page': page,
        'pageSize': pageSize,
      },
    );
    final raw = resp.data;
    final data = raw is List
        ? raw
        : ((raw as Map<String, dynamic>)['items'] ?? raw['data'] ?? <dynamic>[]) as List;
    return data
        .map((e) => PatientAtCenterModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PatientCenterDetailModel> getPatientDetail(
    String centerId,
    String patientId,
  ) async {
    final resp = await _client.dio.get(
      '/healthcare-centers/$centerId/patients/$patientId',
    );
    return PatientCenterDetailModel.fromJson(
      resp.data['data'] as Map<String, dynamic>,
    );
  }
}
