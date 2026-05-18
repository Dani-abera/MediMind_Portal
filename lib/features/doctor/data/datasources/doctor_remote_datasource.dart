import '../../../../core/network/dio_client.dart';
import '../models/center_affiliation_model.dart';
import '../models/doctor_profile_model.dart';
import '../models/doctor_schedule_model.dart';
import '../models/queue_entry_model.dart';

class DoctorRemoteDataSource {
  final DioClient _client;

  DoctorRemoteDataSource(this._client);

  Future<DoctorProfileModel> getProfile() async {
    final resp = await _client.dio.get('/doctors/me');
    return DoctorProfileModel.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<DoctorProfileModel> updateProfile(Map<String, dynamic> data) async {
    final resp = await _client.dio.put('/doctors/me', data: data);
    return DoctorProfileModel.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<List<CenterAffiliationModel>> getCenters() async {
    final resp = await _client.dio.get('/doctors/me/centers');
    final data = resp.data as List<dynamic>;
    return data
        .map((e) => CenterAffiliationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Map<String, dynamic>>> getTodayAppointments() async {
    final resp = await _client.dio.get('/doctors/me/today');
    final data = resp.data as List<dynamic>;
    return data.map((e) => e as Map<String, dynamic>).toList();
  }

  Future<List<QueueEntryModel>> getQueue(String centerId) async {
    final resp = await _client.dio.get('/doctors/me/queue/$centerId');
    final data = resp.data as List<dynamic>;
    return data
        .map((e) => QueueEntryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<DoctorScheduleModel>> getSchedules() async {
    final resp = await _client.dio.get('/doctors/me/schedules');
    final data = resp.data['data'] as List<dynamic>;
    return data
        .map((e) => DoctorScheduleModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
