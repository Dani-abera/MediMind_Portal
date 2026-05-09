import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'app.dart';
import 'bootstrap.dart';

void main() {
  runZonedGuarded(
    () async {
      await bootstrap();
      runApp(
        EasyLocalization(
          supportedLocales: const [Locale('en'), Locale('am')],
          path: 'assets/translations',
          fallbackLocale: const Locale('en'),
          child: const MediMindPortalApp(),
        ),
      );
    },
    (error, stack) {
      Sentry.captureException(error, stackTrace: stack);
      debugPrint('[UNHANDLED] $error\n$stack');
    },
  );
}
