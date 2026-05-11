import 'package:dio/dio.dart';
import '../models/center_model.dart';

abstract class CenterRemoteDataSource {
  Future<CenterModel> registerCenter(Map<String, dynamic> data);
  Future<CenterModel> getMyCenter();
}

class CenterRemoteDataSourceImpl implements CenterRemoteDataSource {
  final Dio _dio;

  CenterRemoteDataSourceImpl(this._dio);

  @override
  Future<CenterModel> registerCenter(Map<String, dynamic> data) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/healthcare-centers',
        data: data,
      );
      return CenterModel.fromJson(res.data!);
    } on DioException catch (e) {
      throw _toException(e);
    }
  }

  @override
  Future<CenterModel> getMyCenter() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/healthcare-centers/mine',
      );
      return CenterModel.fromJson(res.data!);
    } on DioException catch (e) {
      throw _toException(e);
    }
  }

  Exception _toException(DioException e) {
    if (e.response?.data is Map) {
      final data = e.response!.data as Map;
      final msg = data['detail'] ?? data['title'] ?? e.message;
      return Exception(msg);
    }
    return Exception(e.message ?? 'Unknown error occurred');
  }
}
