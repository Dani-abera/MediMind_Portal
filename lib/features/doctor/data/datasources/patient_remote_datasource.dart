import 'package:dio/dio.dart';
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
      '/doctors/me/patients',
      queryParameters: {
        if (search != null) 'search': search,
        'page': page,
        'pageSize': pageSize,
      },
    );
    final data = resp.data['items'] as List<dynamic>;
    return data
        .map((e) => PatientSummaryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PatientModel> getPatientById(String id) async {
    final resp = await _client.dio.get('/doctors/me/patients/$id');
    return PatientModel.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<List<HealthRecordModel>> getHealthRecords(String patientId) async {
    final resp = await _client.dio.get(
      '/patients/$patientId/health-records',
    );
    final data = resp.data['data'] as List<dynamic>;
    return data
        .map((e) => HealthRecordModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<PredictionModel>> getPredictions(String patientId) async {
    try {
      final resp = await _client.dio.get(
        '/patients/$patientId/predictions/latest',
      );
      if (resp.data == null) return [];
      return [PredictionModel.fromJson(resp.data as Map<String, dynamic>)];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getMedicalHistory(String patientId) async {
    try {
      final resp = await _client.dio.get(
        '/patients/$patientId/medical-history',
      );
      if (resp.data == null) return {};
      return resp.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return {};
      rethrow;
    }
  }
}
