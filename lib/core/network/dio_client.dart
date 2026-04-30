import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth_interceptor.dart';
import 'error_interceptor.dart';
import 'logger_interceptor.dart';
import '../storage/secure_storage.dart';
import 'user_context.dart';

class DioClient {
  late final Dio _dio;

  DioClient({
    required SecureStorage storage,
    required UserContext userContext,
  }) {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? 'https://api.medimind.et/api/v1';

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      LoggerInterceptor(),
      AuthInterceptor(storage, userContext),
      ErrorInterceptor(),
    ]);
  }

  Dio get dio => _dio;
}
