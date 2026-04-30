import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/cards/kpi_card.dart';
import '../../../../core/widgets/shell/page_header.dart';

class DoctorDashboardPage extends StatelessWidget {
  const DoctorDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeader(
          title: 'Dashboard',
          subtitle: 'Welcome back, Doctor',
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildKPIRow(),
                const SizedBox(height: 24),
                _buildTodayAppointments(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKPIRow() {
    return const Row(
      children: [
        Expanded(
          child: KPICard(
            icon: FontAwesomeIcons.calendarDay,
            title: "Today's Appointments",
            value: '12',
            trend: '+2',
            trendDirection: TrendDirection.up,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: KPICard(
            icon: FontAwesomeIcons.clock,
            title: 'Pending',
            value: '5',
            trend: '-1',
            trendDirection: TrendDirection.down,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: KPICard(
            icon: FontAwesomeIcons.userGroup,
            title: 'Total Patients',
            value: '248',
            trend: '+8',
            trendDirection: TrendDirection.up,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: KPICard(
            icon: FontAwesomeIcons.circleCheck,
            title: 'Completed Today',
            value: '7',
          ),
        ),
      ],
    );
  }

  Widget _buildTodayAppointments(BuildContext context) {
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
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text("Today's Schedule",
                style: Theme.of(context).textTheme.headlineSmall),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (ctx, i) => _AppointmentListTile(index: i),
          ),
        ],
      ),
    );
  }
}

class _AppointmentListTile extends StatelessWidget {
  final int index;
  const _AppointmentListTile({required this.index});

  @override
  Widget build(BuildContext context) {
    final times = ['08:00', '09:30', '10:00', '11:30', '14:00'];
    final names = [
      'Abebe Kebede',
      'Sara Alemu',
      'Michael Tadesse',
      'Feven Girma',
      'Daniel Haile',
    ];
    final statuses = ['Confirmed', 'Pending', 'Confirmed', 'Cancelled', 'Confirmed'];

    return ListTile(
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: AppColors.primaryLight,
        child: Text(
          names[index][0],
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
      title: Text(names[index],
          style: Theme.of(context).textTheme.bodyMedium),
      subtitle: Text('General Consultation',
          style: Theme.of(context).textTheme.bodySmall),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(times[index],
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statuses[index] == 'Confirmed'
                  ? AppColors.success.withAlpha(20)
                  : statuses[index] == 'Pending'
                      ? AppColors.warning.withAlpha(20)
                      : AppColors.danger.withAlpha(20),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              statuses[index],
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: statuses[index] == 'Confirmed'
                    ? AppColors.success
                    : statuses[index] == 'Pending'
                        ? AppColors.warning
                        : AppColors.danger,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
