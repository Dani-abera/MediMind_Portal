abstract class RouteNames {
  // Public
  static const String splash = '/splash';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  // ── Doctor ───────────────────────────────────────────────────────────────
  static const String doctorRoot = '/doctor';
  static const String doctorDashboard = '/doctor/dashboard';
  static const String doctorQueue = '/doctor/queue';
  static const String doctorAppointments = '/doctor/appointments';
  static const String doctorAppointmentsCalendar =
      '/doctor/appointments/calendar';
  static const String doctorAppointmentsList = '/doctor/appointments/list';
  static const String doctorPatients = '/doctor/patients';
  static const String doctorPatientDetail = '/doctor/patients/:id';
  static const String doctorConsultations = '/doctor/consultations';
  static const String doctorConsultationDetail = '/doctor/consultation/:id';
  static const String doctorVideoCall = '/doctor/video-call/:id';
  static const String doctorPrescriptions = '/doctor/prescriptions';
  static const String doctorPrescriptionsTemplates =
      '/doctor/prescriptions/templates';
  static const String doctorPrescriptionsNew = '/doctor/prescriptions/new';
  static const String doctorSchedule = '/doctor/schedule';
  static const String doctorProfile = '/doctor/profile';
  static const String doctorSettings = '/doctor/settings';
  static const String doctorNotifications = '/doctor/notifications';

  // ── Admin ────────────────────────────────────────────────────────────────
  static const String adminRoot = '/admin';
  static const String adminDashboard = '/admin/dashboard';
  static const String adminRegisterCenter = '/admin/register-center';
  static const String adminPendingApproval = '/admin/pending-approval';
  static const String adminCenterRejected = '/admin/center-rejected';
  static const String adminCenterSuspended = '/admin/center-suspended';
  static const String adminQueue = '/admin/queue';
  static const String adminAppointments = '/admin/appointments';
  static const String adminAppointmentsPending = '/admin/appointments/pending';
  static const String adminAppointmentsCalendar =
      '/admin/appointments/calendar';
  static const String adminAppointmentsList = '/admin/appointments/list';
  static const String adminDoctors = '/admin/doctors';
  static const String adminDoctorDetail = '/admin/doctors/:id';
  static const String adminPatients = '/admin/patients';
  static const String adminPatientDetail = '/admin/patients/:id';
  static const String adminPayments = '/admin/payments';
  static const String adminAnalytics = '/admin/analytics';
  static const String adminAnalyticsDashboard = '/admin/analytics/dashboard';
  static const String adminAnalyticsRevenue = '/admin/analytics/revenue';
  static const String adminAnalyticsDoctors = '/admin/analytics/doctors';
  static const String adminAnalyticsExport = '/admin/analytics/export';
  static const String adminAdmins = '/admin/admins';
  static const String adminAuditLog = '/admin/audit-log';
  static const String adminSettings = '/admin/settings';
  static const String adminSettingsCenter = '/admin/settings/center';
  static const String adminSettingsBranding = '/admin/settings/branding';
  static const String adminSettingsHours = '/admin/settings/hours';
  static const String adminSettingsBooking = '/admin/settings/booking';
  static const String adminProfile = '/admin/profile';
  static const String adminNotifications = '/admin/notifications';

  // ── SuperAdmin ───────────────────────────────────────────────────────────
  static const String superAdminRoot = '/super-admin';
  static const String superAdminDashboard = '/super-admin/dashboard';
  static const String superAdminCenters = '/super-admin/centers';
  static const String superAdminCentersPending = '/super-admin/centers/pending';
  static const String superAdminCentersSuspended =
      '/super-admin/centers/suspended';
  static const String superAdminCenterDetail = '/super-admin/centers/:id';
  static const String superAdminDoctors = '/super-admin/doctors';
  static const String superAdminDoctorsPending = '/super-admin/doctors/pending';
  static const String superAdminDoctorDetail = '/super-admin/doctors/:id';
  static const String superAdminUsers = '/super-admin/users';
  static const String superAdminSubscriptions = '/super-admin/subscriptions';
  static const String superAdminAnalytics = '/super-admin/analytics';
  static const String superAdminAnalyticsDashboard =
      '/super-admin/analytics/dashboard';
  static const String superAdminAnalyticsRevenue =
      '/super-admin/analytics/revenue';
  static const String superAdminAnalyticsGrowth =
      '/super-admin/analytics/growth';
  static const String superAdminAuditLog = '/super-admin/audit-log';
  static const String superAdminSettings = '/super-admin/settings';
  static const String superAdminProfile = '/super-admin/profile';
  static const String superAdminNotifications = '/super-admin/notifications';
}
