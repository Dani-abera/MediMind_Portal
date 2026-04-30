import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const String _accessToken = 'access_token';
  static const String _refreshToken = 'refresh_token';
  static const String _userId = 'user_id';
  static const String _userType = 'user_type';
  static const String _centerId = 'center_id';

  late final FlutterSecureStorage _storage;

  SecureStorage() {
    _storage = const FlutterSecureStorage(
      // macOS: Keychain, Windows: DPAPI, Linux: libsecret
      mOptions: MacOsOptions(
        accountName: 'MediMindPortal',
        synchronizable: false,
      ),
      lOptions: LinuxOptions(),
      wOptions: WindowsOptions(
        useBackwardCompatibility: false,
      ),
    );
  }

  Future<void> writeAccessToken(String token) =>
      _storage.write(key: _accessToken, value: token);

  Future<String?> readAccessToken() => _storage.read(key: _accessToken);

  Future<void> writeRefreshToken(String token) =>
      _storage.write(key: _refreshToken, value: token);

  Future<String?> readRefreshToken() => _storage.read(key: _refreshToken);

  Future<void> writeUserId(String id) =>
      _storage.write(key: _userId, value: id);

  Future<String?> readUserId() => _storage.read(key: _userId);

  Future<void> writeUserType(String type) =>
      _storage.write(key: _userType, value: type);

  Future<String?> readUserType() => _storage.read(key: _userType);

  Future<void> writeCenterId(String id) =>
      _storage.write(key: _centerId, value: id);

  Future<String?> readCenterId() => _storage.read(key: _centerId);

  Future<void> clearAll() => _storage.deleteAll();
}
