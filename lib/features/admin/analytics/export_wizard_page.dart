// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/network/user_context.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/shell/page_header.dart';
import '../domain/entities/analytics_data.dart';
import '../domain/usecases/export_analytics_usecase.dart';
import '../presentation/bloc/export_wizard/export_wizard_bloc.dart';

class ExportWizardPage extends StatelessWidget {
  const ExportWizardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ExportWizardBloc>()
        ..add(ExportWizardStarted(UserContext().centerId ?? '')),
      child: const _ExportWizardView(),
    );
  }
}

class _ExportWizardView extends StatelessWidget {
  const _ExportWizardView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExportWizardBloc, ExportWizardState>(
      listener: (ctx, state) {
        if (state is ExportWizardDone) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(content: Text('Export generated successfully')),
          );
          context.read<ExportWizardBloc>().add(const ExportWizardReset());
        }
        if (state is ExportWizardFailed) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.danger),
          );
        }
      },
      child: Column(
        children: [
          const PageHeader(title: 'Export Data', subtitle: 'Generate and download reports'),
          Expanded(
            child: BlocBuilder<ExportWizardBloc, ExportWizardState>(
              builder: (ctx, state) {
                return Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StepIndicator(state: state),
                      const SizedBox(height: AppSpacing.xl),
                      Expanded(child: _StepContent(state: state)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final ExportWizardState state;
  const _StepIndicator({required this.state});

  int get _currentStep => switch (state) {
    ExportWizardStep1() => 1,
    ExportWizardStep2() => 2,
    ExportWizardStep3() => 3,
    ExportWizardStep4() || ExportWizardExporting() => 4,
    _ => 1,
  };

  @override
  Widget build(BuildContext context) {
    const labels = ['Choose Data', 'Date Range', 'Format', 'Preview & Export'];
    return Row(
      children: List.generate(4, (i) {
        final step = i + 1;
        final isActive = step == _currentStep;
        final isDone = step < _currentStep;
        return Expanded(
          child: Row(
            children: [
              _StepCircle(step: step, isActive: isActive, isDone: isDone),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Step $step', style: AppTypography.caption.copyWith(color: AppColors.neutral400, fontSize: 10)),
                    Text(labels[i],
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                          color: isActive ? AppColors.primary : AppColors.neutral600,
                        )),
                  ],
                ),
              ),
              if (i < 3) const Expanded(child: Divider()),
            ],
          ),
        );
      }),
    );
  }
}

class _StepCircle extends StatelessWidget {
  final int step;
  final bool isActive;
  final bool isDone;
  const _StepCircle({required this.step, required this.isActive, required this.isDone});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDone ? AppColors.primary : isActive ? AppColors.primary : AppColors.neutral200,
      ),
      child: Center(
        child: isDone
            ? const Icon(Icons.check, size: 14, color: Colors.white)
            : Text('$step',
                style: AppTypography.bodySmall.copyWith(
                  color: isActive ? Colors.white : AppColors.neutral500,
                  fontWeight: FontWeight.w600,
                )),
      ),
    );
  }
}

class _StepContent extends StatelessWidget {
  final ExportWizardState state;
  const _StepContent({required this.state});

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      ExportWizardStep1() => _Step1(state: state as ExportWizardStep1),
      ExportWizardStep2() => _Step2(state: state as ExportWizardStep2),
      ExportWizardStep3() => _Step3(state: state as ExportWizardStep3),
      ExportWizardStep4() => _Step4(state: state as ExportWizardStep4),
      ExportWizardExporting() => const Center(child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [CircularProgressIndicator(), SizedBox(height: 16), Text('Generating export…')],
        )),
      _ => const SizedBox.shrink(),
    };
  }
}

class _Step1 extends StatelessWidget {
  final ExportWizardStep1 state;
  const _Step1({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What data would you like to export?', style: AppTypography.h3),
        const SizedBox(height: AppSpacing.base),
        ...ExportDataType.values.map((t) => _DataTypeCard(
              type: t,
              isSelected: state.selectedType == t,
              onTap: () => context.read<ExportWizardBloc>().add(ExportDataTypeSelected(t)),
            )),
      ],
    );
  }
}

class _DataTypeCard extends StatelessWidget {
  final ExportDataType type;
  final bool isSelected;
  final VoidCallback onTap;
  const _DataTypeCard({required this.type, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withAlpha(10) : AppColors.neutral50,
          borderRadius: AppRadius.radiusBase,
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.neutral200, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Radio<ExportDataType>(
              value: type,
              groupValue: isSelected ? type : null,
              onChanged: (_) => onTap(),
              activeColor: AppColors.primary,
            ),
            Text(type.label, style: AppTypography.body),
          ],
        ),
      ),
    );
  }
}

class _Step2 extends StatelessWidget {
  final ExportWizardStep2 state;
  const _Step2({required this.state});

  @override
  Widget build(BuildContext context) {
    const presets = [DateRangePreset.today, DateRangePreset.last7, DateRangePreset.last30, DateRangePreset.last90];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 18),
            onPressed: () => context.read<ExportWizardBloc>().add(const ExportWizardStepBack()),
          ),
          Text('Select date range', style: AppTypography.h3),
        ]),
        const SizedBox(height: AppSpacing.base),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: presets.map((p) {
            final label = DateRangeSelection.preset(p).label;
            final isSelected = state.range.preset == p;
            return FilterChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) => context.read<ExportWizardBloc>().add(ExportDateRangeSelected(p)),
              selectedColor: AppColors.primary.withAlpha(20),
              checkmarkColor: AppColors.primary,
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _Step3 extends StatelessWidget {
  final ExportWizardStep3 state;
  const _Step3({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 18),
            onPressed: () => context.read<ExportWizardBloc>().add(const ExportWizardStepBack()),
          ),
          Text('Choose format', style: AppTypography.h3),
        ]),
        const SizedBox(height: AppSpacing.base),
        ...ExportFormat.values.map((f) => RadioListTile<ExportFormat>(
              title: Text(_formatLabel(f), style: AppTypography.body),
              subtitle: Text(_formatDesc(f), style: AppTypography.caption.copyWith(color: AppColors.neutral500)),
              value: f,
              groupValue: state.format,
              activeColor: AppColors.primary,
              onChanged: (_) => context.read<ExportWizardBloc>().add(ExportFormatSelected(f)),
            )),
        const SizedBox(height: AppSpacing.xl),
        AppButton.primary(
          label: 'Continue',
          onPressed: () => context.read<ExportWizardBloc>().add(ExportFormatSelected(state.format)),
        ),
      ],
    );
  }

  String _formatLabel(ExportFormat f) => switch (f) {
    ExportFormat.csv   => 'CSV',
    ExportFormat.excel => 'Excel (.xlsx)',
    ExportFormat.pdf   => 'PDF',
  };

  String _formatDesc(ExportFormat f) => switch (f) {
    ExportFormat.csv   => 'Comma-separated values for spreadsheet import',
    ExportFormat.excel => 'Formatted Excel workbook with headers',
    ExportFormat.pdf   => 'Formatted PDF with charts and summary tables',
  };
}

class _Step4 extends StatelessWidget {
  final ExportWizardStep4 state;
  const _Step4({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 18),
            onPressed: () => context.read<ExportWizardBloc>().add(const ExportWizardStepBack()),
          ),
          Text('Preview & Export', style: AppTypography.h3),
        ]),
        const SizedBox(height: AppSpacing.base),
        Container(
          padding: const EdgeInsets.all(AppSpacing.base),
          decoration: BoxDecoration(
            color: AppColors.neutral50,
            borderRadius: AppRadius.radiusBase,
            border: Border.all(color: AppColors.neutral200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _row('Data', state.dataType.label),
              _row('Date Range', state.range.label),
              _row('Format', state.format.name.toUpperCase()),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppButton.primary(
          label: 'Generate Export',
          onPressed: () => context.read<ExportWizardBloc>().add(const ExportGenerateRequested()),
          icon: Icons.download_outlined,
        ),
      ],
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: [
      SizedBox(width: 100, child: Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.neutral500))),
      Expanded(child: Text(value, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600))),
    ]),
  );
}
