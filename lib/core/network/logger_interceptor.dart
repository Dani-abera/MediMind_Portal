import 'dart:developer' as dev;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class LoggerInterceptor extends Interceptor {
  static const int _maxBodySize = 50 * 1024; // 50KB

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      final sanitized = Map<String, dynamic>.from(options.headers)
        ..removeWhere((k, _) => k.toLowerCase() == 'authorization');
      dev.log('→ ${options.method} ${options.path}', name: 'HTTP');
      dev.log('  headers: $sanitized', name: 'HTTP');
      final body = options.data?.toString() ?? '';
      if (body.length <= _maxBodySize) {
        dev.log('  body: $body', name: 'HTTP');
      } else {
        dev.log('  body: [truncated, ${body.length} bytes]', name: 'HTTP');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      dev.log(
        '← ${response.statusCode} ${response.requestOptions.path}',
        name: 'HTTP',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      dev.log(
        '✗ ${err.response?.statusCode} ${err.requestOptions.path}: ${err.message}',
        name: 'HTTP',
      );
    }
    handler.next(err);
  }
}
