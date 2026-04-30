import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/shell/sidebar.dart';
import 'route_names.dart';

abstract class SidebarConfigs {
  static List<SidebarItem> get doctor => [
        SidebarItem(
          label: 'Dashboard',
          icon: FontAwesomeIcons.gaugeHigh,
          route: RouteNames.doctorDashboard,
        ),
        SidebarItem(
          label: 'Appointments',
          icon: FontAwesomeIcons.calendarCheck,
          route: RouteNames.doctorAppointmentsPending,
          children: [
            SidebarItem(
              label: 'Pending',
              icon: FontAwesomeIcons.clock,
              route: RouteNames.doctorAppointmentsPending,
            ),
            SidebarItem(
              label: 'Calendar',
              icon: FontAwesomeIcons.calendarDays,
              route: RouteNames.doctorAppointmentsCalendar,
            ),
            SidebarItem(
              label: 'All',
              icon: FontAwesomeIcons.listUl,
              route: RouteNames.doctorAppointmentsAll,
            ),
          ],
        ),
        SidebarItem(
          label: 'Patients',
          icon: FontAwesomeIcons.userGroup,
          route: RouteNames.doctorPatients,
        ),
        SidebarItem(
          label: 'Queue',
          icon: FontAwesomeIcons.listOl,
          route: RouteNames.doctorQueue,
        ),
        SidebarItem(
          label: 'Settings',
          icon: FontAwesomeIcons.gear,
          route: RouteNames.doctorSettings,
        ),
      ];

  static List<SidebarItem> get admin => [
        SidebarItem(
          label: 'Dashboard',
          icon: FontAwesomeIcons.gaugeHigh,
          route: RouteNames.adminDashboard,
        ),
        SidebarItem(
          label: 'Doctors',
          icon: FontAwesomeIcons.userDoctor,
          route: RouteNames.adminDoctors,
        ),
        SidebarItem(
          label: 'Appointments',
          icon: FontAwesomeIcons.calendarCheck,
          route: RouteNames.adminAppointmentsPending,
          children: [
            SidebarItem(
              label: 'Pending',
              icon: FontAwesomeIcons.clock,
              route: RouteNames.adminAppointmentsPending,
            ),
            SidebarItem(
              label: 'All',
              icon: FontAwesomeIcons.listUl,
              route: RouteNames.adminAppointmentsAll,
            ),
          ],
        ),
        SidebarItem(
          label: 'Queue',
          icon: FontAwesomeIcons.listOl,
          route: RouteNames.adminQueue,
        ),
        SidebarItem(
          label: 'Patients',
          icon: FontAwesomeIcons.userGroup,
          route: RouteNames.adminPatients,
        ),
        SidebarItem(
          label: 'Reports',
          icon: FontAwesomeIcons.chartBar,
          route: RouteNames.adminReports,
        ),
        SidebarItem(
          label: 'Settings',
          icon: FontAwesomeIcons.gear,
          route: RouteNames.adminSettings,
        ),
      ];

  static List<SidebarItem> get superAdmin => [
        SidebarItem(
          label: 'Dashboard',
          icon: FontAwesomeIcons.gaugeHigh,
          route: RouteNames.superAdminDashboard,
        ),
        SidebarItem(
          label: 'Centers',
          icon: FontAwesomeIcons.hospital,
          route: RouteNames.superAdminCenters,
        ),
        SidebarItem(
          label: 'Doctors',
          icon: FontAwesomeIcons.userDoctor,
          route: RouteNames.superAdminDoctors,
        ),
        SidebarItem(
          label: 'Subscriptions',
          icon: FontAwesomeIcons.creditCard,
          route: RouteNames.superAdminSubscriptions,
        ),
        SidebarItem(
          label: 'Analytics',
          icon: FontAwesomeIcons.chartLine,
          route: RouteNames.superAdminAnalytics,
        ),
        SidebarItem(
          label: 'Settings',
          icon: FontAwesomeIcons.gear,
          route: RouteNames.superAdminSettings,
        ),
      ];
}
