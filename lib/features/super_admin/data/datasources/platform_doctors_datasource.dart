import '../../../../core/network/dio_client.dart';
import '../../domain/entities/platform_doctor.dart';
import '../models/platform_doctor_model.dart';

class PlatformDoctorsDatasource {
  final DioClient _client;
  PlatformDoctorsDatasource(this._client);

  Future<({List<PlatformDoctor> doctors, int total})> getDoctors({
    String? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    final resp = await _client.dio.get(
      '/super-admin/doctors',
      queryParameters: {
        if (status != null) 'status': status,
        'page': page,
        'pageSize': pageSize,
      },
    );
    final data = resp.data as Map<String, dynamic>;
    final items = (data['items'] as List? ?? [])
        .map((e) => PlatformDoctorModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return (doctors: items, total: data['totalCount'] as int? ?? items.length);
  }

  Future<PlatformDoctor> getDoctorDetail(String doctorId) async {
    final resp = await _client.dio.get('/super-admin/doctors/$doctorId');
    return PlatformDoctorModel.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<void> verifyDoctorLicense(String doctorId, {String? notes}) async {
    await _client.dio.post(
      '/super-admin/doctors/$doctorId/verify-license',
      data: {if (notes != null) 'notes': notes},
    );
  }

  Future<void> suspendDoctor(String doctorId, {required String reason}) async {
    await _client.dio.post(
      '/super-admin/doctors/$doctorId/suspend',
      data: {'reason': reason},
    );
  }
}
