import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/storage/secure_storage.dart';
import '../models/auth_tokens_model.dart';
import '../models/user_model.dart';
import '../../domain/entities/admin_user.dart';
import '../../domain/entities/doctor_user.dart';
import '../../domain/entities/user.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheTokens(AuthTokensModel tokens);
  Future<AuthTokensModel?> getCachedTokens();
  Future<void> cacheUser(User user);
  Future<User?> getCachedUser();
  Future<void> clearAuth();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const _boxName = 'auth_cache';
  static const _userKey = 'cached_user';
  static const _tokensKey = 'cached_tokens';

  final SecureStorage _secureStorage;

  AuthLocalDataSourceImpl(this._secureStorage);

  Box get _box => Hive.box(_boxName);

  static Future<void> openBox() async {
    if (Hive.isBoxOpen(_boxName)) return;
    try {
      await Hive.openBox(_boxName);
    } on FileSystemException {
      // Stale lock from a previous crash — delete it and retry once.
      final dir = await getApplicationSupportDirectory();
      final lock = File('${dir.path}/$_boxName.lock');
      if (await lock.exists()) await lock.delete();
      await Hive.openBox(_boxName);
    }
  }

  @override
  Future<void> cacheTokens(AuthTokensModel tokens) async {
    await _secureStorage.writeAccessToken(tokens.accessToken);
    await _secureStorage.writeRefreshToken(tokens.refreshToken);
    _box.put(_tokensKey, tokens.toJson());
  }

  @override
  Future<AuthTokensModel?> getCachedTokens() async {
    final access = await _secureStorage.readAccessToken();
    final refresh = await _secureStorage.readRefreshToken();
    if (access == null || refresh == null) return null;
    final raw = _box.get(_tokensKey) as Map?;
    if (raw != null) {
      return AuthTokensModel.fromJson(Map<String, dynamic>.from(raw));
    }
    return AuthTokensModel(
      accessToken: access,
      refreshToken: refresh,
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );
  }

  @override
  Future<void> cacheUser(User user) async {
    final map = _userToMap(user);
    _box.put(_userKey, map);
    await _secureStorage.writeUserId(user.id);
    await _secureStorage.writeUserType(_roleToString(user.role));
    if (user is AdminUser) {
      if (user.centerId != null) {
        await _secureStorage.writeCenterId(user.centerId!);
      }
    }
  }

  @override
  Future<User?> getCachedUser() async {
    final raw = _box.get(_userKey) as Map?;
    if (raw == null) return null;
    try {
      return UserModel.fromJson(Map<String, dynamic>.from(raw));
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearAuth() async {
    await _secureStorage.clearAll();
    await _box.delete(_userKey);
    await _box.delete(_tokensKey);
  }

  Map<String, dynamic> _userToMap(User user) {
    final base = <String, dynamic>{
      'sub': user.id,
      'id': user.id,
      'fullName': user.fullName,
      'email': user.email,
      'userType': _roleToString(user.role),
      'avatarUrl': user.avatarUrl,
    };
    if (user is DoctorUser) {
      base['badgeNumber'] = user.badgeNumber;
      base['specialization'] = user.specialization;
    }
    if (user is AdminUser) {
      base['centerId'] = user.centerId;
      base['centerName'] = user.centerName;
      base['centerStatus'] = user.centerStatus;
    }
    return base;
  }

  String _roleToString(UserRole role) => switch (role) {
        UserRole.doctor => 'Doctor',
        UserRole.admin => 'Admin',
        UserRole.superAdmin => 'SuperAdmin',
      };
}
