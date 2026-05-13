import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../centers/domain/entities/subscription_plan.dart';

class SubscriptionPlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final bool isSelected;
  final VoidCallback onTap;

  const SubscriptionPlanCard({
    super.key,
    required this.plan,
    required this.isSelected,
    required this.onTap,
  });

  Color get _tierColor => switch (plan.tier.toString()) {
        '10' || 'Trial' => AppColors.neutral500,
        '20' || 'Basic' => AppColors.info,
        '30' || 'Standard' => AppColors.primary,
        '40' || 'Premium' => const Color(0xFF7B2FBE),
        _ => AppColors.neutral500,
      };

  String get _tierLabel => switch (plan.tier.toString()) {
        '10' => 'Trial',
        '20' => 'Basic',
        '30' => 'Standard',
        '40' => 'Premium',
        _ => plan.tier,
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withAlpha(8)
              : AppColors.surface,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.neutral200,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    plan.name,
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutral900,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _tierColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _tierLabel,
                    style: TextStyle(
                      fontSize: 10,
                      color: _tierColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.check_circle,
                      color: AppColors.primary, size: 18),
                ],
              ],
            ),
            const SizedBox(height: 8),
            plan.isFree
                ? Text(
                    'Free',
                    style: AppTypography.h3.copyWith(color: AppColors.success),
                  )
                : RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'ETB ${plan.monthlyPrice.toStringAsFixed(0)}',
                          style: AppTypography.h3
                              .copyWith(color: AppColors.neutral900),
                        ),
                        TextSpan(
                          text: '/mo',
                          style: AppTypography.caption
                              .copyWith(color: AppColors.neutral500),
                        ),
                      ],
                    ),
                  ),
            const SizedBox(height: 4),
            Text(
              plan.maxDoctors == 0
                  ? 'Unlimited doctors'
                  : 'Up to ${plan.maxDoctors} doctors',
              style: AppTypography.caption
                  .copyWith(color: AppColors.neutral500),
            ),
            const SizedBox(height: 10),
            ...plan.features.take(4).map(
                  (f) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check, size: 13, color: _tierColor),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(f,
                              style: AppTypography.caption
                                  .copyWith(color: AppColors.neutral600)),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
