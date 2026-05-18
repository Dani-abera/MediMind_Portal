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
    // Backend exposes status-filtered lists as path segments (/centers/pending)
    // returning a plain array, while the unfiltered endpoint is paginated.
    final path = status != null
        ? '/super-admin/centers/$status'
        : '/super-admin/centers';

    final resp = await _client.dio.get(
      path,
      queryParameters: status == null
          ? {'page': page, 'pageSize': pageSize}
          : null,
    );

    final rawData = resp.data;

    // Backend returns a plain array for path-filtered endpoints (/centers/pending)
    // and a paginated object for the base endpoint.
    List<dynamic> rawList;
    int total;

    if (rawData is Map) {
      rawList = (rawData['items'] as List?) ?? [];
      total = rawData['totalCount'] as int? ?? rawList.length;
    } else {
      rawList = rawData as List;
      total = rawList.length;
    }

    final items = rawList
        .map((e) => PlatformCenterModel.fromJson(
            Map<String, dynamic>.from(e as Map)))
        .toList();
    return (centers: items, total: total);
  }

  Future<PlatformCenter> getCenterDetail(String centerId) async {
    final resp = await _client.dio.get('/super-admin/centers/$centerId');
    return PlatformCenterModel.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<void> approveCenter(
    String centerId, {
    required DateTime trialEndDate,
    String? notes,
  }) async {
    await _client.dio.post(
      '/super-admin/centers/$centerId/approve',
      data: {
        'trialEndDate': trialEndDate.toIso8601String(),
        if (notes != null) 'notes': notes,
      },
    );
  }

  Future<void> rejectCenter(String centerId, {required String reason}) async {
    await _client.dio.post(
      '/super-admin/centers/$centerId/reject',
      data: {'reason': reason},
    );
  }

  Future<void> suspendCenter(
    String centerId, {
    required String reason,
    DateTime? suspendUntil,
  }) async {
    await _client.dio.post(
      '/super-admin/centers/$centerId/suspend',
      data: {
        'reason': reason,
        if (suspendUntil != null)
          'suspendUntil': suspendUntil.toIso8601String(),
      },
    );
  }

  Future<void> reactivateCenter(String centerId) async {
    await _client.dio.post('/super-admin/centers/$centerId/reactivate');
  }

  Future<void> changeSubscription(
    String centerId, {
    required String plan,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  }) async {
    await _client.dio.patch(
      '/super-admin/centers/$centerId/subscription',
      data: {
        'plan': plan,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'reason': reason,
      },
    );
  }
}
