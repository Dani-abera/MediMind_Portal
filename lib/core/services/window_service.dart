import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

class WindowService with WindowListener {
  static const _prefX = 'window_x';
  static const _prefY = 'window_y';
  static const _prefW = 'window_w';
  static const _prefH = 'window_h';

  static const Size _minSize = Size(1280, 720);
  static const Size _defaultSize = Size(1440, 900);

  final SharedPreferences _prefs;

  WindowService(this._prefs);

  Future<void> initialize() async {
    if (!_isDesktop) return;

    await windowManager.ensureInitialized();
    windowManager.addListener(this);

    final savedSize = _loadSize();
    final savedOffset = _loadOffset();

    final options = WindowOptions(
      minimumSize: _minSize,
      size: savedSize ?? _defaultSize,
      center: savedOffset == null,
      title: 'MediMind Portal',
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );

    await windowManager.waitUntilReadyToShow(options, () async {
      if (savedOffset != null) {
        await windowManager.setPosition(savedOffset);
      }
      await windowManager.show();
      await windowManager.focus();
    });
  }

  @override
  void onWindowResized() => _saveWindowState();

  @override
  void onWindowMoved() => _saveWindowState();

  @override
  void onWindowClose() {
    _saveWindowState();
  }

  Future<void> _saveWindowState() async {
    if (!_isDesktop) return;
    try {
      final size = await windowManager.getSize();
      final offset = await windowManager.getPosition();
      await _prefs.setDouble(_prefW, size.width);
      await _prefs.setDouble(_prefH, size.height);
      await _prefs.setDouble(_prefX, offset.dx);
      await _prefs.setDouble(_prefY, offset.dy);
    } catch (_) {}
  }

  Size? _loadSize() {
    final w = _prefs.getDouble(_prefW);
    final h = _prefs.getDouble(_prefH);
    if (w == null || h == null) return null;
    return Size(w.clamp(_minSize.width, 9999), h.clamp(_minSize.height, 9999));
  }

  Offset? _loadOffset() {
    final x = _prefs.getDouble(_prefX);
    final y = _prefs.getDouble(_prefY);
    if (x == null || y == null) return null;
    return Offset(x, y);
  }

  bool get _isDesktop =>
      Platform.isWindows || Platform.isMacOS || Platform.isLinux;
}
