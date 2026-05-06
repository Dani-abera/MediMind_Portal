import '../../../../core/network/dio_client.dart';
import '../../domain/entities/platform_center.dart';
import '../models/platform_center_model.dart';

class PlatformCentersDatasource {
  final DioClient _client;
  PlatformCentersDatasource(this._client);

  Future<({List<PlatformCenter> centers, int total})> getCenters({
    String? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    final resp = await _client.dio.get('/api/v1/super-admin/centers', queryParameters: {
      if (status != null) 'status': status,
      'page': page,
      'pageSize': pageSize,
    });
    final data = resp.data as Map<String, dynamic>;
    final items = (data['data'] as List? ?? [])
        .map((e) => PlatformCenterModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return (centers: items, total: data['total'] as int? ?? items.length);
  }

  Future<PlatformCenter> getCenterDetail(String centerId) async {
    final resp = await _client.dio.get('/api/v1/super-admin/centers/$centerId');
    return PlatformCenterModel.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<void> approveCenter(String centerId, {required DateTime trialEndDate, String? notes}) async {
    await _client.dio.post('/api/v1/super-admin/centers/$centerId/approve', data: {
      'trialEndDate': trialEndDate.toIso8601String(),
      if (notes != null) 'notes': notes,
    });
  }

  Future<void> rejectCenter(String centerId, {required String reason}) async {
    await _client.dio.post('/api/v1/super-admin/centers/$centerId/reject', data: {'reason': reason});
  }

  Future<void> suspendCenter(String centerId, {required String reason, DateTime? suspendUntil}) async {
    await _client.dio.post('/api/v1/super-admin/centers/$centerId/suspend', data: {
      'reason': reason,
      if (suspendUntil != null) 'suspendUntil': suspendUntil.toIso8601String(),
    });
  }

  Future<void> reactivateCenter(String centerId) async {
    await _client.dio.post('/api/v1/super-admin/centers/$centerId/reactivate');
  }

  Future<void> changeSubscription(String centerId, {
    required String plan,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  }) async {
    await _client.dio.patch('/api/v1/super-admin/centers/$centerId/subscription', data: {
      'plan': plan,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'reason': reason,
    });
  }
}
