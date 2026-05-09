import 'dart:convert';
import 'dart:developer' as dev;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class LoggerInterceptor extends Interceptor {
  static const int _maxBodySize = 100 * 1024; // 100KB

  void _log(String message) => dev.log(message, name: 'HTTP');

  String _prettyJson(dynamic data) {
    try {
      final encoder = JsonEncoder.withIndent('  ');
      if (data is String) {
        return encoder.convert(jsonDecode(data));
      }
      return encoder.convert(data);
    } catch (_) {
      return data?.toString() ?? '';
    }
  }

  String _formatBody(dynamic data) {
    if (data == null) return '(empty)';
    final raw = data is String ? data : jsonEncode(data);
    if (raw.length > _maxBodySize) return '[truncated — ${raw.length} bytes]';
    return _prettyJson(data);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      final sanitized = Map<String, dynamic>.from(options.headers)
        ..removeWhere((k, _) => k.toLowerCase() == 'authorization');

      _log('┌── REQUEST ──────────────────────────────────');
      _log('│ ${options.method}  ${options.uri}');
      if (options.queryParameters.isNotEmpty) {
        _log('│ Query: ${options.queryParameters}');
      }
      _log('│ Headers: $sanitized');
      _log('│ Body:\n${_formatBody(options.data)}');
      _log('└─────────────────────────────────────────────');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      _log('┌── RESPONSE ─────────────────────────────────');
      _log('│ ${response.statusCode} ${response.statusMessage}  ${response.requestOptions.uri}');
      _log('│ Body:\n${_formatBody(response.data)}');
      _log('└─────────────────────────────────────────────');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      _log('┌── ERROR ────────────────────────────────────');
      _log('│ ${err.response?.statusCode ?? "??"}  ${err.requestOptions.uri}');
      _log('│ Type: ${err.type}');
      _log('│ Message: ${err.message}');
      if (err.response?.data != null) {
        _log('│ Response body:\n${_formatBody(err.response!.data)}');
      }
      _log('└─────────────────────────────────────────────');
    }
    handler.next(err);
  }
}
