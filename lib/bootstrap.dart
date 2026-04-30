import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'core/di/service_locator.dart';
import 'core/services/window_service.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load env
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // .env not found — use defaults
  }

  // Hive with platform-appropriate path
  final hivePath = await _getHivePath();
  await Hive.initFlutter(hivePath);

  // Easy localization
  await EasyLocalization.ensureInitialized();

  // Core DI
  await initCoreDependencies();

  // Window manager (desktop only)
  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    await sl<WindowService>().initialize();
  }

  // Sentry (release mode)
  const dsn = String.fromEnvironment('SENTRY_DSN');
  if (dsn.isNotEmpty) {
    await SentryFlutter.init(
      (options) {
        options.dsn = dsn;
        options.tracesSampleRate = 0.2;
      },
    );
  }
}

Future<String> _getHivePath() async {
  if (Platform.isWindows) {
    final appData = Platform.environment['APPDATA'];
    if (appData != null) return '$appData\\MediMindPortal';
  } else if (Platform.isMacOS) {
    final home = Platform.environment['HOME'];
    if (home != null) return '$home/Library/Application Support/MediMindPortal';
  } else if (Platform.isLinux) {
    final home = Platform.environment['HOME'];
    if (home != null) return '$home/.config/medimind_portal';
  }
  final dir = await getApplicationSupportDirectory();
  return dir.path;
}
