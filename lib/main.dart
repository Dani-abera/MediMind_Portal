import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'app.dart';
import 'bootstrap.dart';

Future<void> main() async {
  await bootstrap();

  runZonedGuarded(
    () => runApp(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('am')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        child: const MediMindPortalApp(),
      ),
    ),
    (error, stack) {
      Sentry.captureException(error, stackTrace: stack);
      debugPrint('[UNHANDLED] $error\n$stack');
    },
  );
}
