import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class EnvBadge extends StatelessWidget {
  const EnvBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final env = dotenv.env['APP_ENV'] ?? dotenv.env['ENVIRONMENT'] ?? 'dev';
    final (label, color) = switch (env.toLowerCase()) {
      'production' || 'prod' => ('PROD', AppColors.danger),
      'staging' => ('STAGING', AppColors.warning),
      _ => ('DEV', AppColors.info),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 10,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
