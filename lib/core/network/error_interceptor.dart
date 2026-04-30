import 'package:dio/dio.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../error/exceptions.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    Sentry.captureException(err, stackTrace: err.stackTrace);

    final code = err.response?.statusCode;
    final message = _extractMessage(err);

    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      return handler.next(
        err.copyWith(error: NetworkTimeoutException(message)),
      );
    }

    if (err.type == DioExceptionType.connectionError) {
      return handler.next(
        err.copyWith(error: NetworkException(message)),
      );
    }

    switch (code) {
      case 400:
        return handler.next(
            err.copyWith(error: BadRequestException(message)));
      case 401:
        return handler.next(
            err.copyWith(error: UnauthorizedException(message)));
      case 403:
        return handler.next(
            err.copyWith(error: ForbiddenException(message)));
      case 404:
        return handler.next(
            err.copyWith(error: NotFoundException(message)));
      case 409:
        return handler.next(
            err.copyWith(error: ConflictException(message)));
      case 422:
        return handler.next(
            err.copyWith(error: ValidationException(message)));
      case 500:
      case 502:
      case 503:
        return handler.next(
            err.copyWith(error: ServerException(message)));
      default:
        return handler.next(
            err.copyWith(error: UnknownException(message)));
    }
  }

  String _extractMessage(DioException err) {
    try {
      final data = err.response?.data;
      if (data is Map) {
        return data['message']?.toString() ??
            data['error']?.toString() ??
            err.message ??
            'An error occurred';
      }
    } catch (_) {}
    return err.message ?? 'An error occurred';
  }
}
