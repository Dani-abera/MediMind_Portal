import 'package:dio/dio.dart';
import 'user_context.dart';
import '../storage/secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorage _storage;
  final UserContext _ctx;

  AuthInterceptor(this._storage, this._ctx);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = _ctx.accessToken ?? await _storage.readAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        final retryOptions = err.requestOptions.copyWith(
          headers: {
            ...err.requestOptions.headers,
            'Authorization': 'Bearer ${_ctx.accessToken}',
          },
        );
        try {
          final dio = Dio();
          final response = await dio.fetch(retryOptions);
          return handler.resolve(response);
        } catch (e) {
          _ctx.clear();
        }
      } else {
        _ctx.clear();
      }
    }
    handler.next(err);
  }

  Future<bool> _tryRefresh() async {
    try {
      final refresh = await _storage.readRefreshToken();
      if (refresh == null) return false;
      final dio = Dio();
      final res = await dio.post(
        '${const String.fromEnvironment('API_BASE_URL', defaultValue: 'https://api.medimind.et/api/v1')}/auth/refresh',
        data: {'refreshToken': refresh},
      );
      final newAccess = res.data['accessToken'] as String?;
      final newRefresh = res.data['refreshToken'] as String?;
      if (newAccess == null) return false;
      _ctx.accessToken = newAccess;
      if (newRefresh != null) _ctx.refreshToken = newRefresh;
      await _storage.writeAccessToken(newAccess);
      if (newRefresh != null) await _storage.writeRefreshToken(newRefresh);
      return true;
    } catch (_) {
      return false;
    }
  }
}
