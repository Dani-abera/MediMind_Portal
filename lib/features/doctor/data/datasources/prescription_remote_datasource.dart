import '../../../../core/network/dio_client.dart';
import '../../domain/repositories/prescription_repository.dart';
import '../models/medication_model.dart';
import '../models/prescription_model.dart';
import '../models/prescription_template_model.dart';

class PrescriptionRemoteDataSource {
  final DioClient _client;

  PrescriptionRemoteDataSource(this._client);

  Future<List<PrescriptionModel>> getPrescriptions({
    String? status,
    String? patientId,
    DateTime? from,
    DateTime? to,
    int page = 1,
    int pageSize = 20,
  }) async {
    final resp = await _client.dio.get(
      '/prescriptions',
      queryParameters: {
        if (status != null) 'status': status,
        if (patientId != null) 'patientId': patientId,
        if (from != null) 'from': from.toIso8601String(),
        if (to != null) 'to': to.toIso8601String(),
        'page': page,
        'pageSize': pageSize,
      },
    );
    final data = resp.data is List
        ? resp.data as List<dynamic>
        : (resp.data['items'] ?? resp.data['data'] ?? []) as List<dynamic>;
    return data
        .map((e) => PrescriptionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PrescriptionModel> getPrescriptionById(String id) async {
    final resp = await _client.dio.get('/prescriptions/$id');
    return PrescriptionModel.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<PrescriptionModel> createPrescription(
    CreatePrescriptionParams params,
  ) async {
    final resp = await _client.dio.post(
      '/prescriptions',
      data: {
        'patientId': params.patientId,
        if (params.appointmentId != null) 'appointmentId': params.appointmentId,
        'diagnosis': params.diagnosis,
        'medications': params.medications
            .map((m) => MedicationModel.fromEntity(m).toJson())
            .toList(),
        'labTests': params.labTests,
        if (params.followUpInstructions != null)
          'followUpInstructions': params.followUpInstructions,
        if (params.specialInstructions != null)
          'specialInstructions': params.specialInstructions,
        if (params.expiresAt != null)
          'expiresAt': params.expiresAt!.toIso8601String(),
      },
    );
    return PrescriptionModel.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<String> getPrescriptionPdfUrl(String id) async {
    final resp = await _client.dio.get('/prescriptions/$id/pdf');
    return resp.data['data']['url'] as String;
  }

  Future<void> markDispensed(String id) async {
    await _client.dio.post('/prescriptions/$id/mark-dispensed');
  }

  Future<void> revoke(String id, String reason) async {
    await _client.dio.post(
      '/prescriptions/$id/revoke',
      data: {'reason': reason},
    );
  }

  Future<List<PrescriptionTemplateModel>> getTemplates() async {
    final resp = await _client.dio.get('/prescription-templates');
    final data = resp.data is List
        ? resp.data as List<dynamic>
        : (resp.data['items'] ?? resp.data['data'] ?? []) as List<dynamic>;
    return data
        .map(
          (e) => PrescriptionTemplateModel.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }

  Future<PrescriptionTemplateModel> createTemplate(
    Map<String, dynamic> data,
  ) async {
    final resp = await _client.dio.post('/prescription-templates', data: data);
    return PrescriptionTemplateModel.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<PrescriptionTemplateModel> updateTemplate(
    String id,
    Map<String, dynamic> data,
  ) async {
    final resp = await _client.dio.put('/prescription-templates/$id', data: data);
    return PrescriptionTemplateModel.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<void> deleteTemplate(String id) async {
    await _client.dio.delete('/prescription-templates/$id');
  }

  Future<PrescriptionModel> createFromTemplate(
    String templateId,
    String? appointmentId,
  ) async {
    final resp = await _client.dio.post(
      '/prescriptions/from-template',
      data: {
        'templateId': templateId,
        if (appointmentId != null) 'appointmentId': appointmentId,
      },
    );
    return PrescriptionModel.fromJson(resp.data as Map<String, dynamic>);
  }
}
