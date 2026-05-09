import '../../../../core/network/dio_client.dart';
import '../../domain/entities/platform_user.dart';
import '../models/platform_user_model.dart';

class PlatformUsersDatasource {
  final DioClient _client;
  PlatformUsersDatasource(this._client);

  Future<({List<PlatformUser> users, int total})> getUsers({
    String? userType,
    String? status,
    DateTime? from,
    DateTime? to,
    int page = 1,
    int pageSize = 20,
  }) async {
    final resp = await _client.dio.get(
      '/super-admin/users',
      queryParameters: {
        if (userType != null) 'userType': userType,
        if (status != null) 'status': status,
        if (from != null) 'from': from.toIso8601String(),
        if (to != null) 'to': to.toIso8601String(),
        'page': page,
        'pageSize': pageSize,
      },
    );
    final data = resp.data as Map<String, dynamic>;
    final items = (data['data'] as List? ?? [])
        .map((e) => PlatformUserModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return (users: items, total: data['total'] as int? ?? items.length);
  }

  Future<void> suspendUser(
    String userId, {
    required String reason,
    DateTime? suspendUntil,
  }) async {
    await _client.dio.post(
      '/super-admin/users/$userId/suspend',
      data: {
        'reason': reason,
        if (suspendUntil != null)
          'suspendUntil': suspendUntil.toIso8601String(),
      },
    );
  }

  Future<void> reactivateUser(String userId) async {
    await _client.dio.post('/super-admin/users/$userId/reactivate');
  }

  Future<void> forceLogoutUser(String userId) async {
    await _client.dio.post('/super-admin/users/$userId/force-logout');
  }

  Future<void> deleteUser(String userId) async {
    await _client.dio.delete('/super-admin/users/$userId');
  }
}
