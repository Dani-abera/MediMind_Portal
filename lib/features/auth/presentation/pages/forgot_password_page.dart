import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medimind_portal/core/utils/fa_compat.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../bloc/forgot_password/forgot_password_bloc.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ForgotPasswordBloc>(),
      child: const _ForgotPasswordView(),
    );
  }
}

class _ForgotPasswordView extends StatefulWidget {
  const _ForgotPasswordView();

  @override
  State<_ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<_ForgotPasswordView> {
  final _emailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context
        .read<ForgotPasswordBloc>()
        .add(ForgotPasswordSubmitted(_emailCtrl.text.trim()));
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
      child: BlocConsumer<ForgotPasswordBloc, ForgotPasswordState>(
        listener: (context, state) {
          if (state is ForgotPasswordError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.danger,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ForgotPasswordSuccess) {
            return _buildSuccessState();
          }
          return _buildFormState(context, state);
        },
      ),
    );
  }

  Widget _buildFormState(BuildContext context, ForgotPasswordState state) {
    final isLoading = state is ForgotPasswordLoading;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reset your password',
              style: AppTypography.h2.copyWith(color: AppColors.neutral900)),
          const SizedBox(height: 6),
          Text(
            "Enter your email and we'll send you a reset link.",
            style: AppTypography.bodySmall.copyWith(color: AppColors.neutral500),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _emailCtrl,
            autofocus: true,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'doctor@medimind.et',
              prefixIcon: Icon(Icons.email_outlined, size: 18),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email is required';
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v.trim())) {
                return 'Enter a valid email';
              }
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
                  : const Text('Send Reset Link'),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () => context.go(RouteNames.login),
              child: Text('Back to login',
                  style: AppTypography.caption
                      .copyWith(color: AppColors.primary)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState() {
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
            child: Icon(FontAwesomeIcons.envelopeCircleCheck,
                color: AppColors.success, size: 24),
          ),
        ),
        const SizedBox(height: 16),
        Text('Check your inbox',
            style: AppTypography.h2.copyWith(color: AppColors.neutral900)),
        const SizedBox(height: 8),
        Text(
          "We sent a password reset link to ${_emailCtrl.text.trim()}. "
          "It will expire in 30 minutes.",
          textAlign: TextAlign.center,
          style: AppTypography.bodySmall.copyWith(color: AppColors.neutral500),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 40,
          child: OutlinedButton(
            onPressed: () {
              context
                  .read<ForgotPasswordBloc>()
                  .add(const ForgotPasswordReset());
            },
            child: const Text('Send again'),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Builder(
            builder: (context) => TextButton(
              onPressed: () => context.go(RouteNames.login),
              child: Text('Back to login',
                  style: AppTypography.caption
                      .copyWith(color: AppColors.primary)),
            ),
          ),
        ),
      ],
    );
  }
}
