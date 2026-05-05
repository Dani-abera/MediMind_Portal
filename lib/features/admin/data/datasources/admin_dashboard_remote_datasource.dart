import '../../../../core/network/dio_client.dart';
import '../models/admin_dashboard_data_model.dart';

class AdminDashboardRemoteDataSource {
  final DioClient _client;
  AdminDashboardRemoteDataSource(this._client);

  Future<AdminDashboardDataModel> getDashboardData(String centerId) async {
    final resp = await _client.dio.get('/api/v1/healthcare-centers/$centerId/dashboard/today');
    return AdminDashboardDataModel.fromJson(resp.data['data'] as Map<String, dynamic>);
  }
}
