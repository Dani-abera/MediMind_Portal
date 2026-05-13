import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/di/service_locator.dart';
import '../../../../../core/network/user_context.dart';
import '../../../../../core/routing/route_names.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../auth/data/datasources/auth_local_datasource.dart';
import '../../../../auth/data/models/user_model.dart';
import '../../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../auth/presentation/bloc/auth_event.dart';
import '../../../../auth/presentation/bloc/auth_state.dart';
import '../../../../centers/domain/entities/subscription_plan.dart';
import '../../../../centers/domain/usecases/initiate_subscription_payment_usecase.dart';
import '../../bloc/registration/center_registration_bloc.dart';
import '../../bloc/registration/subscription_plans_cubit.dart';
import '../../widgets/registration/chip_input_field.dart';
import '../../widgets/registration/map_location_picker.dart';
import '../../widgets/registration/registration_stepper.dart';
import '../../widgets/registration/subscription_plan_card.dart';
import '../../widgets/registration/working_hours_form.dart';

class RegisterCenterPage extends StatelessWidget {
  const RegisterCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<CenterRegistrationBloc>()),
        BlocProvider(create: (_) => sl<SubscriptionPlansCubit>()..loadPlans()),
      ],
      child: const _RegisterCenterPageBody(),
    );
  }
}

class _RegisterCenterPageBody extends StatefulWidget {
  const _RegisterCenterPageBody();

  @override
  State<_RegisterCenterPageBody> createState() => _RegisterCenterPageBodyState();
}

class _RegisterCenterPageBodyState extends State<_RegisterCenterPageBody> {
  final _pageCtrl = PageController();
  int _step = 0;

  // Step 0 – Center Details
  final _step0Key = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _licenseCtrl = TextEditingController();
  String _centerType = 'Clinic';

  // Step 1 – Location & Contact
  final _step1Key = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _regionCtrl = TextEditingController();
  LatLng? _pickedLocation;

  // Step 2 – Services & Hours
  List<String> _services = [];
  List<String> _specializations = [];
  Map<String, String?> _workingHours = {};

  // Step 3 – Subscription plan
  SubscriptionPlan? _selectedPlan;

  // Step 4 – Payment
  bool _paymentLaunched = false;

  static const _centerTypes = [
    'Hospital', 'Clinic', 'Health Center', 'Pharmacy', 'Laboratory', 'Dental Clinic',
  ];

  static const _stepLabels = [
    'Center Details',
    'Location',
    'Services',
    'Plan',
    'Payment',
  ];

  @override
  void dispose() {
    _pageCtrl.dispose();
    _nameCtrl.dispose();
    _licenseCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _regionCtrl.dispose();
    super.dispose();
  }

  void _goTo(int step) {
    setState(() => _step = step);
    _pageCtrl.animateToPage(step,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  bool _validateCurrent() {
    switch (_step) {
      case 0:
        return _step0Key.currentState?.validate() ?? false;
      case 1:
        return _step1Key.currentState?.validate() ?? false;
      case 2:
        if (_services.isEmpty) {
          _showError('Please add at least one service offered.');
          return false;
        }
        return true;
      case 3:
        if (_selectedPlan == null) {
          _showError('Please select a subscription plan.');
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.danger));
  }

  void _next() {
    if (!_validateCurrent()) return;
    if (_step < _stepLabels.length - 1) {
      _goTo(_step + 1);
    } else {
      _submit();
    }
  }

  void _back() {
    if (_step > 0) _goTo(_step - 1);
  }

  Map<String, dynamic> _buildPayload() {
    return {
      'centerName': _nameCtrl.text.trim(),
      'centerType': _centerType,
      'licenseNumber': _licenseCtrl.text.trim(),
      'address': _addressCtrl.text.trim(),
      'city': _cityCtrl.text.trim(),
      'region': _regionCtrl.text.trim(),
      'phoneNumber': _phoneCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'workingHours': _workingHours,
      'servicesOffered': _services,
      'specializations': _specializations,
      'latitude': _pickedLocation?.latitude ?? 0.0,
      'longitude': _pickedLocation?.longitude ?? 0.0,
    };
  }

  void _submit() {
    context.read<CenterRegistrationBloc>().add(RegisterCenterSubmitted(_buildPayload()));
  }

  Future<void> _launchPayment(String centerId) async {
    if (_selectedPlan == null || _selectedPlan!.isFree) return;
    try {
      final useCase = sl<InitiateSubscriptionPaymentUseCase>();
      final url = await useCase(centerId, _selectedPlan!.id);
      if (url.isNotEmpty) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        setState(() => _paymentLaunched = true);
      }
    } catch (_) {
      // Payment initiation not available — proceed anyway
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
        listener: (ctx, state) {
          if (state is AuthUnauthenticated) ctx.go(RouteNames.login);
        },
        builder: (ctx, authState) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: BlocConsumer<CenterRegistrationBloc, CenterRegistrationState>(
              listener: (ctx, state) async {
                if (state is CenterRegistrationSuccess) {
                  final center = state.center;
                  final userCtx = sl<UserContext>();
                  userCtx.centerId = center.centerId;
                  userCtx.centerStatus = center.subscriptionStatus.isEmpty
                      ? 'PendingApproval'
                      : center.subscriptionStatus;

                  final localAuth = sl<AuthLocalDataSource>();
                  final user = await localAuth.getCachedUser();
                  if (user is AdminUserModel) {
                    await localAuth.cacheUser(AdminUserModel(
                      id: user.id,
                      fullName: user.fullName,
                      email: user.email,
                      centerId: center.centerId,
                      centerName: center.centerName,
                      centerStatus: userCtx.centerStatus,
                      avatarUrl: user.avatarUrl,
                    ));
                  }

                  if (_selectedPlan != null && !_selectedPlan!.isFree) {
                    await _launchPayment(center.centerId);
                  }

                  if (ctx.mounted) ctx.go(RouteNames.adminPendingApproval);
                } else if (state is CenterRegistrationFailure) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.danger,
                  ));
                }
              },
              builder: (ctx, regState) {
                final isSubmitting = regState is CenterRegistrationLoading;
                return Column(
                  children: [
                    _buildTopBar(ctx),
                    Expanded(
                      child: PageView(
                        controller: _pageCtrl,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _Step0CenterDetails(
                            formKey: _step0Key,
                            nameCtrl: _nameCtrl,
                            licenseCtrl: _licenseCtrl,
                            centerType: _centerType,
                            centerTypes: _centerTypes,
                            onTypeChanged: (v) =>
                                setState(() => _centerType = v),
                          ),
                          _Step1Location(
                            formKey: _step1Key,
                            emailCtrl: _emailCtrl,
                            phoneCtrl: _phoneCtrl,
                            addressCtrl: _addressCtrl,
                            cityCtrl: _cityCtrl,
                            regionCtrl: _regionCtrl,
                            pickedLocation: _pickedLocation,
                            onLocationPicked: (loc) =>
                                setState(() => _pickedLocation = loc),
                          ),
                          _Step2Services(
                            services: _services,
                            specializations: _specializations,
                            workingHours: _workingHours,
                            onServicesChanged: (v) =>
                                setState(() => _services = v),
                            onSpecializationsChanged: (v) =>
                                setState(() => _specializations = v),
                            onHoursChanged: (v) =>
                                setState(() => _workingHours = v),
                          ),
                          _Step3Plan(
                            selectedPlan: _selectedPlan,
                            onPlanSelected: (p) =>
                                setState(() => _selectedPlan = p),
                          ),
                          _Step4Payment(
                            selectedPlan: _selectedPlan,
                            isSubmitting: isSubmitting,
                            paymentLaunched: _paymentLaunched,
                            onPayWithChapa: () async {
                              // Payment URL is fetched after center is created
                              // Just proceed to submit
                              _submit();
                            },
                          ),
                        ],
                      ),
                    ),
                    _buildFooter(ctx, isSubmitting),
                  ],
                );
              },
            ),
          );
        },
      );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(32, 20, 32, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Register Healthcare Center',
                  style: AppTypography.h2.copyWith(color: AppColors.neutral900)),
              const Spacer(),
              TextButton.icon(
                icon: const Icon(Icons.logout, size: 16),
                label: const Text('Sign Out'),
                onPressed: () =>
                    context.read<AuthBloc>().add(const AuthLogoutRequested()),
                style: TextButton.styleFrom(foregroundColor: AppColors.neutral500),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('Complete all steps to register your center',
              style: AppTypography.body.copyWith(color: AppColors.neutral500)),
          const SizedBox(height: 20),
          RegistrationStepper(currentStep: _step, labels: _stepLabels),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, bool isSubmitting) {
    final isLastStep = _step == _stepLabels.length - 1;
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Row(
        children: [
          if (_step > 0)
            OutlinedButton.icon(
              icon: const Icon(Icons.arrow_back, size: 16),
              label: const Text('Back'),
              onPressed: isSubmitting ? null : _back,
            ),
          const Spacer(),
          FilledButton(
            onPressed: isSubmitting ? null : _next,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(isLastStep ? 'Submit Registration' : 'Continue'),
                        const SizedBox(width: 6),
                        Icon(
                            isLastStep
                                ? Icons.check
                                : Icons.arrow_forward,
                            size: 16),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Step 0 – Center Details
// ─────────────────────────────────────────────────────────────
class _Step0CenterDetails extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController licenseCtrl;
  final String centerType;
  final List<String> centerTypes;
  final ValueChanged<String> onTypeChanged;

  const _Step0CenterDetails({
    required this.formKey,
    required this.nameCtrl,
    required this.licenseCtrl,
    required this.centerType,
    required this.centerTypes,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      title: 'Center Details',
      subtitle: 'Basic information about your healthcare facility',
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: nameCtrl,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Center Name *',
                hintText: 'e.g. Addis General Hospital',
                prefixIcon: Icon(Icons.local_hospital_outlined, size: 18),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Center name is required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: centerType,
              decoration: const InputDecoration(
                labelText: 'Center Type *',
                prefixIcon: Icon(Icons.category_outlined, size: 18),
              ),
              items: centerTypes
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) {
                if (v != null) onTypeChanged(v);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: licenseCtrl,
              decoration: const InputDecoration(
                labelText: 'License Number *',
                hintText: 'e.g. ETH-MED-2024-001',
                prefixIcon: Icon(Icons.badge_outlined, size: 18),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'License number is required' : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Step 1 – Location & Contact
// ─────────────────────────────────────────────────────────────
class _Step1Location extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController addressCtrl;
  final TextEditingController cityCtrl;
  final TextEditingController regionCtrl;
  final LatLng? pickedLocation;
  final ValueChanged<LatLng> onLocationPicked;

  const _Step1Location({
    required this.formKey,
    required this.emailCtrl,
    required this.phoneCtrl,
    required this.addressCtrl,
    required this.cityCtrl,
    required this.regionCtrl,
    required this.pickedLocation,
    required this.onLocationPicked,
  });

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      title: 'Location & Contact',
      subtitle: 'Where patients can find and reach your center',
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email *',
                      prefixIcon: Icon(Icons.email_outlined, size: 18),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v.trim())) {
                        return 'Invalid email';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number *',
                      prefixIcon: Icon(Icons.phone_outlined, size: 18),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: addressCtrl,
              decoration: const InputDecoration(
                labelText: 'Address *',
                hintText: 'Street, building, kebele',
                prefixIcon: Icon(Icons.location_on_outlined, size: 18),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Address is required' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: cityCtrl,
                    decoration: const InputDecoration(
                      labelText: 'City *',
                      prefixIcon: Icon(Icons.location_city_outlined, size: 18),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: regionCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Region *',
                      prefixIcon: Icon(Icons.map_outlined, size: 18),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            MapLocationPicker(
              initialLocation: pickedLocation,
              onLocationPicked: onLocationPicked,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Step 2 – Services & Working Hours
// ─────────────────────────────────────────────────────────────
class _Step2Services extends StatelessWidget {
  final List<String> services;
  final List<String> specializations;
  final Map<String, String?> workingHours;
  final ValueChanged<List<String>> onServicesChanged;
  final ValueChanged<List<String>> onSpecializationsChanged;
  final ValueChanged<Map<String, String?>> onHoursChanged;

  const _Step2Services({
    required this.services,
    required this.specializations,
    required this.workingHours,
    required this.onServicesChanged,
    required this.onSpecializationsChanged,
    required this.onHoursChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      title: 'Services & Hours',
      subtitle: 'What your center offers and when it is open',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ChipInputField(
            label: 'Services Offered *',
            hint: 'Type and press Enter — e.g. Pediatrics',
            values: services,
            onChanged: onServicesChanged,
          ),
          const SizedBox(height: 20),
          ChipInputField(
            label: 'Specializations',
            hint: 'Type and press Enter — e.g. Cardiology',
            values: specializations,
            onChanged: onSpecializationsChanged,
          ),
          const SizedBox(height: 20),
          WorkingHoursForm(
            initialValues: workingHours,
            onChanged: onHoursChanged,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Step 3 – Subscription Plan
// ─────────────────────────────────────────────────────────────
class _Step3Plan extends StatelessWidget {
  final SubscriptionPlan? selectedPlan;
  final ValueChanged<SubscriptionPlan> onPlanSelected;

  const _Step3Plan({
    required this.selectedPlan,
    required this.onPlanSelected,
  });

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      title: 'Subscription Plan',
      subtitle: 'Choose the plan that fits your center',
      child: BlocBuilder<SubscriptionPlansCubit, SubscriptionPlansState>(
        builder: (ctx, state) {
          if (state is SubscriptionPlansLoading) {
            return const Center(
                child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            ));
          }
          if (state is SubscriptionPlansError) {
            return Column(
              children: [
                Icon(Icons.wifi_off, size: 40, color: AppColors.neutral400),
                const SizedBox(height: 12),
                Text(state.message,
                    style: AppTypography.body.copyWith(color: AppColors.neutral500),
                    textAlign: TextAlign.center),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => ctx.read<SubscriptionPlansCubit>().loadPlans(),
                  child: const Text('Retry'),
                ),
              ],
            );
          }
          if (state is SubscriptionPlansLoaded) {
            final plans = state.plans;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),
              itemCount: plans.length,
              itemBuilder: (_, i) => SubscriptionPlanCard(
                plan: plans[i],
                isSelected: selectedPlan?.id == plans[i].id,
                onTap: () => onPlanSelected(plans[i]),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Step 4 – Payment
// ─────────────────────────────────────────────────────────────
class _Step4Payment extends StatelessWidget {
  final SubscriptionPlan? selectedPlan;
  final bool isSubmitting;
  final bool paymentLaunched;
  final VoidCallback onPayWithChapa;

  const _Step4Payment({
    required this.selectedPlan,
    required this.isSubmitting,
    required this.paymentLaunched,
    required this.onPayWithChapa,
  });

  @override
  Widget build(BuildContext context) {
    final plan = selectedPlan;
    if (plan == null) {
      return _StepScaffold(
        title: 'Payment',
        subtitle: '',
        child: Center(
          child: Text('No plan selected.',
              style: AppTypography.body.copyWith(color: AppColors.neutral400)),
        ),
      );
    }

    if (plan.isFree) {
      return _StepScaffold(
        title: 'Start Free Trial',
        subtitle: 'No payment required for the Trial plan',
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.success.withAlpha(15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.success.withAlpha(60)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline,
                      color: AppColors.success, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Free Trial Plan',
                            style: AppTypography.bodySmall
                                .copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(
                          'You selected the free trial plan. '
                          'Click "Submit Registration" to complete your registration. '
                          'A Super Admin will review and activate your account.',
                          style: AppTypography.caption
                              .copyWith(color: AppColors.neutral600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _planSummary(plan),
          ],
        ),
      );
    }

    return _StepScaffold(
      title: 'Complete Payment',
      subtitle: 'Pay for your chosen plan to proceed',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _planSummary(plan),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.info.withAlpha(12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.info.withAlpha(60)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: AppColors.info, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'After clicking "Submit Registration", your center will be registered '
                    'and a payment link will be opened in your browser via Chapa. '
                    'Complete the payment there, then wait for Super Admin approval.',
                    style: AppTypography.caption.copyWith(color: AppColors.neutral700),
                  ),
                ),
              ],
            ),
          ),
          if (paymentLaunched) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withAlpha(15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.success.withAlpha(60)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.open_in_browser,
                      color: AppColors.success, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    'Payment page opened in your browser.',
                    style: AppTypography.caption
                        .copyWith(color: AppColors.success),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _planSummary(SubscriptionPlan plan) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Selected Plan',
              style:
                  AppTypography.caption.copyWith(color: AppColors.neutral500)),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(plan.name,
                  style: AppTypography.bodySmall
                      .copyWith(fontWeight: FontWeight.w700)),
              const Spacer(),
              Text(
                plan.isFree
                    ? 'Free'
                    : 'ETB ${plan.monthlyPrice.toStringAsFixed(0)}/mo',
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: plan.isFree ? AppColors.success : AppColors.neutral900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            plan.maxDoctors == 0
                ? 'Unlimited doctors · ${plan.maxAppointmentsPerDay == 0 ? "Unlimited" : plan.maxAppointmentsPerDay} appointments/day'
                : 'Up to ${plan.maxDoctors} doctors · ${plan.maxAppointmentsPerDay} appointments/day',
            style: AppTypography.caption.copyWith(color: AppColors.neutral500),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Shared step scaffold
// ─────────────────────────────────────────────────────────────
class _StepScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _StepScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style:
                      AppTypography.h3.copyWith(color: AppColors.neutral900)),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(subtitle,
                    style: AppTypography.body
                        .copyWith(color: AppColors.neutral500)),
              ],
              const SizedBox(height: 24),
              child,
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
