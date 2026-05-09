import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../models/auth_tokens_model.dart';
import '../models/user_model.dart';
import '../../domain/entities/user.dart';

abstract class AuthRemoteDataSource {
  Future<void> doctorRequestOtp(String badgeNumber);
  Future<({User user, AuthTokensModel tokens})> doctorVerifyOtp({
    required String badgeNumber,
    required String otpCode,
  });
  Future<({User user, AuthTokensModel tokens, bool requires2fa})> adminLogin({
    required String email,
    required String password,
  });
  Future<({User user, AuthTokensModel tokens})> adminVerifyOtp({
    required String email,
    required String otpCode,
  });
  Future<({User user, AuthTokensModel tokens, bool requires2fa})>
      superAdminLogin({
    required String email,
    required String password,
  });
  Future<({User user, AuthTokensModel tokens})> superAdminVerify2fa({
    required String email,
    required String totpCode,
  });
  Future<AuthTokensModel> refreshToken(String refreshToken);
  Future<void> logout(String refreshToken);
  Future<void> requestPasswordReset(String email);
  Future<void> resetPassword({required String token, required String newPassword});
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
  Future<void> adminRegister({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl(this._dio);

  @override
  Future<void> doctorRequestOtp(String badgeNumber) async {
    try {
      await _dio.post(
        '/auth/doctor/request-otp',
        data: {'badgeNumber': badgeNumber},
      );
    } on DioException catch (e) {
      throw _toException(e);
    }
  }

  @override
  Future<({User user, AuthTokensModel tokens})> doctorVerifyOtp({
    required String badgeNumber,
    required String otpCode,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/auth/doctor/verify-otp',
        data: {'badgeNumber': badgeNumber, 'otpCode': otpCode},
      );
      final data = res.data!;
      return (
        user: _parseUser(data),
        tokens: AuthTokensModel.fromJson(data),
      );
    } on DioException catch (e) {
      throw _toException(e);
    }
  }

  @override
  Future<({User user, AuthTokensModel tokens, bool requires2fa})> adminLogin({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/auth/admin/login',
        data: {'email': email, 'password': password},
      );
      final data = res.data!;
      final requires2fa = data['requires2fa'] as bool? ?? false;
      return (
        user: _parseUser(data),
        tokens: AuthTokensModel.fromJson(data),
        requires2fa: requires2fa,
      );
    } on DioException catch (e) {
      throw _toException(e);
    }
  }

  @override
  Future<({User user, AuthTokensModel tokens})> adminVerifyOtp({
    required String email,
    required String otpCode,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/auth/admin/verify-otp',
        data: {'email': email, 'otpCode': otpCode},
      );
      final data = res.data!;
      return (
        user: _parseUser(data),
        tokens: AuthTokensModel.fromJson(data),
      );
    } on DioException catch (e) {
      throw _toException(e);
    }
  }

  @override
  Future<({User user, AuthTokensModel tokens, bool requires2fa})>
      superAdminLogin({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/auth/superadmin/login',
        data: {'email': email, 'password': password},
      );
      final data = res.data!;
      return (
        user: _parseUser(data),
        tokens: AuthTokensModel.fromJson(data),
        requires2fa: data['requires2fa'] as bool? ?? false,
      );
    } on DioException catch (e) {
      throw _toException(e);
    }
  }

  @override
  Future<({User user, AuthTokensModel tokens})> superAdminVerify2fa({
    required String email,
    required String totpCode,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/auth/super-admin/verify-2fa',
        data: {'email': email, 'totpCode': totpCode},
      );
      final data = res.data!;
      return (
        user: _parseUser(data),
        tokens: AuthTokensModel.fromJson(data),
      );
    } on DioException catch (e) {
      throw _toException(e);
    }
  }

  @override
  Future<AuthTokensModel> refreshToken(String refreshToken) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/auth/refresh-token',
        data: {'refreshToken': refreshToken},
      );
      return AuthTokensModel.fromJson(res.data!);
    } on DioException catch (e) {
      throw _toException(e);
    }
  }

  @override
  Future<void> logout(String refreshToken) async {
    try {
      await _dio.post('/auth/logout', data: {'refreshToken': refreshToken});
    } catch (_) {
      // Best-effort — don't block local logout on network failure
    }
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    try {
      await _dio.post('/auth/admin/forgot-password', data: {'email': email});
    } on DioException catch (e) {
      throw _toException(e);
    }
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      await _dio.post(
        '/auth/admin/reset-password',
        data: {'token': token, 'newPassword': newPassword},
      );
    } on DioException catch (e) {
      throw _toException(e);
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _dio.post(
        '/auth/admin/change-password',
        data: {'current': currentPassword, 'newPassword': newPassword},
      );
    } on DioException catch (e) {
      throw _toException(e);
    }
  }

  @override
  Future<void> adminRegister({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      await _dio.post(
        '/auth/admin/register',
        data: {
          'fullName': fullName,
          'email': email,
          'phoneNumber': phoneNumber,
          'password': password,
        },
      );
    } on DioException catch (e) {
      throw _toException(e);
    }
  }

  User _parseUser(Map<String, dynamic> data) {
    // Decode JWT claims if user object not in response root
    final userMap = data['user'] as Map<String, dynamic>? ?? data;
    final accessToken = data['accessToken'] as String?;
    if (accessToken != null && userMap['sub'] == null) {
      final claims = _decodeJwtPayload(accessToken);
      return UserModel.fromJson({...userMap, ...claims});
    }
    return UserModel.fromJson(userMap);
  }

  Map<String, dynamic> _decodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return {};
      final payload = base64.normalize(parts[1]);
      final decoded = utf8.decode(base64.decode(payload));
      return Map<String, dynamic>.from(
          jsonDecode(decoded) as Map<String, dynamic>);
    } catch (_) {
      return {};
    }
  }

  AppException _toException(DioException e) {
    final code = e.response?.statusCode;
    final msg = _extractMsg(e);
    return switch (code) {
      400 => BadRequestException(msg),
      401 => UnauthorizedException(msg),
      403 => ForbiddenException(msg),
      404 => NotFoundException(msg),
      409 => ConflictException(msg),
      422 => ValidationException(msg),
      500 => ServerException(msg),
      _ => e.error is AppException
          ? e.error as AppException
          : UnknownException(msg),
    };
  }

  String _extractMsg(DioException e) {
    try {
      final data = e.response?.data;
      if (data is Map) {
        return data['detail']?.toString() ??
            data['message']?.toString() ??
            data['title']?.toString() ??
            e.message ??
            'An error occurred';
      }
    } catch (_) {}
    return e.message ?? 'An error occurred';
  }
}
