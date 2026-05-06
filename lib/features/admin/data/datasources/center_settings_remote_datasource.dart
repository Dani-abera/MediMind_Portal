import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/center_config_model.dart';
import '../models/working_hours_model.dart';
import '../models/booking_rules_model.dart';
import '../models/center_branding_model.dart';

class CenterSettingsRemoteDataSource {
  final DioClient _client;
  CenterSettingsRemoteDataSource(this._client);

  Future<CenterConfigModel> getCenterConfig(String centerId) async {
    final resp = await _client.dio.get('/api/v1/healthcare-centers/$centerId/config');
    return CenterConfigModel.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<CenterConfigModel> saveCenterConfig(String centerId, CenterConfigModel config) async {
    final resp = await _client.dio.put(
      '/api/v1/healthcare-centers/$centerId/config',
      data: config.toJson(),
    );
    return CenterConfigModel.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<WorkingHoursModel> getWorkingHours(String centerId) async {
    final resp = await _client.dio.get('/api/v1/healthcare-centers/$centerId/working-hours');
    return WorkingHoursModel.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<WorkingHoursModel> saveWorkingHours(String centerId, WorkingHoursModel hours) async {
    final resp = await _client.dio.put(
      '/api/v1/healthcare-centers/$centerId/working-hours',
      data: hours.toJson(),
    );
    return WorkingHoursModel.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<BookingRulesModel> getBookingRules(String centerId) async {
    final resp = await _client.dio.get('/api/v1/healthcare-centers/$centerId/booking-rules');
    return BookingRulesModel.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<BookingRulesModel> saveBookingRules(String centerId, BookingRulesModel rules) async {
    final resp = await _client.dio.put(
      '/api/v1/healthcare-centers/$centerId/booking-rules',
      data: rules.toJson(),
    );
    return BookingRulesModel.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<CenterBrandingModel> getCenterBranding(String centerId) async {
    final resp = await _client.dio.get('/api/v1/healthcare-centers/$centerId/branding');
    return CenterBrandingModel.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<CenterBrandingModel> saveCenterBranding(String centerId, CenterBrandingModel branding) async {
    final resp = await _client.dio.put(
      '/api/v1/healthcare-centers/$centerId/branding',
      data: branding.toJson(),
    );
    return CenterBrandingModel.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<String> uploadCenterImage(String centerId, String imageType, String filePath) async {
    final resp = await _client.dio.post(
      '/api/v1/healthcare-centers/$centerId/upload-image',
      data: FormData.fromMap({
        'imageType': imageType,
        'file': await MultipartFile.fromFile(filePath),
      }),
    );
    return resp.data['url'] as String;
  }
}
