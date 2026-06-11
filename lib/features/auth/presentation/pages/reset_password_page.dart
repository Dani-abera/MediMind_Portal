import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medimind_portal/core/utils/fa_compat.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../bloc/reset_password/reset_password_bloc.dart';
import '../widgets/password_strength_indicator.dart';

class ResetPasswordPage extends StatelessWidget {
  final String? token;
  const ResetPasswordPage({super.key, this.token});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ResetPasswordBloc>(),
      child: _ResetPasswordView(token: token),
    );
  }
}

class _ResetPasswordView extends StatefulWidget {
  final String? token;
  const _ResetPasswordView({this.token});

  @override
  State<_ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<_ResetPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final token = widget.token;
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid or missing reset token.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }
    context.read<ResetPasswordBloc>().add(
          ResetPasswordSubmitted(
            token: token,
            newPassword: _newPassCtrl.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLogo(),
                const SizedBox(height: 32),
                _buildCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
            child: Icon(FontAwesomeIcons.heartPulse,
                color: Colors.white, size: 18),
          ),
        ),
        const SizedBox(width: 10),
        Text('MediMind Portal',
            style: AppTypography.h2.copyWith(color: AppColors.neutral900)),
      ],
    );
  }

  Widget _buildCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: AppColors.neutral200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: BlocConsumer<ResetPasswordBloc, ResetPasswordState>(
        listener: (context, state) {
          if (state is ResetPasswordError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.danger,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ResetPasswordSuccess) return _buildSuccessState(context);
          if (widget.token == null || widget.token!.isEmpty) {
            return _buildInvalidTokenState(context);
          }
          return _buildFormState(context, state);
        },
      ),
    );
  }

  Widget _buildFormState(BuildContext context, ResetPasswordState state) {
    final isLoading = state is ResetPasswordLoading;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Set new password',
              style: AppTypography.h2.copyWith(color: AppColors.neutral900)),
          const SizedBox(height: 6),
          Text(
            'Choose a strong password for your account.',
            style: AppTypography.bodySmall.copyWith(color: AppColors.neutral500),
          ),
          const SizedBox(height: 24),
          // New password
          ValueListenableBuilder(
            valueListenable: _newPassCtrl,
            builder: (_, __, ___) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _newPassCtrl,
                  autofocus: true,
                  obscureText: _obscureNew,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    prefixIcon: const Icon(Icons.lock_outlined, size: 18),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNew
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 18,
                      ),
                      onPressed: () =>
                          setState(() => _obscureNew = !_obscureNew),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 8) return 'At least 8 characters required';
                    return null;
                  },
                ),
                PasswordStrengthIndicator(password: _newPassCtrl.text),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Confirm password
          TextFormField(
            controller: _confirmPassCtrl,
            obscureText: _obscureConfirm,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: 'Confirm New Password',
              prefixIcon: const Icon(Icons.lock_outlined, size: 18),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 18,
                ),
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please confirm your password';
              if (v != _newPassCtrl.text) return 'Passwords do not match';
              return null;
            },
            onFieldSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: isLoading ? null : _submit,
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white),
                    )
                  : const Text('Reset Password'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.success.withAlpha(20),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(FontAwesomeIcons.circleCheck,
                color: AppColors.success, size: 24),
          ),
        ),
        const SizedBox(height: 16),
        Text('Password reset!',
            style: AppTypography.h2.copyWith(color: AppColors.neutral900)),
        const SizedBox(height: 8),
        Text(
          'Your password has been updated. You can now sign in with your new password.',
          textAlign: TextAlign.center,
          style: AppTypography.bodySmall.copyWith(color: AppColors.neutral500),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 40,
          child: ElevatedButton(
            onPressed: () => context.go(RouteNames.login),
            child: const Text('Go to Login'),
          ),
        ),
      ],
    );
  }

  Widget _buildInvalidTokenState(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.danger.withAlpha(20),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(FontAwesomeIcons.triangleExclamation,
                color: AppColors.danger, size: 24),
          ),
        ),
        const SizedBox(height: 16),
        Text('Invalid Link',
            style: AppTypography.h2.copyWith(color: AppColors.neutral900)),
        const SizedBox(height: 8),
        Text(
          'This password reset link is invalid or has expired. '
          'Please request a new one.',
          textAlign: TextAlign.center,
          style: AppTypography.bodySmall.copyWith(color: AppColors.neutral500),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 40,
          child: ElevatedButton(
            onPressed: () => context.go(RouteNames.forgotPassword),
            child: const Text('Request New Link'),
          ),
        ),
      ],
    );
  }
}
