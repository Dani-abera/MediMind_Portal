import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_typography.dart';

enum BadgeStatus {
  pending,
  confirmed,
  cancelled,
  completed,
  noShow,
  inProgress,
  active,
  suspended,
  trial,
  expired,
  verified,
  unverified,
}

class StatusBadge extends StatelessWidget {
  final String label;
  final BadgeStatus status;

  const StatusBadge({super.key, required this.label, required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _configs[status]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: config.bg,
        borderRadius: AppRadius.radiusFull,
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: config.text,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  static final Map<BadgeStatus, _BadgeConfig> _configs = {
    BadgeStatus.pending: _BadgeConfig(
        bg: AppColors.warning.withAlpha(20), text: AppColors.warning),
    BadgeStatus.confirmed: _BadgeConfig(
        bg: AppColors.info.withAlpha(20), text: AppColors.info),
    BadgeStatus.cancelled: _BadgeConfig(
        bg: AppColors.danger.withAlpha(20), text: AppColors.danger),
    BadgeStatus.completed: _BadgeConfig(
        bg: AppColors.success.withAlpha(20), text: AppColors.success),
    BadgeStatus.noShow: _BadgeConfig(
        bg: AppColors.neutral300, text: AppColors.neutral600),
    BadgeStatus.inProgress: _BadgeConfig(
        bg: AppColors.info.withAlpha(20), text: AppColors.info),
    BadgeStatus.active: _BadgeConfig(
        bg: AppColors.success.withAlpha(20), text: AppColors.success),
    BadgeStatus.suspended: _BadgeConfig(
        bg: AppColors.danger.withAlpha(20), text: AppColors.danger),
    BadgeStatus.trial: _BadgeConfig(
        bg: AppColors.accent.withAlpha(20), text: AppColors.accent),
    BadgeStatus.expired: _BadgeConfig(
        bg: AppColors.neutral200, text: AppColors.neutral500),
    BadgeStatus.verified: _BadgeConfig(
        bg: AppColors.success.withAlpha(20), text: AppColors.success),
    BadgeStatus.unverified: _BadgeConfig(
        bg: AppColors.warning.withAlpha(20), text: AppColors.warning),
  };
}

class _BadgeConfig {
  final Color bg;
  final Color text;
  const _BadgeConfig({required this.bg, required this.text});
}
