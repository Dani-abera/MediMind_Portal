import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../bloc/doctors_roster/doctors_roster_bloc.dart';

class AddDoctorDialog extends StatefulWidget {
  const AddDoctorDialog._();

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: context.read<DoctorsRosterBloc>(),
        child: const AddDoctorDialog._(),
      ),
    );
  }

  @override
  State<AddDoctorDialog> createState() => _AddDoctorDialogState();
}

class _AddDoctorDialogState extends State<AddDoctorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _licenseCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _licenseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DoctorsRosterBloc, DoctorsRosterState>(
      listener: (ctx, state) {
        if (state is DoctorsRosterActionSuccess) {
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
        title: const Text('Add Doctor to Center'),
        content: SizedBox(
          width: 400,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter the doctor\'s medical license number to search and add them to your center.',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.neutral500),
                ),
                const SizedBox(height: AppSpacing.base),
                TextFormField(
                  controller: _licenseCtrl,
                  decoration: const InputDecoration(
                    labelText: 'License Number',
                    hintText: 'e.g. MED-2024-001234',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  validator: (v) => v == null || v.trim().isEmpty ? 'License number is required' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _submitting ? null : () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          AppButton.primary(
            label: 'Search & Add',
            isLoading: _submitting,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<DoctorsRosterBloc>().add(DoctorAddedToCenter(_licenseCtrl.text.trim()));
  }
}
