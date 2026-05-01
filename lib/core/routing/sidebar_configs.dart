import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/shell/sidebar.dart';
import 'route_names.dart';

abstract class SidebarConfigs {
  // ── Doctor ───────────────────────────────────────────────────────────────
  static List<SidebarItem> get doctor => [
        const SidebarItem(
          label: 'Dashboard',
          icon: FontAwesomeIcons.house,
          route: RouteNames.doctorDashboard,
        ),
        const SidebarItem(
          label: "Today's Queue",
          icon: FontAwesomeIcons.peopleGroup,
          route: RouteNames.doctorQueue,
        ),
        SidebarItem(
          label: 'Appointments',
          icon: FontAwesomeIcons.calendarCheck,
          route: RouteNames.doctorAppointmentsCalendar,
          children: const [
            SidebarItem(
              label: 'Calendar View',
              icon: FontAwesomeIcons.calendarDays,
              route: RouteNames.doctorAppointmentsCalendar,
            ),
            SidebarItem(
              label: 'List View',
              icon: FontAwesomeIcons.listUl,
              route: RouteNames.doctorAppointmentsList,
            ),
          ],
        ),
        const SidebarItem(
          label: 'My Patients',
          icon: FontAwesomeIcons.userInjured,
          route: RouteNames.doctorPatients,
        ),
        const SidebarItem(
          label: 'Consultations',
          icon: FontAwesomeIcons.video,
          route: RouteNames.doctorConsultations,
        ),
        SidebarItem(
          label: 'Prescriptions',
          icon: FontAwesomeIcons.prescription,
          route: RouteNames.doctorPrescriptions,
          children: const [
            SidebarItem(
              label: 'All',
              icon: FontAwesomeIcons.listUl,
              route: RouteNames.doctorPrescriptions,
            ),
            SidebarItem(
              label: 'Templates',
              icon: FontAwesomeIcons.fileLines,
              route: RouteNames.doctorPrescriptionsTemplates,
            ),
            SidebarItem(
              label: 'Create New',
              icon: FontAwesomeIcons.plus,
              route: RouteNames.doctorPrescriptionsNew,
            ),
          ],
        ),
        const SidebarItem(
          label: 'My Schedule',
          icon: FontAwesomeIcons.clock,
          route: RouteNames.doctorSchedule,
        ),
        const SidebarItem(isDivider: true, label: '', icon: FontAwesomeIcons.minus, route: ''),
        const SidebarItem(
          label: 'Profile',
          icon: FontAwesomeIcons.user,
          route: RouteNames.doctorProfile,
        ),
        const SidebarItem(
          label: 'Settings',
          icon: FontAwesomeIcons.gear,
          route: RouteNames.doctorSettings,
        ),
      ];

  // ── Admin ────────────────────────────────────────────────────────────────
  static List<SidebarItem> get admin => [
        const SidebarItem(
          label: 'Dashboard',
          icon: FontAwesomeIcons.gaugeHigh,
          route: RouteNames.adminDashboard,
        ),
        const SidebarItem(
          label: 'Live Queue',
          icon: FontAwesomeIcons.peopleGroup,
          route: RouteNames.adminQueue,
        ),
        SidebarItem(
          label: 'Appointments',
          icon: FontAwesomeIcons.calendar,
          route: RouteNames.adminAppointmentsPending,
          children: const [
            SidebarItem(
              label: 'Pending',
              icon: FontAwesomeIcons.clock,
              route: RouteNames.adminAppointmentsPending,
            ),
            SidebarItem(
              label: 'Calendar',
              icon: FontAwesomeIcons.calendarDays,
              route: RouteNames.adminAppointmentsCalendar,
            ),
            SidebarItem(
              label: 'All',
              icon: FontAwesomeIcons.listUl,
              route: RouteNames.adminAppointmentsList,
            ),
          ],
        ),
        const SidebarItem(
          label: 'Doctors',
          icon: FontAwesomeIcons.userDoctor,
          route: RouteNames.adminDoctors,
        ),
        const SidebarItem(
          label: 'Patients',
          icon: FontAwesomeIcons.hospitalUser,
          route: RouteNames.adminPatients,
        ),
        const SidebarItem(
          label: 'Payments',
          icon: FontAwesomeIcons.moneyBill,
          route: RouteNames.adminPayments,
        ),
        const SidebarItem(
          label: 'Prescriptions',
          icon: FontAwesomeIcons.prescription,
          route: RouteNames.adminPrescriptions,
        ),
        SidebarItem(
          label: 'Analytics',
          icon: FontAwesomeIcons.chartLine,
          route: RouteNames.adminAnalyticsDashboard,
          children: const [
            SidebarItem(
              label: 'Overview',
              icon: FontAwesomeIcons.gaugeHigh,
              route: RouteNames.adminAnalyticsDashboard,
            ),
            SidebarItem(
              label: 'Revenue',
              icon: FontAwesomeIcons.moneyBill,
              route: RouteNames.adminAnalyticsRevenue,
            ),
            SidebarItem(
              label: 'Per-Doctor',
              icon: FontAwesomeIcons.userDoctor,
              route: RouteNames.adminAnalyticsDoctors,
            ),
            SidebarItem(
              label: 'Export',
              icon: FontAwesomeIcons.fileExport,
              route: RouteNames.adminAnalyticsExport,
            ),
          ],
        ),
        const SidebarItem(
          label: 'Staff & Admins',
          icon: FontAwesomeIcons.usersGear,
          route: RouteNames.adminAdmins,
        ),
        const SidebarItem(
          label: 'Audit Log',
          icon: FontAwesomeIcons.clockRotateLeft,
          route: RouteNames.adminAuditLog,
        ),
        const SidebarItem(isDivider: true, label: '', icon: FontAwesomeIcons.minus, route: ''),
        SidebarItem(
          label: 'Center Settings',
          icon: FontAwesomeIcons.building,
          route: RouteNames.adminSettingsCenter,
          children: const [
            SidebarItem(
              label: 'General',
              icon: FontAwesomeIcons.gear,
              route: RouteNames.adminSettingsCenter,
            ),
            SidebarItem(
              label: 'Branding',
              icon: FontAwesomeIcons.palette,
              route: RouteNames.adminSettingsBranding,
            ),
            SidebarItem(
              label: 'Working Hours',
              icon: FontAwesomeIcons.clock,
              route: RouteNames.adminSettingsHours,
            ),
            SidebarItem(
              label: 'Booking Rules',
              icon: FontAwesomeIcons.calendarCheck,
              route: RouteNames.adminSettingsBooking,
            ),
          ],
        ),
        const SidebarItem(
          label: 'Profile',
          icon: FontAwesomeIcons.user,
          route: RouteNames.adminProfile,
        ),
      ];

  // ── SuperAdmin ───────────────────────────────────────────────────────────
  static List<SidebarItem> get superAdmin => [
        const SidebarItem(
          label: 'Platform Dashboard',
          icon: FontAwesomeIcons.globe,
          route: RouteNames.superAdminDashboard,
        ),
        SidebarItem(
          label: 'Centers',
          icon: FontAwesomeIcons.hospital,
          route: RouteNames.superAdminCenters,
          children: const [
            SidebarItem(
              label: 'All Centers',
              icon: FontAwesomeIcons.listUl,
              route: RouteNames.superAdminCenters,
            ),
            SidebarItem(
              label: 'Pending Approval',
              icon: FontAwesomeIcons.clock,
              route: RouteNames.superAdminCentersPending,
            ),
            SidebarItem(
              label: 'Suspended',
              icon: FontAwesomeIcons.ban,
              route: RouteNames.superAdminCentersSuspended,
            ),
          ],
        ),
        SidebarItem(
          label: 'Doctors',
          icon: FontAwesomeIcons.userDoctor,
          route: RouteNames.superAdminDoctors,
          children: const [
            SidebarItem(
              label: 'All',
              icon: FontAwesomeIcons.listUl,
              route: RouteNames.superAdminDoctors,
            ),
            SidebarItem(
              label: 'Pending Verification',
              icon: FontAwesomeIcons.hourglassHalf,
              route: RouteNames.superAdminDoctorsPending,
            ),
          ],
        ),
        const SidebarItem(
          label: 'Users',
          icon: FontAwesomeIcons.users,
          route: RouteNames.superAdminUsers,
        ),
        const SidebarItem(
          label: 'Subscriptions',
          icon: FontAwesomeIcons.creditCard,
          route: RouteNames.superAdminSubscriptions,
        ),
        SidebarItem(
          label: 'Analytics',
          icon: FontAwesomeIcons.chartLine,
          route: RouteNames.superAdminAnalyticsDashboard,
          children: const [
            SidebarItem(
              label: 'Platform Overview',
              icon: FontAwesomeIcons.gaugeHigh,
              route: RouteNames.superAdminAnalyticsDashboard,
            ),
            SidebarItem(
              label: 'Revenue',
              icon: FontAwesomeIcons.moneyBill,
              route: RouteNames.superAdminAnalyticsRevenue,
            ),
            SidebarItem(
              label: 'Growth',
              icon: FontAwesomeIcons.arrowTrendUp,
              route: RouteNames.superAdminAnalyticsGrowth,
            ),
          ],
        ),
        const SidebarItem(
          label: 'Audit Log',
          icon: FontAwesomeIcons.clockRotateLeft,
          route: RouteNames.superAdminAuditLog,
        ),
        const SidebarItem(isDivider: true, label: '', icon: FontAwesomeIcons.minus, route: ''),
        const SidebarItem(
          label: 'Platform Settings',
          icon: FontAwesomeIcons.gear,
          route: RouteNames.superAdminSettings,
        ),
        const SidebarItem(
          label: 'Profile',
          icon: FontAwesomeIcons.user,
          route: RouteNames.superAdminProfile,
        ),
      ];
}
