import 'dart:async';
import 'package:flutter/material.dart';

typedef InactivityCallback = void Function();

/// Wraps the app to detect user inactivity and call [onTimeout].
/// Reset the timer by calling [resetTimer] or via the [InactivityDetector] widget.
class InactivityService {
  static final InactivityService _instance = InactivityService._();
  factory InactivityService() => _instance;
  InactivityService._();

  Duration _timeout = const Duration(minutes: 30);
  Timer? _timer;
  InactivityCallback? _onTimeout;

  void configure({
    required Duration timeout,
    required InactivityCallback onTimeout,
  }) {
    _timeout = timeout;
    _onTimeout = onTimeout;
    resetTimer();
  }

  void resetTimer() {
    _timer?.cancel();
    if (_onTimeout != null) {
      _timer = Timer(_timeout, () => _onTimeout?.call());
    }
  }

  void dispose() {
    _timer?.cancel();
    _onTimeout = null;
  }
}

/// Wrap the workspace shell with this to reset the inactivity timer
/// on any pointer or key event.
class InactivityDetector extends StatelessWidget {
  final Widget child;

  const InactivityDetector({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => InactivityService().resetTimer(),
      onPointerMove: (_) => InactivityService().resetTimer(),
      child: KeyboardListener(
        focusNode: FocusNode(skipTraversal: true),
        onKeyEvent: (_) => InactivityService().resetTimer(),
        child: child,
      ),
    );
  }
}
