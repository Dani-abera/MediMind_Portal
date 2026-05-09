import '../../../../core/network/dio_client.dart';
import '../../domain/entities/platform_analytics.dart';
import '../../domain/entities/platform_dashboard_data.dart';
import '../models/platform_analytics_model.dart';
import '../models/platform_dashboard_model.dart';

class PlatformAnalyticsDatasource {
  final DioClient _client;
  PlatformAnalyticsDatasource(this._client);

  Future<PlatformDashboardData> getDashboardData() async {
    final resp = await _client.dio.get('/super-admin/dashboard');
    return PlatformDashboardModel.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<PlatformAnalytics> getAnalytics({String period = 'last30'}) async {
    final resp = await _client.dio.get(
      '/super-admin/analytics',
      queryParameters: {'period': period},
    );
    return PlatformAnalyticsModel.fromJson(resp.data as Map<String, dynamic>);
  }
}
