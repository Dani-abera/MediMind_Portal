import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/di/service_locator.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/shell/page_header.dart';
import '../../../domain/entities/platform_settings.dart';
import '../../bloc/platform_settings/platform_settings_bloc.dart';

class PlatformSettingsPage extends StatelessWidget {
  const PlatformSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PlatformSettingsBloc>()..add(const PlatformSettingsStarted()),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatefulWidget {
  const _SettingsView();

  @override
  State<_SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<_SettingsView> {
  final _trialCtrl = TextEditingController();
  final _basicCtrl = TextEditingController();
  final _premiumCtrl = TextEditingController();
  final _maintenanceMsgCtrl = TextEditingController();
  bool _populated = false;

  @override
  void dispose() {
    _trialCtrl.dispose();
    _basicCtrl.dispose();
    _premiumCtrl.dispose();
    _maintenanceMsgCtrl.dispose();
    super.dispose();
  }

  void _populate(PlatformSettings settings) {
    if (_populated) return;
    _populated = true;
    _trialCtrl.text = settings.trialFeeEtb.toString();
    _basicCtrl.text = settings.basicFeeEtb.toString();
    _premiumCtrl.text = settings.premiumFeeEtb.toString();
    _maintenanceMsgCtrl.text = settings.maintenanceMessage;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlatformSettingsBloc, PlatformSettingsState>(
      listener: (ctx, state) {
        if (state is PlatformSettingsLoaded && !_populated) {
          setState(() => _populate(state.settings));
        }
        if (state is PlatformSettingsSaved) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(content: Text('Platform settings saved')),
          );
        }
        if (state is PlatformSettingsError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.danger),
          );
        }
      },
      child: BlocBuilder<PlatformSettingsBloc, PlatformSettingsState>(
        builder: (ctx, state) {
          final settings = state is PlatformSettingsLoaded ? state.settings : const PlatformSettings();
          final isLoading = state is PlatformSettingsLoading;
          final isSaving = state is PlatformSettingsSaving;

          return Column(
            children: [
              const PageHeader(
                title: 'Platform Settings',
                subtitle: 'System-wide configuration',
              ),
              if (isLoading)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionCard(
                          'Subscription Fees (ETB)',
                          Column(
                            children: [
                              _feeField('Trial Fee', _trialCtrl),
                              const SizedBox(height: AppSpacing.base),
                              _feeField('Basic Fee', _basicCtrl),
                              const SizedBox(height: AppSpacing.base),
                              _feeField('Premium Fee', _premiumCtrl),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.base),
                        _sectionCard(
                          'Maintenance Mode',
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SwitchListTile(
                                title: const Text('Enable Maintenance Mode'),
                                subtitle: const Text('This will disable access for all users except super admins'),
                                value: settings.maintenanceMode,
                                onChanged: (v) => ctx.read<PlatformSettingsBloc>().add(
                                      PlatformSettingsChanged(settings.copyWith(maintenanceMode: v)),
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              TextFormField(
                                controller: _maintenanceMsgCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Maintenance Message',
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 3,
                                onChanged: (v) => ctx.read<PlatformSettingsBloc>().add(
                                      PlatformSettingsChanged(settings.copyWith(maintenanceMessage: v)),
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.base),
                        if (settings.featureFlags.isNotEmpty) ...[
                          _sectionCard(
                            'Feature Flags',
                            Column(
                              children: settings.featureFlags.entries.map((e) {
                                return SwitchListTile(
                                  title: Text(e.key, style: AppTypography.bodySmall),
                                  value: e.value,
                                  onChanged: (v) {
                                    final newFlags = Map<String, bool>.from(settings.featureFlags);
                                    newFlags[e.key] = v;
                                    ctx.read<PlatformSettingsBloc>().add(
                                          PlatformSettingsChanged(settings.copyWith(featureFlags: newFlags)),
                                        );
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.base),
                        ],
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton(
                            onPressed: isSaving
                                ? null
                                : () {
                                    final updatedSettings = settings.copyWith(
                                      trialFeeEtb: double.tryParse(_trialCtrl.text) ?? settings.trialFeeEtb,
                                      basicFeeEtb: double.tryParse(_basicCtrl.text) ?? settings.basicFeeEtb,
                                      premiumFeeEtb: double.tryParse(_premiumCtrl.text) ?? settings.premiumFeeEtb,
                                      maintenanceMessage: _maintenanceMsgCtrl.text,
                                    );
                                    ctx.read<PlatformSettingsBloc>().add(PlatformSettingsChanged(updatedSettings));
                                    ctx.read<PlatformSettingsBloc>().add(const PlatformSettingsSubmitted());
                                  },
                            child: isSaving
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text('Save Settings'),
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

  Widget _sectionCard(String title, Widget child) => Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.h3),
              const SizedBox(height: AppSpacing.base),
              child,
            ],
          ),
        ),
      );

  Widget _feeField(String label, TextEditingController ctrl) => TextFormField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixText: 'ETB ',
        ),
      );
}
