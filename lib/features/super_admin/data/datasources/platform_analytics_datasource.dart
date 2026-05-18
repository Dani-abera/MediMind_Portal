import '../../../../core/network/dio_client.dart';
import '../../domain/entities/platform_analytics.dart';
import '../../domain/entities/platform_dashboard_data.dart';
import '../models/platform_analytics_model.dart';

class PlatformAnalyticsDatasource {
  final DioClient _client;
  PlatformAnalyticsDatasource(this._client);

  Future<PlatformDashboardData> getDashboardData() async {
    final resp = await _client.dio.get(
      '/super-admin/centers',
      queryParameters: {'page': 1, 'pageSize': 100},
    );
    final rawData = resp.data;
    final List<dynamic> items;
    final int totalCenters;

    if (rawData is Map) {
      items = (rawData['items'] as List?) ?? [];
      totalCenters = rawData['totalCount'] as int? ?? items.length;
    } else {
      items = rawData as List;
      totalCenters = items.length;
    }

    int activeCenters = 0;
    int pendingApprovals = 0;
    final subscriptionBreakdown = <String, int>{};

    for (final raw in items) {
      final m = Map<String, dynamic>.from(raw as Map);
      final status = m['subscriptionStatus'] as String? ?? '';
      subscriptionBreakdown[status] = (subscriptionBreakdown[status] ?? 0) + 1;
      switch (status.toLowerCase()) {
        case 'active':
          activeCenters++;
        case 'pendingapproval':
          pendingApprovals++;
      }
    }

    return PlatformDashboardData(
      totalCenters: totalCenters,
      activeCenters: activeCenters,
      pendingApprovals: pendingApprovals,
      subscriptionBreakdown: subscriptionBreakdown,
    );
  }

  Future<PlatformAnalytics> getAnalytics({String period = 'last30'}) async {
    final resp = await _client.dio.get(
      '/super-admin/analytics',
      queryParameters: {'period': period},
    );
    return PlatformAnalyticsModel.fromJson(resp.data as Map<String, dynamic>);
  }
}
