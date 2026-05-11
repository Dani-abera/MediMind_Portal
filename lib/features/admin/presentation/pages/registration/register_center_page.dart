import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/di/service_locator.dart';
import '../../../../../core/network/user_context.dart';
import '../../../../../core/routing/route_names.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../auth/data/datasources/auth_local_datasource.dart';
import '../../../../auth/data/models/user_model.dart';
import '../../bloc/registration/center_registration_bloc.dart';
import '../../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../auth/presentation/bloc/auth_event.dart';
import '../../../../auth/presentation/bloc/auth_state.dart';

class RegisterCenterPage extends StatefulWidget {
  const RegisterCenterPage({super.key});

  @override
  State<RegisterCenterPage> createState() => _RegisterCenterPageState();
}

class _RegisterCenterPageState extends State<RegisterCenterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _typeCtrl = TextEditingController(text: 'Clinic');
  final _licenseCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _regionCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _servicesCtrl = TextEditingController();
  final _specializationsCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _typeCtrl.dispose();
    _licenseCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _regionCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _servicesCtrl.dispose();
    _specializationsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CenterRegistrationBloc>(),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            context.go(RouteNames.login);
          }
        },
        builder: (context, authState) {
          return Stack(
            children: [
              Scaffold(
                appBar: AppBar(
                  title: const Text('Register Healthcare Center'),
                ),
                body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: BlocConsumer<CenterRegistrationBloc, CenterRegistrationState>(
                listener: (context, state) {
                  if (state is CenterRegistrationSuccess) {
                    final ctx = sl<UserContext>();
                    ctx.centerId = state.center.centerId;
                    ctx.centerStatus = state.center.subscriptionStatus.isEmpty 
                      ? 'PendingApproval' 
                      : state.center.subscriptionStatus;

                    final localAuth = sl<AuthLocalDataSource>();
                    localAuth.getCachedUser().then((user) {
                      if (user is AdminUserModel) {
                        localAuth.cacheUser(AdminUserModel(
                          id: user.id,
                          fullName: user.fullName,
                          email: user.email,
                          centerId: ctx.centerId,
                          centerName: state.center.centerName,
                          centerStatus: ctx.centerStatus,
                          avatarUrl: user.avatarUrl,
                        ));
                      }
                    });

                    context.go(RouteNames.adminPendingApproval);
                  } else if (state is CenterRegistrationFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message), backgroundColor: Colors.red),
                    );
                  }
                },
                builder: (context, state) {
                  final isLoading = state is CenterRegistrationLoading;
                  return Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Center Information', style: AppTypography.h3),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(labelText: 'Center Name *'),
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                          enabled: !isLoading,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _typeCtrl,
                          decoration: const InputDecoration(labelText: 'Center Type * (e.g. Clinic, Hospital)'),
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                          enabled: !isLoading,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _licenseCtrl,
                          decoration: const InputDecoration(labelText: 'License Number *'),
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                          enabled: !isLoading,
                        ),
                        const SizedBox(height: 24),
                        Text('Contact & Location', style: AppTypography.h3),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: TextFormField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email *'), enabled: !isLoading)),
                            const SizedBox(width: 16),
                            Expanded(child: TextFormField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'Phone Number *'), enabled: !isLoading)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _addressCtrl,
                          decoration: const InputDecoration(labelText: 'Address *'),
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                          enabled: !isLoading,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: TextFormField(controller: _cityCtrl, decoration: const InputDecoration(labelText: 'City *'), enabled: !isLoading)),
                            const SizedBox(width: 16),
                            Expanded(child: TextFormField(controller: _regionCtrl, decoration: const InputDecoration(labelText: 'Region *'), enabled: !isLoading)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text('Services (Comma separated)', style: AppTypography.h3),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _servicesCtrl,
                          decoration: const InputDecoration(labelText: 'Services Offered', hintText: 'e.g. Pediatrics, X-Ray'),
                          enabled: !isLoading,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _specializationsCtrl,
                          decoration: const InputDecoration(labelText: 'Specializations', hintText: 'e.g. General Practice, Dentistry'),
                          enabled: !isLoading,
                        ),
                        const SizedBox(height: 32),
                        FilledButton(
                          onPressed: isLoading ? null : () {
                            if (!_formKey.currentState!.validate()) return;
                            final data = {
                              "centerName": _nameCtrl.text,
                              "centerType": _typeCtrl.text,
                              "licenseNumber": _licenseCtrl.text,
                              "address": _addressCtrl.text,
                              "city": _cityCtrl.text,
                              "region": _regionCtrl.text,
                              "phoneNumber": _phoneCtrl.text,
                              "email": _emailCtrl.text,
                              "workingHours": {
                                "monday": null,
                                "tuesday": null,
                                "wednesday": null,
                                "thursday": null,
                                "friday": null,
                                "saturday": null,
                                "sunday": null
                              },
                              "servicesOffered": _servicesCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
                              "specializations": _specializationsCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
                              "latitude": "0.0",
                              "longitude": "0.0"
                            };
                            context.read<CenterRegistrationBloc>().add(RegisterCenterSubmitted(data));
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: isLoading
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('Submit Registration'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: isLoading ? null : () {
                            context.read<AuthBloc>().add(const AuthLogoutRequested());
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Text('Logout'),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
              if (authState is AuthLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
