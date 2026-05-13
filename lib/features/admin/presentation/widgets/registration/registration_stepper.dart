import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';

class RegistrationStepper extends StatelessWidget {
  final int currentStep;
  final List<String> labels;

  const RegistrationStepper({
    super.key,
    required this.currentStep,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(labels.length, (i) {
        final isDone = i < currentStep;
        final isActive = i == currentStep;
        return Expanded(
          child: Row(
            children: [
              _StepCircle(index: i, isDone: isDone, isActive: isActive),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Step ${i + 1}',
                      style: AppTypography.caption.copyWith(
                        color: isActive
                            ? AppColors.primary
                            : isDone
                                ? AppColors.neutral500
                                : AppColors.neutral400,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      labels[i],
                      style: AppTypography.caption.copyWith(
                        color: isActive
                            ? AppColors.neutral900
                            : isDone
                                ? AppColors.neutral600
                                : AppColors.neutral400,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (i < labels.length - 1)
                Expanded(
                  child: Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    color: isDone ? AppColors.primary : AppColors.neutral200,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

class _StepCircle extends StatelessWidget {
  final int index;
  final bool isDone;
  final bool isActive;

  const _StepCircle({
    required this.index,
    required this.isDone,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDone
            ? AppColors.primary
            : isActive
                ? AppColors.primary
                : AppColors.neutral200,
        border: isActive && !isDone
            ? null
            : null,
      ),
      child: Center(
        child: isDone
            ? const Icon(Icons.check, size: 14, color: Colors.white)
            : Text(
                '${index + 1}',
                style: TextStyle(
                  color: isActive ? Colors.white : AppColors.neutral500,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
