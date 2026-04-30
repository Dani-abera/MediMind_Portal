import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_typography.dart';

enum _ButtonVariant { primary, secondary, text, danger, icon }

class AppButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final _ButtonVariant _variant;

  const AppButton.primary({
    super.key,
    required String this.label,
    this.icon,
    this.onPressed,
    this.isLoading = false,
  }) : _variant = _ButtonVariant.primary;

  const AppButton.secondary({
    super.key,
    required String this.label,
    this.icon,
    this.onPressed,
    this.isLoading = false,
  }) : _variant = _ButtonVariant.secondary;

  const AppButton.text({
    super.key,
    required String this.label,
    this.icon,
    this.onPressed,
    this.isLoading = false,
  }) : _variant = _ButtonVariant.text;

  const AppButton.danger({
    super.key,
    required String this.label,
    this.icon,
    this.onPressed,
    this.isLoading = false,
  }) : _variant = _ButtonVariant.danger;

  const AppButton.icon({
    super.key,
    required IconData this.icon,
    this.onPressed,
    this.isLoading = false,
  })  : _variant = _ButtonVariant.icon,
        label = null;

  @override
  Widget build(BuildContext context) {
    switch (_variant) {
      case _ButtonVariant.primary:
        return _ElevatedBtn(
          label: label!,
          icon: icon,
          onPressed: isLoading ? null : onPressed,
          isLoading: isLoading,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          hoverColor: AppColors.primaryHover,
        );
      case _ButtonVariant.secondary:
        return _OutlinedBtn(
          label: label!,
          icon: icon,
          onPressed: isLoading ? null : onPressed,
          isLoading: isLoading,
        );
      case _ButtonVariant.text:
        return _TextBtn(
          label: label!,
          icon: icon,
          onPressed: isLoading ? null : onPressed,
          isLoading: isLoading,
        );
      case _ButtonVariant.danger:
        return _ElevatedBtn(
          label: label!,
          icon: icon,
          onPressed: isLoading ? null : onPressed,
          isLoading: isLoading,
          backgroundColor: AppColors.danger,
          foregroundColor: Colors.white,
          hoverColor: AppColors.danger.withAlpha(200),
        );
      case _ButtonVariant.icon:
        return IconButton(
          icon: isLoading
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : FaIcon(icon!, size: 15),
          onPressed: isLoading ? null : onPressed,
          visualDensity: VisualDensity.compact,
        );
    }
  }
}

class _ElevatedBtn extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color hoverColor;

  const _ElevatedBtn({
    required this.label,
    this.icon,
    this.onPressed,
    required this.isLoading,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.hoverColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          overlayColor: hoverColor,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: isLoading
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    FaIcon(icon!, size: 13),
                    const SizedBox(width: 6),
                  ],
                  Text(label,
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: foregroundColor,
                      )),
                ],
              ),
      ),
    );
  }
}

class _OutlinedBtn extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _OutlinedBtn({
    required this.label,
    this.icon,
    this.onPressed,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          shape:
              const RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          side: BorderSide(color: AppColors.primary),
        ),
        onPressed: onPressed,
        child: isLoading
            ? SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.primary))
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    FaIcon(icon!, size: 13, color: AppColors.primary),
                    const SizedBox(width: 6),
                  ],
                  Text(label,
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      )),
                ],
              ),
      ),
    );
  }
}

class _TextBtn extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _TextBtn({
    required this.label,
    this.icon,
    this.onPressed,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: TextButton(
        style: TextButton.styleFrom(
          shape:
              const RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
        onPressed: onPressed,
        child: isLoading
            ? SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.primary))
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    FaIcon(icon!, size: 13, color: AppColors.primary),
                    const SizedBox(width: 6),
                  ],
                  Text(label,
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      )),
                ],
              ),
      ),
    );
  }
}
