import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class AppLoadingSpinner extends StatelessWidget {
  final double size;
  const AppLoadingSpinner({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        color: AppColors.primary,
      ),
    );
  }
}

class AppShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const AppShimmerBox({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.radius = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.neutral200,
      highlightColor: AppColors.neutral50,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

class AppEmptyState extends StatelessWidget {
  final String message;
  final String? description;
  final Widget? action;
  final IconData? icon;

  const AppEmptyState({
    super.key,
    required this.message,
    this.description,
    this.action,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon ?? Icons.inbox_outlined,
            size: 56,
            color: AppColors.neutral300,
          ),
          const SizedBox(height: 16),
          Text(message,
              style: AppTypography.h3.copyWith(color: AppColors.neutral500)),
          if (description != null) ...[
            const SizedBox(height: 8),
            Text(description!,
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.neutral400),
                textAlign: TextAlign.center),
          ],
          if (action != null) ...[
            const SizedBox(height: 20),
            action!,
          ],
        ],
      ),
    );
  }
}

class AppErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const AppErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 56, color: AppColors.danger),
          const SizedBox(height: 16),
          Text('Something went wrong',
              style: AppTypography.h3.copyWith(color: AppColors.neutral700)),
          const SizedBox(height: 8),
          Text(message,
              style: AppTypography.bodySmall
                  .copyWith(color: AppColors.neutral400),
              textAlign: TextAlign.center),
          if (onRetry != null) ...[
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}
