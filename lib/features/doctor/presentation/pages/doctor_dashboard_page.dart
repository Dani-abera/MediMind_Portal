import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/cards/kpi_card.dart';
import '../../../../core/widgets/feedback/app_loading.dart';
import '../../../../core/widgets/shell/page_header.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/usecases/get_dashboard_data_usecase.dart';
import '../bloc/dashboard/dashboard_bloc.dart';

class DoctorDashboardPage extends StatelessWidget {
  const DoctorDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DashboardBloc>()..add(const DashboardStarted()),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Dashboard',
          subtitle: 'Welcome back, Doctor',
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, size: 18),
              tooltip: 'Refresh',
              onPressed: () =>
                  context.read<DashboardBloc>().add(const DashboardRefreshed()),
            ),
          ],
        ),
        Expanded(
          child: BlocBuilder<DashboardBloc, DashboardState>(
            builder: (ctx, state) {
              if (state is DashboardLoading || state is DashboardInitial) {
                return const _DashboardSkeleton();
              }
              if (state is DashboardError) {
                return AppErrorState(
                  message: state.message,
                  onRetry: () =>
                      ctx.read<DashboardBloc>().add(const DashboardRefreshed()),
                );
              }
              if (state is DashboardLoaded) {
                return _DashboardContent(data: state.data);
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final DashboardData data;
  const _DashboardContent({required this.data});

  @override
  Widget build(BuildContext context) {
    final summary = data.todaySummary;
    final total = summary['total'] as int? ?? 0;
    final completed = summary['completed'] as int? ?? 0;
    final inProgress = summary['inProgress'] as int? ?? 0;
    final pending = summary['pending'] as int? ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _KPIRow(
            total: total,
            pending: pending,
            inProgress: inProgress,
            completed: completed,
          ),
          const SizedBox(height: 24),
          _TodayScheduleCard(appointments: data.todayAppointments),
        ],
      ),
    );
  }
}

class _KPIRow extends StatelessWidget {
  final int total;
  final int pending;
  final int inProgress;
  final int completed;

  const _KPIRow({
    required this.total,
    required this.pending,
    required this.inProgress,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: KPICard(
            icon: FontAwesomeIcons.calendarDay,
            title: "Today's Appointments",
            value: '$total',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: KPICard(
            icon: FontAwesomeIcons.clock,
            title: 'Pending',
            value: '$pending',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: KPICard(
            icon: FontAwesomeIcons.spinner,
            title: 'In Progress',
            value: '$inProgress',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: KPICard(
            icon: FontAwesomeIcons.circleCheck,
            title: 'Completed Today',
            value: '$completed',
          ),
        ),
      ],
    );
  }
}

class _TodayScheduleCard extends StatelessWidget {
  final List<Appointment> appointments;
  const _TodayScheduleCard({required this.appointments});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              "Today's Schedule",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const Divider(height: 1),
          if (appointments.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: AppEmptyState(
                message: 'No appointments today',
                description: 'Your schedule is clear for today.',
                icon: Icons.calendar_today_outlined,
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: appointments.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (ctx, i) =>
                  _AppointmentListTile(appointment: appointments[i]),
            ),
        ],
      ),
    );
  }
}

class _AppointmentListTile extends StatelessWidget {
  final Appointment appointment;
  const _AppointmentListTile({required this.appointment});

  @override
  Widget build(BuildContext context) {
    final initial = appointment.patientName.isNotEmpty
        ? appointment.patientName[0].toUpperCase()
        : '?';
    final timeStr =
        '${appointment.dateTime.hour.toString().padLeft(2, '0')}:${appointment.dateTime.minute.toString().padLeft(2, '0')}';

    final status = appointment.status;
    Color statusColor;
    switch (status) {
      case AppointmentStatus.confirmed:
        statusColor = AppColors.success;
      case AppointmentStatus.pending:
        statusColor = AppColors.warning;
      case AppointmentStatus.inProgress:
        statusColor = AppColors.primary;
      case AppointmentStatus.cancelled:
      case AppointmentStatus.noShow:
        statusColor = AppColors.danger;
      case AppointmentStatus.completed:
        statusColor = AppColors.neutral500;
    }

    return ListTile(
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: AppColors.primaryLight,
        child: Text(
          initial,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
      title: Text(
        appointment.patientName,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      subtitle: Text(
        appointment.reason.isEmpty ? 'General Consultation' : appointment.reason,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(timeStr, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(20),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              status.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(4, (i) => i)
                .expand((i) => [
                      const Expanded(
                        child: AppShimmerBox(height: 100, radius: 8),
                      ),
                      if (i < 3) const SizedBox(width: 16),
                    ])
                .toList(),
          ),
          const SizedBox(height: 24),
          const AppShimmerBox(height: 320, radius: 8),
        ],
      ),
    );
  }
}
