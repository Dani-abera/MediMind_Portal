import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/cards/kpi_card.dart';
import '../../../../core/widgets/shell/page_header.dart';

class SuperAdminDashboardPage extends StatelessWidget {
  const SuperAdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const PageHeader(
          title: 'Dashboard',
          subtitle: 'System-wide overview',
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
                        icon: FontAwesomeIcons.hospital,
                        title: 'Health Centers',
                        value: '47',
                        trend: '+3',
                        trendDirection: TrendDirection.up,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: KPICard(
                        icon: FontAwesomeIcons.userDoctor,
                        title: 'Total Doctors',
                        value: '312',
                        trend: '+18',
                        trendDirection: TrendDirection.up,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: KPICard(
                        icon: FontAwesomeIcons.userGroup,
                        title: 'Total Patients',
                        value: '98,421',
                        trend: '+2.1%',
                        trendDirection: TrendDirection.up,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: KPICard(
                        icon: FontAwesomeIcons.creditCard,
                        title: 'Active Subscriptions',
                        value: '41',
                        trend: '-2',
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
