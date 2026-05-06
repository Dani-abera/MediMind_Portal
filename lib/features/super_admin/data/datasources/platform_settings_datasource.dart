import '../../../../core/network/dio_client.dart';
import '../../domain/entities/platform_settings.dart';
import '../models/platform_settings_model.dart';

class PlatformSettingsDatasource {
  final DioClient _client;
  PlatformSettingsDatasource(this._client);

  Future<PlatformSettings> getSettings() async {
    final resp = await _client.dio.get('/api/v1/super-admin/settings');
    return PlatformSettingsModel.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<PlatformSettings> saveSettings(PlatformSettingsModel settings) async {
    final resp = await _client.dio.put('/api/v1/super-admin/settings', data: settings.toJson());
    return PlatformSettingsModel.fromJson(resp.data as Map<String, dynamic>);
  }
}
