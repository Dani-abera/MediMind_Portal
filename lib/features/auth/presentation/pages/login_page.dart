import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../bloc/doctor_login/doctor_login_bloc.dart';
import '../bloc/doctor_login/doctor_login_event.dart';
import '../bloc/doctor_login/doctor_login_state.dart';
import '../bloc/admin_login/admin_login_bloc.dart';
import '../bloc/admin_login/admin_login_event.dart';
import '../bloc/admin_login/admin_login_state.dart';
import '../bloc/super_admin_login/super_admin_login_bloc.dart';
import '../bloc/super_admin_login/super_admin_login_event.dart';
import '../bloc/super_admin_login/super_admin_login_state.dart';
import '../cubit/account_lockout_cubit.dart';
import '../cubit/admin_register_cubit.dart';
import '../../domain/entities/user.dart';

enum _LoginTab { doctor, admin, superAdmin }

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<DoctorLoginBloc>()),
        BlocProvider(create: (_) => sl<AdminLoginBloc>()),
        BlocProvider(create: (_) => sl<SuperAdminLoginBloc>()),
        BlocProvider(create: (_) => sl<AdminRegisterCubit>()),
        BlocProvider.value(value: sl<AccountLockoutCubit>()),
      ],
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  _LoginTab _activeTab = _LoginTab.doctor;

  void _onLoginSuccess(BuildContext context, User user, dynamic tokens) {
    context.read<AuthBloc>().add(AuthUserLoggedIn(user: user, tokens: tokens));
  }

  void _navigate(BuildContext context, AuthState state) {
    if (state is! AuthAuthenticated) return;
    switch (state.user.role) {
      case UserRole.doctor:
        context.go(RouteNames.doctorDashboard);
      case UserRole.admin:
        context.go(RouteNames.adminDashboard);
      case UserRole.superAdmin:
        context.go(RouteNames.superAdminDashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) => _navigate(context, state),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Row(
          children: [
            // Left branding panel (45%)
            Expanded(
              flex: 45,
              child: _BrandingPanel(),
            ),
            // Right form panel (55%)
            Expanded(
              flex: 55,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(40),
                  child: SizedBox(
                    width: 420,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 24),
                        _buildTabSelector(),
                        const SizedBox(height: 24),
                        _buildForm(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Welcome back',
            style: AppTypography.h1.copyWith(color: AppColors.neutral900)),
        const SizedBox(height: 4),
        Text('Sign in to your staff account',
            style: AppTypography.body.copyWith(color: AppColors.neutral500)),
      ],
    );
  }

  Widget _buildTabSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: AppRadius.radiusMd,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: _LoginTab.values.map((tab) {
          final isActive = _activeTab == tab;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _activeTab = tab),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? Colors.white : Colors.transparent,
                  borderRadius: AppRadius.radiusSm,
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: Colors.black.withAlpha(15),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          )
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    _tabLabel(tab),
                    style: AppTypography.bodySmall.copyWith(
                      color: isActive
                          ? AppColors.primary
                          : AppColors.neutral500,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _tabLabel(_LoginTab tab) => switch (tab) {
        _LoginTab.doctor => 'Doctor',
        _LoginTab.admin => 'Admin',
        _LoginTab.superAdmin => 'Super Admin',
      };

  Widget _buildForm() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: switch (_activeTab) {
        _LoginTab.doctor => _DoctorLoginForm(
            key: const ValueKey('doctor'),
            onSuccess: (user, tokens) => _onLoginSuccess(context, user, tokens),
          ),
        _LoginTab.admin => _AdminLoginForm(
            key: const ValueKey('admin'),
            onSuccess: (user, tokens) => _onLoginSuccess(context, user, tokens),
          ),
        _LoginTab.superAdmin => _SuperAdminLoginForm(
            key: const ValueKey('superAdmin'),
            onSuccess: (user, tokens) => _onLoginSuccess(context, user, tokens),
          ),
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Branding panel
// ---------------------------------------------------------------------------

class _BrandingPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryHover],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Background decorative circles
          Positioned(
            top: -60,
            right: -60,
            child: _circle(200, Colors.white.withAlpha(15)),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: _circle(300, Colors.white.withAlpha(10)),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 64),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLogo(),
                const Spacer(),
                _buildTagline(),
                const SizedBox(height: 48),
                _buildFeatureBullets(),
                const Spacer(),
                _buildCopyright(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(30),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withAlpha(60), width: 1.5),
          ),
          child: const Center(
            child: FaIcon(FontAwesomeIcons.heartPulse,
                color: Colors.white, size: 22),
          ),
        ),
        const SizedBox(width: 14),
        const Text(
          'MediMind',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTagline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Smarter care,\nbetter outcomes.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w700,
            height: 1.25,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'The unified portal for healthcare professionals\nand administrators.',
          style: TextStyle(
            color: Colors.white.withAlpha(178),
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureBullets() {
    const features = [
      (FontAwesomeIcons.calendarCheck, 'Appointment management & scheduling'),
      (FontAwesomeIcons.userDoctor, 'Patient records & medical history'),
      (FontAwesomeIcons.chartLine, 'Real-time analytics & reporting'),
      (FontAwesomeIcons.bell, 'Instant notifications & queue management'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: features.map((f) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: FaIcon(f.$1, color: Colors.white, size: 14),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                f.$2,
                style: TextStyle(
                  color: Colors.white.withAlpha(204),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCopyright() {
    return Text(
      '© ${DateTime.now().year} MediMind. All rights reserved.',
      style: TextStyle(
        color: Colors.white.withAlpha(102),
        fontSize: 12,
      ),
    );
  }

  Widget _circle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

// ---------------------------------------------------------------------------
// Doctor login form (badge → OTP)
// ---------------------------------------------------------------------------

class _DoctorLoginForm extends StatefulWidget {
  final void Function(dynamic user, dynamic tokens) onSuccess;
  const _DoctorLoginForm({super.key, required this.onSuccess});

  @override
  State<_DoctorLoginForm> createState() => _DoctorLoginFormState();
}

class _DoctorLoginFormState extends State<_DoctorLoginForm> {
  final _badgeCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Timer? _countdownTimer;
  int _secondsLeft = 0;

  @override
  void dispose() {
    _badgeCtrl.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _secondsLeft = 60;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
        } else {
          t.cancel();
        }
      });
    });
  }

  void _requestOtp() {
    if (!_formKey.currentState!.validate()) return;
    final lockout = context.read<AccountLockoutCubit>();
    final id = 'doctor_${_badgeCtrl.text.trim()}';
    if (lockout.isLocked(id)) {
      _showLockoutSnackbar(lockout.lockedUntil(id)!);
      return;
    }
    context
        .read<DoctorLoginBloc>()
        .add(DoctorRequestOtp(_badgeCtrl.text.trim()));
  }

  void _showLockoutSnackbar(DateTime until) {
    final remaining = until.difference(DateTime.now());
    final mins = remaining.inMinutes + 1;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Account locked. Try again in $mins minute(s).'),
        backgroundColor: AppColors.danger,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DoctorLoginBloc, DoctorLoginState>(
      listener: (context, state) {
        if (state is DoctorLoginOtpSent) _startCountdown();
        if (state is DoctorLoginSuccess) {
          context.read<AccountLockoutCubit>().recordSuccess(
                'doctor_${state.user.id}',
              );
          widget.onSuccess(state.user, state.tokens);
        }
        if (state is DoctorLoginError) {
          final id = 'doctor_${_badgeCtrl.text.trim()}';
          context.read<AccountLockoutCubit>().recordFailure(id);
        }
      },
      builder: (context, state) {
        if (state is DoctorLoginOtpSent ||
            state is DoctorLoginVerifyingOtp) {
          return _buildOtpStep(context, state);
        }
        return _buildBadgeStep(context, state);
      },
    );
  }

  Widget _buildBadgeStep(BuildContext context, DoctorLoginState state) {
    final isLoading = state is DoctorLoginRequestingOtp;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _badgeCtrl,
            autofocus: true,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Badge / Staff ID',
              hintText: 'e.g. DR-2024-001',
              prefixIcon: Icon(Icons.badge_outlined, size: 18),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Badge number is required' : null,
            onFieldSubmitted: (_) => _requestOtp(),
          ),
          if (state is DoctorLoginError) ...[
            const SizedBox(height: 8),
            _ErrorText(state.message),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: isLoading ? null : _requestOtp,
              child: isLoading
                  ? _LoadingSpinner()
                  : const Text('Get OTP'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpStep(BuildContext context, DoctorLoginState state) {
    final badgeNumber = state is DoctorLoginOtpSent
        ? state.badgeNumber
        : _badgeCtrl.text.trim();
    final isVerifying = state is DoctorLoginVerifyingOtp;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, size: 18),
              onPressed: () => context
                  .read<DoctorLoginBloc>()
                  .add(const DoctorLoginReset()),
              tooltip: 'Back',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Enter the 6-digit OTP sent to your registered number',
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.neutral600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Center(
          child: Pinput(
            length: 6,
            autofocus: true,
            enabled: !isVerifying,
            defaultPinTheme: PinTheme(
              width: 52,
              height: 52,
              textStyle: AppTypography.h2
                  .copyWith(color: AppColors.neutral900),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.neutral300),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            focusedPinTheme: PinTheme(
              width: 52,
              height: 52,
              textStyle: AppTypography.h2
                  .copyWith(color: AppColors.neutral900),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onCompleted: isVerifying
                ? null
                : (otp) => context.read<DoctorLoginBloc>().add(
                      DoctorVerifyOtp(
                          badgeNumber: badgeNumber, otpCode: otp),
                    ),
          ),
        ),
        if (state is DoctorLoginVerifyingOtp) ...[
          const SizedBox(height: 16),
          const Center(child: _LoadingSpinner()),
        ],
        const SizedBox(height: 20),
        Center(
          child: _secondsLeft > 0
              ? Text(
                  'Resend in ${_secondsLeft}s',
                  style: AppTypography.caption
                      .copyWith(color: AppColors.neutral400),
                )
              : TextButton(
                  onPressed: () {
                    context
                        .read<DoctorLoginBloc>()
                        .add(DoctorOtpResendRequested(badgeNumber));
                    _startCountdown();
                  },
                  child: Text(
                    'Resend OTP',
                    style:
                        AppTypography.caption.copyWith(color: AppColors.primary),
                  ),
                ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Admin login form (email/password → optional OTP)
// ---------------------------------------------------------------------------

class _AdminLoginForm extends StatefulWidget {
  final void Function(dynamic user, dynamic tokens) onSuccess;
  const _AdminLoginForm({super.key, required this.onSuccess});

  @override
  State<_AdminLoginForm> createState() => _AdminLoginFormState();
}

class _AdminLoginFormState extends State<_AdminLoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  String? _pendingEmail;

  // Registration mode
  bool _showRegister = false;
  final _regFormKey = GlobalKey<FormState>();
  final _fullNameCtrl = TextEditingController();
  final _regEmailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _regPassCtrl = TextEditingController();
  bool _regObscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _fullNameCtrl.dispose();
    _regEmailCtrl.dispose();
    _phoneCtrl.dispose();
    _regPassCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final id = _emailCtrl.text.trim();
    final lockout = context.read<AccountLockoutCubit>();
    if (lockout.isLocked(id)) {
      _showLockoutSnackbar(lockout.lockedUntil(id)!);
      return;
    }
    context.read<AdminLoginBloc>().add(
          AdminLoginSubmitted(
            email: id,
            password: _passCtrl.text,
          ),
        );
  }

  void _showLockoutSnackbar(DateTime until) {
    final remaining = until.difference(DateTime.now());
    final mins = remaining.inMinutes + 1;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Account locked. Try again in $mins minute(s).'),
        backgroundColor: AppColors.danger,
      ),
    );
  }

  void _submitRegister() {
    if (!_regFormKey.currentState!.validate()) return;
    context.read<AdminRegisterCubit>().register(
          fullName: _fullNameCtrl.text.trim(),
          email: _regEmailCtrl.text.trim(),
          phoneNumber: _phoneCtrl.text.trim(),
          password: _regPassCtrl.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminLoginBloc, AdminLoginState>(
      listener: (context, state) {
        if (state is AdminLoginRequires2fa) {
          setState(() => _pendingEmail = state.email);
        }
        if (state is AdminLoginSuccess) {
          context
              .read<AccountLockoutCubit>()
              .recordSuccess(_emailCtrl.text.trim());
          widget.onSuccess(state.user, state.tokens);
        }
        if (state is AdminLoginError) {
          context
              .read<AccountLockoutCubit>()
              .recordFailure(_emailCtrl.text.trim());
        }
      },
      builder: (context, state) {
        if (_showRegister) return _buildRegisterStep(context);
        if (state is AdminLoginRequires2fa ||
            (state is AdminLoginLoading && _pendingEmail != null)) {
          return _buildOtpStep(context, state);
        }
        return _buildCredentialStep(context, state);
      },
    );
  }

  Widget _buildCredentialStep(BuildContext context, AdminLoginState state) {
    final isLoading = state is AdminLoginLoading;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _emailCtrl,
            autofocus: true,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'admin@clinic.et',
              prefixIcon: Icon(Icons.email_outlined, size: 18),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email is required';
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v.trim())) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _passCtrl,
            obscureText: _obscure,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outlined, size: 18),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 18,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Password is required' : null,
            onFieldSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () =>
                  GoRouter.of(context).go(RouteNames.forgotPassword),
              style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 32)),
              child: Text(
                'Forgot password?',
                style: AppTypography.caption
                    .copyWith(color: AppColors.primary),
              ),
            ),
          ),
          if (state is AdminLoginError) ...[
            const SizedBox(height: 4),
            _ErrorText(state.message),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: isLoading ? null : _submit,
              child: isLoading ? _LoadingSpinner() : const Text('Sign In'),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Don't have an account? ",
                style: AppTypography.caption
                    .copyWith(color: AppColors.neutral500),
              ),
              TextButton(
                onPressed: () => setState(() => _showRegister = true),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Create Account',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterStep(BuildContext context) {
    return BlocConsumer<AdminRegisterCubit, AdminRegisterState>(
      listener: (context, state) {
        if (state is AdminRegisterSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account created! You can now sign in.'),
              backgroundColor: AppColors.success,
            ),
          );
          context.read<AdminRegisterCubit>().reset();
          setState(() {
            _showRegister = false;
            _fullNameCtrl.clear();
            _regEmailCtrl.clear();
            _phoneCtrl.clear();
            _regPassCtrl.clear();
          });
        }
      },
      builder: (context, state) {
        final isLoading = state is AdminRegisterLoading;
        return Form(
          key: _regFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 18),
                    onPressed: () {
                      context.read<AdminRegisterCubit>().reset();
                      setState(() => _showRegister = false);
                    },
                    tooltip: 'Back to Sign In',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Create Admin Account',
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.neutral600),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fullNameCtrl,
                autofocus: true,
                textInputAction: TextInputAction.next,
                enabled: !isLoading,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outlined, size: 18),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Full name is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _regEmailCtrl,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                enabled: !isLoading,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'admin@clinic.et',
                  prefixIcon: Icon(Icons.email_outlined, size: 18),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Email is required';
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v.trim())) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                enabled: !isLoading,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone_outlined, size: 18),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Phone number is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _regPassCtrl,
                obscureText: _regObscure,
                textInputAction: TextInputAction.done,
                enabled: !isLoading,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outlined, size: 18),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _regObscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 18,
                    ),
                    onPressed: () => setState(() => _regObscure = !_regObscure),
                  ),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Password is required' : null,
                onFieldSubmitted: (_) => _submitRegister(),
              ),
              if (state is AdminRegisterError) ...[
                const SizedBox(height: 8),
                _ErrorText(state.message),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submitRegister,
                  child: isLoading
                      ? _LoadingSpinner()
                      : const Text('Create Account'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOtpStep(BuildContext context, AdminLoginState state) {
    final email = _pendingEmail ?? _emailCtrl.text.trim();
    final isLoading = state is AdminLoginLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, size: 18),
              onPressed: () {
                setState(() => _pendingEmail = null);
                context.read<AdminLoginBloc>().add(const AdminLoginReset());
              },
              tooltip: 'Back',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Enter the verification code sent to $email',
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.neutral600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Center(
          child: Pinput(
            length: 6,
            autofocus: true,
            enabled: !isLoading,
            defaultPinTheme: PinTheme(
              width: 52,
              height: 52,
              textStyle: AppTypography.h2
                  .copyWith(color: AppColors.neutral900),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.neutral300),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            focusedPinTheme: PinTheme(
              width: 52,
              height: 52,
              textStyle: AppTypography.h2
                  .copyWith(color: AppColors.neutral900),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onCompleted: isLoading
                ? null
                : (otp) => context.read<AdminLoginBloc>().add(
                      AdminOtpSubmitted(email: email, otpCode: otp),
                    ),
          ),
        ),
        if (isLoading) ...[
          const SizedBox(height: 16),
          const Center(child: _LoadingSpinner()),
        ],
        if (state is AdminLoginError) ...[
          const SizedBox(height: 12),
          Center(child: _ErrorText(state.message)),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// SuperAdmin login form (email/password → mandatory TOTP)
// ---------------------------------------------------------------------------

class _SuperAdminLoginForm extends StatefulWidget {
  final void Function(dynamic user, dynamic tokens) onSuccess;
  const _SuperAdminLoginForm({super.key, required this.onSuccess});

  @override
  State<_SuperAdminLoginForm> createState() => _SuperAdminLoginFormState();
}

class _SuperAdminLoginFormState extends State<_SuperAdminLoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  String? _pendingEmail;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final id = _emailCtrl.text.trim();
    final lockout = context.read<AccountLockoutCubit>();
    if (lockout.isLocked(id)) {
      _showLockoutSnackbar(lockout.lockedUntil(id)!);
      return;
    }
    context.read<SuperAdminLoginBloc>().add(
          SuperAdminLoginSubmitted(
            email: id,
            password: _passCtrl.text,
          ),
        );
  }

  void _showLockoutSnackbar(DateTime until) {
    final remaining = until.difference(DateTime.now());
    final mins = remaining.inMinutes + 1;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Account locked. Try again in $mins minute(s).'),
        backgroundColor: AppColors.danger,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SuperAdminLoginBloc, SuperAdminLoginState>(
      listener: (context, state) {
        if (state is SuperAdminLoginRequires2fa) {
          setState(() => _pendingEmail = state.email);
        }
        if (state is SuperAdminLoginSuccess) {
          context
              .read<AccountLockoutCubit>()
              .recordSuccess(_emailCtrl.text.trim());
          widget.onSuccess(state.user, state.tokens);
        }
        if (state is SuperAdminLoginError) {
          context
              .read<AccountLockoutCubit>()
              .recordFailure(_emailCtrl.text.trim());
        }
      },
      builder: (context, state) {
        if (state is SuperAdminLoginRequires2fa ||
            (state is SuperAdminLoginLoading && _pendingEmail != null)) {
          return _buildTotpStep(context, state);
        }
        return _buildCredentialStep(context, state);
      },
    );
  }

  Widget _buildCredentialStep(
      BuildContext context, SuperAdminLoginState state) {
    final isLoading = state is SuperAdminLoginLoading;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withAlpha(80),
              borderRadius: AppRadius.radiusSm,
              border: Border.all(color: AppColors.primaryLight),
            ),
            child: Row(
              children: [
                const FaIcon(FontAwesomeIcons.shieldHalved,
                    size: 14, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Super Admin access requires TOTP verification',
                    style: AppTypography.caption
                        .copyWith(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailCtrl,
            autofocus: true,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'super@medimind.et',
              prefixIcon: Icon(Icons.email_outlined, size: 18),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email is required';
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v.trim())) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _passCtrl,
            obscureText: _obscure,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outlined, size: 18),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 18,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Password is required' : null,
            onFieldSubmitted: (_) => _submit(),
          ),
          if (state is SuperAdminLoginError) ...[
            const SizedBox(height: 8),
            _ErrorText(state.message),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: isLoading ? null : _submit,
              child: isLoading ? _LoadingSpinner() : const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotpStep(BuildContext context, SuperAdminLoginState state) {
    final email = _pendingEmail ?? _emailCtrl.text.trim();
    final isLoading = state is SuperAdminLoginLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, size: 18),
              onPressed: () {
                setState(() => _pendingEmail = null);
                context
                    .read<SuperAdminLoginBloc>()
                    .add(const SuperAdminLoginReset());
              },
              tooltip: 'Back',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Enter the 6-digit code from your authenticator app',
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.neutral600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          email,
          style: AppTypography.caption.copyWith(color: AppColors.neutral400),
        ),
        const SizedBox(height: 24),
        Center(
          child: Pinput(
            length: 6,
            autofocus: true,
            enabled: !isLoading,
            defaultPinTheme: PinTheme(
              width: 52,
              height: 52,
              textStyle: AppTypography.h2
                  .copyWith(color: AppColors.neutral900),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.neutral300),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            focusedPinTheme: PinTheme(
              width: 52,
              height: 52,
              textStyle: AppTypography.h2
                  .copyWith(color: AppColors.neutral900),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onCompleted: isLoading
                ? null
                : (code) => context.read<SuperAdminLoginBloc>().add(
                      SuperAdmin2faSubmitted(email: email, totpCode: code),
                    ),
          ),
        ),
        if (isLoading) ...[
          const SizedBox(height: 16),
          const Center(child: _LoadingSpinner()),
        ],
        if (state is SuperAdminLoginError) ...[
          const SizedBox(height: 12),
          Center(child: _ErrorText(state.message)),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Shared small widgets
// ---------------------------------------------------------------------------

class _ErrorText extends StatelessWidget {
  final String message;
  const _ErrorText(this.message);

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: AppTypography.caption.copyWith(color: AppColors.danger),
    );
  }
}

class _LoadingSpinner extends StatelessWidget {
  const _LoadingSpinner();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 18,
      height: 18,
      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
    );
  }
}
