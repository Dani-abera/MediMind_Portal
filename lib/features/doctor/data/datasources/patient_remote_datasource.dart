import '../../../../core/network/dio_client.dart';
import '../models/health_record_model.dart';
import '../models/patient_model.dart';
import '../models/patient_summary_model.dart';
import '../models/prediction_model.dart';

class PatientRemoteDataSource {
  final DioClient _client;

  PatientRemoteDataSource(this._client);

  Future<List<PatientSummaryModel>> getPatients({
    String? search,
    bool? hasChronicConditions,
    int page = 1,
    int pageSize = 20,
  }) async {
    final resp = await _client.dio.get(
      '/doctor/patients',
      queryParameters: {
        if (search != null) 'search': search,
        if (hasChronicConditions != null)
          'hasChronicConditions': hasChronicConditions,
        'page': page,
        'pageSize': pageSize,
      },
    );
    final data = resp.data['data'] as List<dynamic>;
    return data
        .map((e) => PatientSummaryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PatientModel> getPatientById(String id) async {
    final resp = await _client.dio.get('/doctor/patients/$id');
    return PatientModel.fromJson(resp.data['data'] as Map<String, dynamic>);
  }

  Future<List<HealthRecordModel>> getHealthRecords(String patientId) async {
    final resp = await _client.dio.get(
      '/doctor/patients/$patientId/health-records',
    );
    final data = resp.data['data'] as List<dynamic>;
    return data
        .map((e) => HealthRecordModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<PredictionModel>> getPredictions(String patientId) async {
    final resp = await _client.dio.get(
      '/doctor/patients/$patientId/predictions',
    );
    final data = resp.data['data'] as List<dynamic>;
    return data
        .map((e) => PredictionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> getMedicalHistory(String patientId) async {
    final resp = await _client.dio.get(
      '/doctor/patients/$patientId/medical-history',
    );
    return resp.data['data'] as Map<String, dynamic>;
  }
}
