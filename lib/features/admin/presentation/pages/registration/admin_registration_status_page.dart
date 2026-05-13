import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/routing/route_names.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../auth/presentation/bloc/auth_event.dart';
import '../../../../auth/presentation/bloc/auth_state.dart';

enum _StatusType { pending, rejected, suspended }

class AdminRegistrationStatusPage extends StatelessWidget {
  final String title;
  final String message;
  final bool showRegisterButton;

  const AdminRegistrationStatusPage({
    super.key,
    required this.title,
    required this.message,
    this.showRegisterButton = false,
  });

  _StatusType get _type {
    final t = title.toLowerCase();
    if (t.contains('reject')) return _StatusType.rejected;
    if (t.contains('suspend')) return _StatusType.suspended;
    return _StatusType.pending;
  }

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (_type) {
      _StatusType.pending => (Icons.access_time_rounded, AppColors.warning),
      _StatusType.rejected => (Icons.cancel_outlined, AppColors.danger),
      _StatusType.suspended => (Icons.lock_outline_rounded, AppColors.neutral500),
    };

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) context.go(RouteNames.login);
      },
      builder: (context, authState) {
        return Stack(
          children: [
            Scaffold(
              backgroundColor: AppColors.background,
              body: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 440),
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(36),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(12),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color.withAlpha(20),
                        ),
                        child: Icon(icon, size: 36, color: color),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        title,
                        style: AppTypography.h3.copyWith(
                            color: AppColors.neutral800),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        message,
                        style: AppTypography.body.copyWith(
                            color: AppColors.neutral500),
                        textAlign: TextAlign.center,
                      ),
                      if (_type == _StatusType.pending) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withAlpha(15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: AppColors.warning.withAlpha(60)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline,
                                  color: AppColors.warning, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'You will receive a notification once your center is approved.',
                                  style: AppTypography.caption.copyWith(
                                      color: AppColors.neutral700),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (_type == _StatusType.rejected) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.danger.withAlpha(12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: AppColors.danger.withAlpha(50)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.mail_outline,
                                  color: AppColors.danger, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'For appeals or re-registration, contact support@medimind.et',
                                  style: AppTypography.caption.copyWith(
                                      color: AppColors.neutral700),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 28),
                      if (showRegisterButton) ...[
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () =>
                                context.go(RouteNames.adminRegisterCenter),
                            child: const Text('Register Healthcare Center'),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.logout, size: 16),
                          label: const Text('Sign Out'),
                          onPressed: () => context
                              .read<AuthBloc>()
                              .add(const AuthLogoutRequested()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (authState is AuthLoading)
              Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      },
    );
  }
}
