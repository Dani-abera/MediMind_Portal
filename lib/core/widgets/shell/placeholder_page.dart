import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import 'page_header.dart';

class ShellPlaceholderPage extends StatelessWidget {
  final String title;
  final String? subtitle;

  const ShellPlaceholderPage({
    super.key,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(title: title, subtitle: subtitle),
        Expanded(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 360),
              padding: const EdgeInsets.all(AppSpacing.xl2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.neutral200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(8),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withAlpha(80),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: FaIcon(
                        FontAwesomeIcons.hammer,
                        size: 22,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Coming in Next Prompt',
                    style: AppTypography.h2.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This page is scaffolded and ready for implementation.',
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.neutral500),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
