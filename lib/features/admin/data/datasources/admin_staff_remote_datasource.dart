import '../../../../core/network/dio_client.dart';
import '../../domain/entities/admin_staff.dart';
import '../models/admin_staff_model.dart';

class AdminStaffRemoteDataSource {
  final DioClient _client;
  AdminStaffRemoteDataSource(this._client);

  Future<List<AdminStaffModel>> getAdmins(String centerId) async {
    final resp = await _client.dio.get('/healthcare-centers/$centerId/admins');
    final data = resp.data['data'] as List? ?? [];
    return data
        .map((e) => AdminStaffModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addAdmin({
    required String centerId,
    required String name,
    required String email,
    required String phone,
    required AdminRole role,
  }) async {
    await _client.dio.post(
      '/healthcare-centers/$centerId/admins',
      data: {'name': name, 'email': email, 'phone': phone, 'role': role.name},
    );
  }

  Future<void> deactivateAdmin(String centerId, String adminId) async {
    await _client.dio.delete('/healthcare-centers/$centerId/admins/$adminId');
  }
}
