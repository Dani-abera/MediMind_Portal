import '../../../../core/network/dio_client.dart';
import '../../domain/entities/doctor_at_center.dart';
import '../models/doctor_at_center_model.dart';

class AdminDoctorRemoteDataSource {
  final DioClient _client;
  AdminDoctorRemoteDataSource(this._client);

  Future<List<DoctorAtCenterModel>> getDoctors(String centerId) async {
    final resp = await _client.dio.get('/healthcare-centers/$centerId/doctors');
    final data = resp.data['data'] as List? ?? [];
    return data
        .map((e) => DoctorAtCenterModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> inviteDoctor(String centerId, InviteDoctorDto dto) async {
    await _client.dio.post(
      '/healthcare-centers/$centerId/doctors/invite',
      data: dto.toJson(),
    );
  }

  // Legacy add-by-license (kept for internal use)
  Future<void> addDoctor(String centerId, String licenseNumber) async {
    await _client.dio.post(
      '/healthcare-centers/$centerId/doctors',
      data: {'licenseNumber': licenseNumber},
    );
  }

  Future<void> removeDoctor(String centerId, String doctorId) async {
    await _client.dio.delete('/healthcare-centers/$centerId/doctors/$doctorId');
  }

  Future<void> updateConsultationFee(String centerId, String doctorId, double fee) async {
    await _client.dio.put(
      '/healthcare-centers/$centerId/doctors/$doctorId/fee',
      data: {'consultationFee': fee},
    );
  }

  Future<void> configureSchedule(DoctorScheduleConfig config) async {
    await _client.dio.post('/doctor-schedules', data: config.toJson());
  }

  Future<DoctorScheduleConfigModel?> getDoctorSchedule(
    String doctorId,
    String centerId,
  ) async {
    try {
      final resp = await _client.dio.get('/doctor-schedules/$doctorId/$centerId');
      final data = resp.data['data'] ?? resp.data;
      if (data == null) return null;
      return DoctorScheduleConfigModel.fromJson(data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteSchedule(String scheduleId) async {
    await _client.dio.delete('/doctor-schedules/$scheduleId');
  }

  // ── Schedule exceptions ───────────────────────────────────────────────────

  Future<List<ScheduleExceptionModel>> getScheduleExceptions(
    String doctorId,
    String centerId,
  ) async {
    try {
      final resp = await _client.dio.get('/doctor-schedules/$doctorId/$centerId/exceptions');
      final data = resp.data['data'] as List? ?? (resp.data is List ? resp.data as List : []);
      return data.map((e) => ScheduleExceptionModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> addScheduleException(
    String doctorId,
    String centerId,
    ScheduleException exception,
  ) async {
    await _client.dio.post(
      '/doctor-schedules/$doctorId/$centerId/exceptions',
      data: exception.toJson(),
    );
  }

  Future<void> deleteScheduleException(
    String doctorId,
    String centerId,
    DateTime date,
  ) async {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    await _client.dio.delete('/doctor-schedules/$doctorId/$centerId/exceptions/$dateStr');
  }
}
