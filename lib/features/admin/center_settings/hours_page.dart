import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/network/user_context.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/shell/page_header.dart';
import '../domain/entities/working_hours.dart';
import '../presentation/bloc/working_hours/working_hours_bloc.dart';

class CenterHoursPage extends StatelessWidget {
  const CenterHoursPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<WorkingHoursBloc>()
        ..add(WorkingHoursStarted(UserContext().centerId ?? '')),
      child: const _HoursView(),
    );
  }
}

class _HoursView extends StatelessWidget {
  const _HoursView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<WorkingHoursBloc, WorkingHoursState>(
      listener: (ctx, state) {
        if (state is WorkingHoursSaved) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(content: Text('Working hours saved successfully')),
          );
        }
        if (state is WorkingHoursError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.danger),
          );
        }
      },
      child: BlocBuilder<WorkingHoursBloc, WorkingHoursState>(
        builder: (ctx, state) {
          final hours = state is WorkingHoursLoaded ? state.hours : null;
          final isLoading = state is WorkingHoursLoading;
          final isSaving = state is WorkingHoursSaving;

          return Column(
            children: [
              const PageHeader(
                title: 'Center Settings',
                subtitle: 'Working Hours',
              ),
              if (isLoading)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else if (hours == null)
                const Expanded(child: Center(child: Text('No working hours configured')))
              else
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      children: [
                        ...hours.days.asMap().entries.map(
                              (e) => _DayCard(
                                dayIndex: e.key,
                                dayHours: e.value,
                              ),
                            ),
                        const SizedBox(height: AppSpacing.xl),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton(
                            onPressed: isSaving
                                ? null
                                : () => ctx.read<WorkingHoursBloc>().add(const WorkingHoursSubmitted()),
                            child: isSaving
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text('Save Working Hours'),
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
}

class _DayCard extends StatelessWidget {
  final int dayIndex;
  final DayHours dayHours;

  const _DayCard({required this.dayIndex, required this.dayHours});

  Future<void> _pickTime(BuildContext context, String field) async {
    final parts = _parseTime(field == 'openTime'
        ? dayHours.openTime
        : field == 'closeTime'
            ? dayHours.closeTime
            : field == 'breakStart'
                ? dayHours.breakStart
                : dayHours.breakEnd);
    final picked = await showTimePicker(
      context: context,
      initialTime: parts,
    );
    if (picked != null && context.mounted) {
      final formatted =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      context.read<WorkingHoursBloc>().add(WorkingHoursTimeChanged(dayIndex, field, formatted));
    }
  }

  TimeOfDay _parseTime(String? time) {
    if (time == null) return TimeOfDay.now();
    final parts = time.split(':');
    if (parts.length != 2) return TimeOfDay.now();
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 0,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(dayHours.day, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                ),
                Switch(
                  value: !dayHours.isClosed,
                  onChanged: (v) => context
                      .read<WorkingHoursBloc>()
                      .add(WorkingHoursDayToggled(dayIndex, !v)),
                ),
                const SizedBox(width: AppSpacing.base),
                if (!dayHours.isClosed) ...[
                  _timeButton(context, 'Open', dayHours.openTime, 'openTime'),
                  const SizedBox(width: AppSpacing.sm),
                  Text('–', style: AppTypography.body),
                  const SizedBox(width: AppSpacing.sm),
                  _timeButton(context, 'Close', dayHours.closeTime, 'closeTime'),
                ] else
                  Text('Closed', style: AppTypography.bodySmall.copyWith(color: AppColors.neutral400)),
              ],
            ),
            if (!dayHours.isClosed) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  const SizedBox(width: 100),
                  Text('Break:', style: AppTypography.caption.copyWith(color: AppColors.neutral500)),
                  const SizedBox(width: AppSpacing.sm),
                  _timeButton(context, 'Break start', dayHours.breakStart, 'breakStart', small: true),
                  const SizedBox(width: AppSpacing.sm),
                  Text('–', style: AppTypography.caption),
                  const SizedBox(width: AppSpacing.sm),
                  _timeButton(context, 'Break end', dayHours.breakEnd, 'breakEnd', small: true),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _timeButton(BuildContext context, String label, String? time, String field, {bool small = false}) {
    return InkWell(
      onTap: () => _pickTime(context, field),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: small ? 6 : 10,
          vertical: small ? 3 : 6,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.neutral200),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          time ?? label,
          style: (small ? AppTypography.caption : AppTypography.bodySmall)
              .copyWith(color: time != null ? AppColors.neutral700 : AppColors.neutral400),
        ),
      ),
    );
  }
}
