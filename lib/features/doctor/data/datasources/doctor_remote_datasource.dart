import '../../../../core/network/dio_client.dart';
import '../models/center_affiliation_model.dart';
import '../models/doctor_profile_model.dart';
import '../models/doctor_schedule_model.dart';
import '../models/queue_entry_model.dart';

class DoctorRemoteDataSource {
  final DioClient _client;

  DoctorRemoteDataSource(this._client);

  Future<DoctorProfileModel> getProfile() async {
    final resp = await _client.dio.get('/doctor/profile');
    return DoctorProfileModel.fromJson(
      resp.data['data'] as Map<String, dynamic>,
    );
  }

  Future<DoctorProfileModel> updateProfile(Map<String, dynamic> data) async {
    final resp = await _client.dio.put('/doctor/profile', data: data);
    return DoctorProfileModel.fromJson(
      resp.data['data'] as Map<String, dynamic>,
    );
  }

  Future<List<CenterAffiliationModel>> getCenters() async {
    final resp = await _client.dio.get('/doctor/centers');
    final data = resp.data['data'] as List<dynamic>;
    return data
        .map((e) => CenterAffiliationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> getTodaySummary() async {
    final resp = await _client.dio.get('/doctor/today-summary');
    return resp.data['data'] as Map<String, dynamic>;
  }

  Future<List<QueueEntryModel>> getQueue(String centerId) async {
    final resp = await _client.dio.get(
      '/doctor/queue',
      queryParameters: {'centerId': centerId},
    );
    final data = resp.data['data'] as List<dynamic>;
    return data
        .map((e) => QueueEntryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<DoctorScheduleModel>> getSchedules() async {
    final resp = await _client.dio.get('/doctor/schedules');
    final data = resp.data['data'] as List<dynamic>;
    return data
        .map((e) => DoctorScheduleModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
