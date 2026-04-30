abstract class RouteNames {
  // Public
  static const String splash = '/splash';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  // Doctor
  static const String doctorRoot = '/doctor';
  static const String doctorDashboard = '/doctor/dashboard';
  static const String doctorAppointments = '/doctor/appointments';
  static const String doctorAppointmentsPending = '/doctor/appointments/pending';
  static const String doctorAppointmentsCalendar = '/doctor/appointments/calendar';
  static const String doctorAppointmentsAll = '/doctor/appointments/all';
  static const String doctorPatients = '/doctor/patients';
  static const String doctorPatientDetail = '/doctor/patients/:id';
  static const String doctorQueue = '/doctor/queue';
  static const String doctorConsultation = '/doctor/consultation/:id';
  static const String doctorProfile = '/doctor/profile';
  static const String doctorSettings = '/doctor/settings';

  // Admin
  static const String adminRoot = '/admin';
  static const String adminDashboard = '/admin/dashboard';
  static const String adminDoctors = '/admin/doctors';
  static const String adminDoctorDetail = '/admin/doctors/:id';
  static const String adminAppointments = '/admin/appointments';
  static const String adminAppointmentsPending = '/admin/appointments/pending';
  static const String adminAppointmentsAll = '/admin/appointments/all';
  static const String adminQueue = '/admin/queue';
  static const String adminPatients = '/admin/patients';
  static const String adminPatientDetail = '/admin/patients/:id';
  static const String adminReports = '/admin/reports';
  static const String adminSettings = '/admin/settings';
  static const String adminProfile = '/admin/profile';

  // SuperAdmin
  static const String superAdminRoot = '/super-admin';
  static const String superAdminDashboard = '/super-admin/dashboard';
  static const String superAdminCenters = '/super-admin/centers';
  static const String superAdminCenterDetail = '/super-admin/centers/:id';
  static const String superAdminDoctors = '/super-admin/doctors';
  static const String superAdminDoctorDetail = '/super-admin/doctors/:id';
  static const String superAdminUsers = '/super-admin/users';
  static const String superAdminSubscriptions = '/super-admin/subscriptions';
  static const String superAdminAnalytics = '/super-admin/analytics';
  static const String superAdminSettings = '/super-admin/settings';
  static const String superAdminProfile = '/super-admin/profile';
}
