import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

enum PasswordStrength { empty, weak, fair, strong, veryStrong }

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({super.key, required this.password});

  static PasswordStrength evaluate(String password) {
    if (password.isEmpty) return PasswordStrength.empty;
    int score = 0;
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) score++;
    return switch (score) {
      0 || 1 => PasswordStrength.weak,
      2 => PasswordStrength.fair,
      3 => PasswordStrength.strong,
      _ => PasswordStrength.veryStrong,
    };
  }

  @override
  Widget build(BuildContext context) {
    final strength = evaluate(password);
    if (strength == PasswordStrength.empty) return const SizedBox.shrink();

    final (label, color, filled) = switch (strength) {
      PasswordStrength.weak => ('Weak', AppColors.danger, 1),
      PasswordStrength.fair => ('Fair', AppColors.warning, 2),
      PasswordStrength.strong => ('Strong', AppColors.info, 3),
      PasswordStrength.veryStrong => ('Very Strong', AppColors.success, 4),
      PasswordStrength.empty => ('', AppColors.neutral300, 0),
    };

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(4, (i) {
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                  decoration: BoxDecoration(
                    color: i < filled ? color : AppColors.neutral200,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: AppTypography.caption.copyWith(color: color)),
        ],
      ),
    );
  }
}
