import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/network/user_context.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/shell/page_header.dart';
import '../presentation/bloc/center_settings/center_settings_bloc.dart';

class CenterGeneralPage extends StatelessWidget {
  const CenterGeneralPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CenterSettingsBloc>()
        ..add(CenterSettingsStarted(UserContext().centerId ?? '')),
      child: const _GeneralView(),
    );
  }
}

class _GeneralView extends StatefulWidget {
  const _GeneralView();

  @override
  State<_GeneralView> createState() => _GeneralViewState();
}

class _GeneralViewState extends State<_GeneralView> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _regionCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();
  final _licenseCtrl = TextEditingController();

  List<String> _specializations = [];
  List<String> _services = [];
  final _specInputCtrl = TextEditingController();
  final _serviceInputCtrl = TextEditingController();

  bool _populated = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _cityCtrl.dispose();
    _regionCtrl.dispose();
    _addressCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    _licenseCtrl.dispose();
    _specInputCtrl.dispose();
    _serviceInputCtrl.dispose();
    super.dispose();
  }

  void _populate(CenterSettingsLoaded state) {
    if (_populated) return;
    _populated = true;
    final c = state.config;
    _nameCtrl.text = c.name;
    _phoneCtrl.text = c.phone;
    _emailCtrl.text = c.email;
    _cityCtrl.text = c.city;
    _regionCtrl.text = c.region;
    _addressCtrl.text = c.fullAddress;
    _latCtrl.text = c.latitude == 0 ? '' : c.latitude.toString();
    _lngCtrl.text = c.longitude == 0 ? '' : c.longitude.toString();
    _licenseCtrl.text = c.licenseNumber;
    _specializations = List<String>.from(c.specializations);
    _services = List<String>.from(c.services);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CenterSettingsBloc, CenterSettingsState>(
      listener: (ctx, state) {
        if (state is CenterSettingsLoaded && !_populated) {
          setState(() => _populate(state));
        }
        if (state is CenterSettingsSaved) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(content: Text('Center settings saved successfully')),
          );
        }
        if (state is CenterSettingsError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.danger),
          );
        }
      },
      child: BlocBuilder<CenterSettingsBloc, CenterSettingsState>(
        builder: (ctx, state) {
          final isSaving = state is CenterSettingsSaving;
          return Column(
            children: [
              const PageHeader(
                title: 'Center Settings',
                subtitle: 'General Information',
              ),
              if (state is CenterSettingsLoading)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionHeader('Basic Information'),
                        const SizedBox(height: AppSpacing.base),
                        Row(
                          children: [
                            Expanded(child: _field('Center Name', _nameCtrl)),
                            const SizedBox(width: AppSpacing.base),
                            Expanded(child: _field('Phone', _phoneCtrl)),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.base),
                        _field('Email', _emailCtrl),
                        const SizedBox(height: AppSpacing.xl),
                        _sectionHeader('Location'),
                        const SizedBox(height: AppSpacing.base),
                        Row(
                          children: [
                            Expanded(child: _field('City', _cityCtrl)),
                            const SizedBox(width: AppSpacing.base),
                            Expanded(child: _field('Region', _regionCtrl)),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.base),
                        _field('Full Address', _addressCtrl, maxLines: 3),
                        const SizedBox(height: AppSpacing.base),
                        Row(
                          children: [
                            Expanded(
                              child: _field(
                                'Latitude',
                                _latCtrl,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.base),
                            Expanded(
                              child: _field(
                                'Longitude',
                                _lngCtrl,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        _sectionHeader('License'),
                        const SizedBox(height: AppSpacing.base),
                        TextFormField(
                          controller: _licenseCtrl,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'License Number',
                            suffixIcon: Tooltip(
                              message: 'Set by platform admin',
                              child: Icon(Icons.lock_outline, size: 16, color: AppColors.neutral400),
                            ),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        _sectionHeader('Services & Specializations'),
                        const SizedBox(height: AppSpacing.base),
                        Text('Specializations', style: AppTypography.bodySmall.copyWith(color: AppColors.neutral600)),
                        const SizedBox(height: AppSpacing.sm),
                        _chipEditor(
                          chips: _specializations,
                          inputCtrl: _specInputCtrl,
                          onAdd: (v) => setState(() => _specializations.add(v)),
                          onRemove: (i) => setState(() => _specializations.removeAt(i)),
                        ),
                        const SizedBox(height: AppSpacing.base),
                        Text('Services', style: AppTypography.bodySmall.copyWith(color: AppColors.neutral600)),
                        const SizedBox(height: AppSpacing.sm),
                        _chipEditor(
                          chips: _services,
                          inputCtrl: _serviceInputCtrl,
                          onAdd: (v) => setState(() => _services.add(v)),
                          onRemove: (i) => setState(() => _services.removeAt(i)),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton(
                            onPressed: isSaving
                                ? null
                                : () {
                                    ctx.read<CenterSettingsBloc>().add(
                                          CenterSettingsFieldChanged(
                                            name: _nameCtrl.text,
                                            phone: _phoneCtrl.text,
                                            email: _emailCtrl.text,
                                            city: _cityCtrl.text,
                                            region: _regionCtrl.text,
                                            fullAddress: _addressCtrl.text,
                                            latitude: double.tryParse(_latCtrl.text),
                                            longitude: double.tryParse(_lngCtrl.text),
                                            specializations: List<String>.from(_specializations),
                                            services: List<String>.from(_services),
                                          ),
                                        );
                                    ctx.read<CenterSettingsBloc>().add(const CenterSettingsSubmitted());
                                  },
                            child: isSaving
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text('Save Changes'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionHeader(String title) => Text(
        title,
        style: AppTypography.h3.copyWith(color: AppColors.neutral700),
      );

  Widget _field(
    String label,
    TextEditingController ctrl, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) =>
      TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      );

  Widget _chipEditor({
    required List<String> chips,
    required TextEditingController inputCtrl,
    required ValueChanged<String> onAdd,
    required ValueChanged<int> onRemove,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              ...chips.asMap().entries.map(
                    (e) => Chip(
                      label: Text(e.value),
                      onDeleted: () => onRemove(e.key),
                    ),
                  ),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: inputCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Add and press Enter',
                    isDense: true,
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                  onSubmitted: (v) {
                    final trimmed = v.trim();
                    if (trimmed.isNotEmpty) {
                      onAdd(trimmed);
                      inputCtrl.clear();
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      );
}
