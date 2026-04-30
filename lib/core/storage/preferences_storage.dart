import 'package:shared_preferences/shared_preferences.dart';

class PreferencesStorage {
  final SharedPreferences _prefs;

  PreferencesStorage(this._prefs);

  // Theme
  static const _themeKey = 'theme_mode';
  Future<void> setThemeMode(String mode) => _prefs.setString(_themeKey, mode);
  String getThemeMode() => _prefs.getString(_themeKey) ?? 'light';

  // Locale
  static const _localeKey = 'locale';
  Future<void> setLocale(String locale) => _prefs.setString(_localeKey, locale);
  String getLocale() => _prefs.getString(_localeKey) ?? 'en';

  // Sidebar
  static const _sidebarKey = 'sidebar_collapsed';
  Future<void> setSidebarCollapsed(bool v) => _prefs.setBool(_sidebarKey, v);
  bool getSidebarCollapsed() => _prefs.getBool(_sidebarKey) ?? false;

  // Table density
  static const _densityKey = 'table_density';
  Future<void> setTableDensity(String d) => _prefs.setString(_densityKey, d);
  String getTableDensity() => _prefs.getString(_densityKey) ?? 'comfortable';

  // Page size
  static const _pageSizeKey = 'table_page_size';
  Future<void> setPageSize(int size) => _prefs.setInt(_pageSizeKey, size);
  int getPageSize() => _prefs.getInt(_pageSizeKey) ?? 20;

  Future<void> clear() => _prefs.clear();
}
