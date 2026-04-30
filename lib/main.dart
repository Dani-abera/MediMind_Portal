import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'app.dart';
import 'bootstrap.dart';

Future<void> main() async {
  await bootstrap();
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('am')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const MediMindPortalApp(),
    ),
  );
}
