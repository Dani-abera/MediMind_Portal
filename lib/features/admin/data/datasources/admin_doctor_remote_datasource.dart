import '../../../../core/network/dio_client.dart';
import '../../domain/entities/doctor_at_center.dart';
import '../models/doctor_at_center_model.dart';

class AdminDoctorRemoteDataSource {
  final DioClient _client;
  AdminDoctorRemoteDataSource(this._client);

  Future<List<DoctorAtCenterModel>> getDoctors(String centerId) async {
    final resp = await _client.dio.get('/api/v1/healthcare-centers/$centerId/doctors');
    final data = resp.data['data'] as List? ?? [];
    return data.map((e) => DoctorAtCenterModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> addDoctor(String centerId, String licenseNumber) async {
    await _client.dio.post('/api/v1/healthcare-centers/$centerId/doctors',
        data: {'licenseNumber': licenseNumber});
  }

  Future<void> removeDoctor(String centerId, String doctorId) async {
    await _client.dio.delete('/api/v1/healthcare-centers/$centerId/doctors/$doctorId');
  }

  Future<void> configureSchedule(DoctorScheduleConfig config) async {
    await _client.dio.post('/api/v1/doctor-schedules', data: config.toJson());
  }

  Future<DoctorScheduleConfigModel?> getDoctorSchedule(String doctorId, String centerId) async {
    try {
      final resp = await _client.dio.get('/api/v1/doctor-schedules/$doctorId/$centerId');
      final data = resp.data['data'];
      if (data == null) return null;
      return DoctorScheduleConfigModel.fromJson(data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteSchedule(String scheduleId) async {
    await _client.dio.delete('/api/v1/doctor-schedules/$scheduleId');
  }
}
