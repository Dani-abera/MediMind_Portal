import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../storage/preferences_storage.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final PreferencesStorage _prefs;

  ThemeCubit(this._prefs)
      : super(_prefs.getThemeMode() == 'dark' ? ThemeMode.dark : ThemeMode.light);

  void toggle() {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    _prefs.setThemeMode(next.name);
    emit(next);
  }
}
