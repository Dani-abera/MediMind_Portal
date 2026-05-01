import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'bloc/shell_event.dart';

class ConnectionStatusDot extends StatelessWidget {
  final AppConnectionStatus status;

  const ConnectionStatusDot({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, message) = switch (status) {
      AppConnectionStatus.connected => (AppColors.success, 'Real-time updates active'),
      AppConnectionStatus.reconnecting => (AppColors.warning, 'Reconnecting...'),
      AppConnectionStatus.offline => (AppColors.neutral300, 'Offline mode'),
    };

    return Tooltip(
      message: message,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: status == AppConnectionStatus.connected
              ? [BoxShadow(color: AppColors.success.withAlpha(100), blurRadius: 4)]
              : null,
        ),
      ),
    );
  }
}
