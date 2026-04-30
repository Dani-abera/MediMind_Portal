import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/cards/kpi_card.dart';
import '../../../../core/widgets/shell/page_header.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const PageHeader(
          title: 'Dashboard',
          subtitle: 'Health Center Overview',
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                const Row(
                  children: [
                    Expanded(
                      child: KPICard(
                        icon: FontAwesomeIcons.userDoctor,
                        title: 'Active Doctors',
                        value: '18',
                        trend: '+2',
                        trendDirection: TrendDirection.up,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: KPICard(
                        icon: FontAwesomeIcons.calendarCheck,
                        title: "Today's Appointments",
                        value: '142',
                        trend: '+12',
                        trendDirection: TrendDirection.up,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: KPICard(
                        icon: FontAwesomeIcons.userGroup,
                        title: 'Total Patients',
                        value: '4,821',
                        trend: '+56',
                        trendDirection: TrendDirection.up,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: KPICard(
                        icon: FontAwesomeIcons.listOl,
                        title: 'Queue Length',
                        value: '23',
                        trend: '-5',
                        trendDirection: TrendDirection.down,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
