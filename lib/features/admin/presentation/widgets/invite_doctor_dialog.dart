import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../domain/entities/doctor_at_center.dart';
import '../bloc/doctors_roster/doctors_roster_bloc.dart';

class InviteDoctorDialog extends StatefulWidget {
  const InviteDoctorDialog._();

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: context.read<DoctorsRosterBloc>(),
        child: const InviteDoctorDialog._(),
      ),
    );
  }

  @override
  State<InviteDoctorDialog> createState() => _InviteDoctorDialogState();
}

class _InviteDoctorDialogState extends State<InviteDoctorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _specializationCtrl = TextEditingController();
  final _licenseCtrl = TextEditingController();
  final _yearsCtrl = TextEditingController();
  final _feeCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _specializationCtrl.dispose();
    _licenseCtrl.dispose();
    _yearsCtrl.dispose();
    _feeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DoctorsRosterBloc, DoctorsRosterState>(
      listener: (ctx, state) {
        if (state is DoctorInvitationSent) {
          Navigator.of(ctx).pop();
        } else if (state is DoctorsRosterError) {
          setState(() => _submitting = false);
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.danger),
          );
        } else if (state is DoctorsRosterActionInProgress) {
          setState(() => _submitting = true);
        }
      },
      child: AlertDialog(
        title: const Text('Invite Doctor'),
        content: SizedBox(
          width: 480,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'The doctor will receive an email with a link to set up their account.',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.neutral500),
                  ),
                  const SizedBox(height: AppSpacing.base),
                  _field(
                    ctrl: _fullNameCtrl,
                    label: 'Full Name',
                    hint: 'Dr. Abebe Girma',
                    icon: Icons.person_outline,
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _field(
                    ctrl: _emailCtrl,
                    label: 'Email',
                    hint: 'doctor@example.com',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                      if (!emailRegex.hasMatch(v.trim())) return 'Please enter valid email address';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _field(
                    ctrl: _phoneCtrl,
                    label: 'Phone Number',
                    hint: '+251911234567',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _field(
                    ctrl: _specializationCtrl,
                    label: 'Specialization',
                    hint: 'e.g. Cardiology',
                    icon: Icons.medical_services_outlined,
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _field(
                    ctrl: _licenseCtrl,
                    label: 'License Number',
                    hint: 'e.g. MED-2024-001234',
                    icon: Icons.badge_outlined,
                    textCapitalization: TextCapitalization.characters,
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: _field(
                          ctrl: _yearsCtrl,
                          label: 'Years of Experience',
                          hint: '5',
                          icon: Icons.work_outline,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          validator: (v) {
                            final n = int.tryParse(v ?? '');
                            if (n == null || n < 0) return 'Invalid';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _field(
                          ctrl: _feeCtrl,
                          label: 'Consultation Fee (ETB)',
                          hint: '500',
                          icon: Icons.payments_outlined,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
                          validator: (v) {
                            final n = double.tryParse(v ?? '');
                            if (n == null || n <= 0) return 'Must be > 0';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _submitting ? null : () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          AppButton.primary(
            label: 'Send Invitation',
            isLoading: _submitting,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController ctrl,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
      ),
      validator: validator,
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<DoctorsRosterBloc>().add(
      DoctorInvited(
        InviteDoctorDto(
          fullName: _fullNameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          phoneNumber: _phoneCtrl.text.trim(),
          specialization: _specializationCtrl.text.trim(),
          licenseNumber: _licenseCtrl.text.trim(),
          yearsOfExperience: int.parse(_yearsCtrl.text.trim()),
          consultationFee: double.parse(_feeCtrl.text.trim()),
        ),
      ),
    );
  }
}
