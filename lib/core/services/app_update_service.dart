import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';

enum UpdateStatus { upToDate, updateAvailable, forceUpdate }

class AppVersionInfo {
  final String current;
  final String latest;
  final String minSupported;
  final String? downloadUrl;

  const AppVersionInfo({
    required this.current,
    required this.latest,
    required this.minSupported,
    this.downloadUrl,
  });

  UpdateStatus get status {
    if (_isLessThan(current, minSupported)) return UpdateStatus.forceUpdate;
    if (_isLessThan(current, latest)) return UpdateStatus.updateAvailable;
    return UpdateStatus.upToDate;
  }

  static bool _isLessThan(String a, String b) {
    final av = _parse(a);
    final bv = _parse(b);
    for (var i = 0; i < 3; i++) {
      final ai = i < av.length ? av[i] : 0;
      final bi = i < bv.length ? bv[i] : 0;
      if (ai < bi) return true;
      if (ai > bi) return false;
    }
    return false;
  }

  static List<int> _parse(String v) {
    return v.split('.').map((s) => int.tryParse(s) ?? 0).toList();
  }
}

class AppUpdateService {
  final Dio _dio;
  final String _baseUrl;

  AppUpdateService({required Dio dio, required String baseUrl})
      : _dio = dio,
        _baseUrl = baseUrl;

  Future<AppVersionInfo?> checkForUpdate() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final response = await _dio.get('$_baseUrl/api/v1/system/version');
      final data = response.data as Map<String, dynamic>;
      return AppVersionInfo(
        current: info.version,
        latest: data['latest'] as String,
        minSupported: data['minSupported'] as String,
        downloadUrl: data['downloadUrl'] as String?,
      );
    } catch (_) {
      return null;
    }
  }
}
