import '../../../../core/network/dio_client.dart';
import '../../domain/entities/super_admin_profile.dart';
import '../models/super_admin_profile_model.dart';

class PlatformProfileDatasource {
  final DioClient _client;
  PlatformProfileDatasource(this._client);

  Future<SuperAdminProfile> getProfile() async {
    final resp = await _client.dio.get('/super-admin/profile');
    return SuperAdminProfileModel.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<SuperAdminProfile> updateProfile(SuperAdminProfileModel model) async {
    final resp = await _client.dio.put(
      '/super-admin/profile',
      data: model.toJson(),
    );
    return SuperAdminProfileModel.fromJson(resp.data as Map<String, dynamic>);
  }
}
