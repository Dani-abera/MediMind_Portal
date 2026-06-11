import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medimind_portal/core/utils/fa_compat.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/feedback/app_loading.dart';
import '../../../../core/widgets/shell/page_header.dart';
import '../../domain/entities/doctor_schedule.dart';
import '../bloc/schedule/schedule_bloc.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ScheduleBloc>()..add(const ScheduleStarted()),
      child: const _ScheduleView(),
    );
  }
}

class _ScheduleView extends StatelessWidget {
  const _ScheduleView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PageHeader(
          title: 'My Schedule',
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, size: 18),
              onPressed: () =>
                  context.read<ScheduleBloc>().add(const ScheduleRefreshed()),
            ),
          ],
        ),
        Expanded(
          child: BlocBuilder<ScheduleBloc, ScheduleState>(
            builder: (ctx, state) {
              if (state is ScheduleLoading || state is ScheduleInitial) {
                return const Center(child: AppLoadingSpinner());
              }
              if (state is ScheduleError) {
                return AppErrorState(
                  message: state.message,
                  onRetry: () =>
                      ctx.read<ScheduleBloc>().add(const ScheduleRefreshed()),
                );
              }
              if (state is ScheduleLoaded) {
                if (state.schedules.isEmpty) {
                  return const AppEmptyState(
                    message: 'No schedules configured',
                    description: 'Contact an admin to set up your schedule.',
                    icon: Icons.calendar_month_outlined,
                  );
                }
                return _ScheduleList(schedules: state.schedules);
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}

class _ScheduleList extends StatelessWidget {
  final List<DoctorSchedule> schedules;
  const _ScheduleList({required this.schedules});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.xl),
      itemCount: schedules.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (ctx, i) => _ScheduleCard(schedule: schedules[i]),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final DoctorSchedule schedule;
  const _ScheduleCard({required this.schedule});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(FontAwesomeIcons.hospital,
                  size: 14, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(schedule.centerName, style: AppTypography.h3),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(15),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  schedule.hoursLabel,
                  style: AppTypography.caption.copyWith(
                      color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(FontAwesomeIcons.calendarWeek,
                  size: 12, color: AppColors.neutral400),
              const SizedBox(width: 8),
              Wrap(
                spacing: 6,
                children: DayOfWeek.values.map((day) {
                  final isActive = schedule.workingDays.contains(day);
                  return Container(
                    width: 36,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary
                          : AppColors.neutral100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        day.shortName,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isActive ? Colors.white : AppColors.neutral400,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(FontAwesomeIcons.clock,
                  size: 12, color: AppColors.neutral400),
              const SizedBox(width: 8),
              Text(
                'Slot duration: ${schedule.slotDurationMinutes} min',
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.neutral500),
              ),
            ],
          ),
          if (schedule.breaks.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(FontAwesomeIcons.pause,
                    size: 12, color: AppColors.neutral400),
                const SizedBox(width: 8),
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: schedule.breaks
                        .map((b) => Text(
                              '${b.label} (${b.durationMinutes}min)',
                              style: AppTypography.caption
                                  .copyWith(color: AppColors.neutral500),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
