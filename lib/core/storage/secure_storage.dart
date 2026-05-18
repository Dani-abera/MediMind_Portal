import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

// macOS Keychain requires a real Apple Team ID (fails with ad-hoc signing).
// We use a Hive box on macOS instead — data lives in the app's sandboxed
// support directory which macOS protects from other apps.
class SecureStorage {
  static const _boxName = 'secure_store';
  static const _accessToken = 'access_token';
  static const _refreshToken = 'refresh_token';
  static const _userId = 'user_id';
  static const _userType = 'user_type';
  static const _centerId = 'center_id';

  static final bool _usesHive = Platform.isMacOS;

  FlutterSecureStorage? _fss;
  Box? _box;

  Future<void> init() async {
    if (_usesHive) {
      _box = await Hive.openBox(_boxName);
    } else {
      _fss = const FlutterSecureStorage(
        lOptions: LinuxOptions(),
        wOptions: WindowsOptions(useBackwardCompatibility: false),
      );
    }
  }

  Future<void> _write(String key, String value) {
    return _usesHive
        ? _box!.put(key, value)
        : _fss!.write(key: key, value: value);
  }

  Future<String?> _read(String key) async {
    if (_usesHive) return _box!.get(key) as String?;
    return _fss!.read(key: key);
  }

Future<void> writeAccessToken(String token) => _write(_accessToken, token);
  Future<String?> readAccessToken() => _read(_accessToken);

  Future<void> writeRefreshToken(String token) => _write(_refreshToken, token);
  Future<String?> readRefreshToken() => _read(_refreshToken);

  Future<void> writeUserId(String id) => _write(_userId, id);
  Future<String?> readUserId() => _read(_userId);

  Future<void> writeUserType(String type) => _write(_userType, type);
  Future<String?> readUserType() => _read(_userType);

  Future<void> writeCenterId(String id) => _write(_centerId, id);
  Future<String?> readCenterId() => _read(_centerId);

  Future<void> clearAll() {
    return _usesHive ? _box!.clear() : _fss!.deleteAll();
  }
}
