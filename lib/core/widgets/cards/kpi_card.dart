import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_typography.dart';

enum TrendDirection { up, down, neutral }

class KPICard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? trend;
  final TrendDirection trendDirection;
  final Widget? sparkline;

  const KPICard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.trend,
    this.trendDirection = TrendDirection.neutral,
    this.sparkline,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.radiusBase,
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withAlpha(80),
                  borderRadius: AppRadius.radiusMd,
                ),
                child: Center(
                  child: FaIcon(icon, size: 16, color: AppColors.primary),
                ),
              ),
              const Spacer(),
              if (trend != null) _trendBadge(),
            ],
          ),
          const SizedBox(height: 12),
          Text(value,
              style: AppTypography.display.copyWith(
                color: colors.onSurface,
                fontSize: 24,
              )),
          const SizedBox(height: 4),
          Text(title,
              style: AppTypography.caption.copyWith(
                color: AppColors.neutral500,
              )),
          if (sparkline != null) ...[
            const SizedBox(height: 12),
            SizedBox(height: 40, child: sparkline!),
          ],
        ],
      ),
    );
  }

  Widget _trendBadge() {
    Color color;
    IconData arrow;
    switch (trendDirection) {
      case TrendDirection.up:
        color = AppColors.success;
        arrow = FontAwesomeIcons.arrowTrendUp;
      case TrendDirection.down:
        color = AppColors.danger;
        arrow = FontAwesomeIcons.arrowTrendDown;
      case TrendDirection.neutral:
        color = AppColors.neutral500;
        arrow = FontAwesomeIcons.minus;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: AppRadius.radiusSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(arrow, size: 10, color: color),
          const SizedBox(width: 4),
          Text(trend!,
              style: AppTypography.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }
}
