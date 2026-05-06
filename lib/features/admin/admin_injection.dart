import '../../core/di/service_locator.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/network_info.dart';
import 'data/datasources/center_settings_remote_datasource.dart';
import 'data/repositories/center_settings_repository_impl.dart';
import 'domain/repositories/center_settings_repository.dart';
import 'domain/usecases/get_center_config_usecase.dart';
import 'domain/usecases/save_center_config_usecase.dart';
import 'domain/usecases/get_working_hours_usecase.dart';
import 'domain/usecases/save_working_hours_usecase.dart';
import 'domain/usecases/get_booking_rules_usecase.dart';
import 'domain/usecases/save_booking_rules_usecase.dart';
import 'domain/usecases/get_center_branding_usecase.dart';
import 'domain/usecases/save_center_branding_usecase.dart';
import 'domain/usecases/upload_center_image_usecase.dart';
import 'presentation/bloc/center_settings/center_settings_bloc.dart';
import 'presentation/bloc/working_hours/working_hours_bloc.dart';
import 'presentation/bloc/booking_rules/booking_rules_bloc.dart';
import 'presentation/bloc/branding/branding_bloc.dart';
import '../../core/network/realtime_service.dart';
import '../../core/storage/preferences_storage.dart';
import '../../core/widgets/shell/bloc/shell_bloc.dart';
import '../../shared/blocs/notification_bloc.dart';
// Data — datasources
import 'data/datasources/admin_appointment_remote_datasource.dart';
import 'data/datasources/admin_dashboard_remote_datasource.dart';
import 'data/datasources/analytics_remote_datasource.dart';
import 'data/datasources/payments_remote_datasource.dart';
import 'data/datasources/audit_log_remote_datasource.dart';
import 'data/datasources/admin_doctor_remote_datasource.dart';
import 'data/datasources/admin_patient_remote_datasource.dart';
import 'data/datasources/admin_queue_remote_datasource.dart';
import 'data/datasources/admin_staff_remote_datasource.dart';
// Data — repositories
import 'data/repositories/analytics_repository_impl.dart';
import 'data/repositories/payments_repository_impl.dart';
import 'data/repositories/audit_log_repository_impl.dart';
import 'data/repositories/admin_appointment_repository_impl.dart';
import 'data/repositories/admin_dashboard_repository_impl.dart';
import 'data/repositories/admin_doctor_repository_impl.dart';
import 'data/repositories/admin_patient_repository_impl.dart';
import 'data/repositories/admin_queue_repository_impl.dart';
import 'data/repositories/admin_staff_repository_impl.dart';
// Domain — repository interfaces
import 'domain/repositories/analytics_repository.dart';
import 'domain/repositories/payments_repository.dart';
import 'domain/repositories/audit_log_repository.dart';
import 'domain/repositories/admin_appointment_repository.dart';
import 'domain/repositories/admin_dashboard_repository.dart';
import 'domain/repositories/admin_doctor_repository.dart';
import 'domain/repositories/admin_patient_repository.dart';
import 'domain/repositories/admin_queue_repository.dart';
import 'domain/repositories/admin_staff_repository.dart';
// Domain — use cases
import 'domain/usecases/get_analytics_summary_usecase.dart';
import 'domain/usecases/get_revenue_summary_usecase.dart';
import 'domain/usecases/get_doctor_analytics_usecase.dart';
import 'domain/usecases/export_analytics_usecase.dart';
import 'domain/usecases/get_payments_usecase.dart';
import 'domain/usecases/get_audit_log_usecase.dart';
import 'domain/usecases/get_admin_queue_usecase.dart';
import 'domain/usecases/call_next_usecase.dart';
import 'domain/usecases/mark_arrived_usecase.dart';
import 'domain/usecases/mark_complete_usecase.dart';
import 'domain/usecases/mark_no_show_usecase.dart';
import 'domain/usecases/skip_queue_usecase.dart';
import 'domain/usecases/insert_emergency_usecase.dart';
import 'domain/usecases/get_queue_stats_usecase.dart';
import 'domain/usecases/get_pending_appointments_usecase.dart';
import 'domain/usecases/get_all_appointments_usecase.dart';
import 'domain/usecases/get_admin_appointment_detail_usecase.dart';
import 'domain/usecases/approve_appointment_usecase.dart';
import 'domain/usecases/reject_appointment_usecase.dart';
import 'domain/usecases/bulk_approve_usecase.dart';
import 'domain/usecases/cancel_appointment_admin_usecase.dart';
import 'domain/usecases/get_admin_dashboard_usecase.dart';
import 'domain/usecases/get_doctors_at_center_usecase.dart';
import 'domain/usecases/add_doctor_to_center_usecase.dart';
import 'domain/usecases/remove_doctor_from_center_usecase.dart';
import 'domain/usecases/configure_doctor_schedule_usecase.dart';
import 'domain/usecases/get_doctor_schedule_usecase.dart';
import 'domain/usecases/delete_doctor_schedule_usecase.dart';
import 'domain/usecases/get_patients_at_center_usecase.dart';
import 'domain/usecases/get_patient_center_detail_usecase.dart';
import 'domain/usecases/get_admins_usecase.dart';
import 'domain/usecases/add_admin_usecase.dart';
import 'domain/usecases/deactivate_admin_usecase.dart';
// Presentation — blocs
import 'presentation/bloc/analytics/analytics_dashboard_bloc.dart';
import 'presentation/bloc/revenue/revenue_bloc.dart';
import 'presentation/bloc/per_doctor/per_doctor_bloc.dart';
import 'presentation/bloc/export_wizard/export_wizard_bloc.dart';
import 'presentation/bloc/payments/payments_ledger_bloc.dart';
import 'presentation/bloc/audit_log/audit_log_bloc.dart';
import 'presentation/bloc/queue/admin_queue_bloc.dart';
import 'presentation/bloc/pending_appointments/pending_appointments_bloc.dart';
import 'presentation/bloc/all_appointments/all_appointments_bloc.dart';
import 'presentation/bloc/appointment_detail/admin_appointment_detail_bloc.dart';
import 'presentation/bloc/dashboard/admin_dashboard_bloc.dart';
import 'presentation/bloc/doctors_roster/doctors_roster_bloc.dart';
import 'presentation/bloc/patient_directory/patient_directory_bloc.dart';
import 'presentation/bloc/patient_detail/patient_center_detail_bloc.dart';
import 'presentation/bloc/admins/admin_staff_bloc.dart';

Future<void> initAdminFeature() async {
  // ── Shell & Notifications ──────────────────────────────────────────────
  if (!sl.isRegistered<ShellBloc>()) {
    sl.registerLazySingleton<ShellBloc>(
      () => ShellBloc(
        prefs: sl<PreferencesStorage>(),
        realtime: sl<RealtimeService>(),
      ),
    );
  }
  if (!sl.isRegistered<NotificationBloc>()) {
    sl.registerLazySingleton<NotificationBloc>(
      () => NotificationBloc(
        client: sl<DioClient>(),
        realtime: sl<RealtimeService>(),
      ),
    );
  }

  // ── Data sources ───────────────────────────────────────────────────────
  sl.registerLazySingleton(() => AnalyticsRemoteDataSource(sl<DioClient>()));
  sl.registerLazySingleton(() => PaymentsRemoteDataSource(sl<DioClient>()));
  sl.registerLazySingleton(() => AuditLogRemoteDataSource(sl<DioClient>()));
  sl.registerLazySingleton(() => AdminQueueRemoteDataSource(sl<DioClient>()));
  sl.registerLazySingleton(() => AdminAppointmentRemoteDataSource(sl<DioClient>()));
  sl.registerLazySingleton(() => AdminDashboardRemoteDataSource(sl<DioClient>()));
  sl.registerLazySingleton(() => AdminDoctorRemoteDataSource(sl<DioClient>()));
  sl.registerLazySingleton(() => AdminPatientRemoteDataSource(sl<DioClient>()));
  sl.registerLazySingleton(() => AdminStaffRemoteDataSource(sl<DioClient>()));

  // ── Repositories ───────────────────────────────────────────────────────
  sl.registerLazySingleton<AnalyticsRepository>(
    () => AnalyticsRepositoryImpl(sl<AnalyticsRemoteDataSource>(), sl<NetworkInfo>()),
  );
  sl.registerLazySingleton<PaymentsRepository>(
    () => PaymentsRepositoryImpl(sl<PaymentsRemoteDataSource>(), sl<NetworkInfo>()),
  );
  sl.registerLazySingleton<AuditLogRepository>(
    () => AuditLogRepositoryImpl(sl<AuditLogRemoteDataSource>(), sl<NetworkInfo>()),
  );
  sl.registerLazySingleton<AdminQueueRepository>(
    () => AdminQueueRepositoryImpl(sl<AdminQueueRemoteDataSource>(), sl<NetworkInfo>()),
  );
  sl.registerLazySingleton<AdminAppointmentRepository>(
    () => AdminAppointmentRepositoryImpl(sl<AdminAppointmentRemoteDataSource>(), sl<NetworkInfo>()),
  );
  sl.registerLazySingleton<AdminDashboardRepository>(
    () => AdminDashboardRepositoryImpl(sl<AdminDashboardRemoteDataSource>(), sl<NetworkInfo>()),
  );
  sl.registerLazySingleton<AdminDoctorRepository>(
    () => AdminDoctorRepositoryImpl(sl<AdminDoctorRemoteDataSource>(), sl<NetworkInfo>()),
  );
  sl.registerLazySingleton<AdminPatientRepository>(
    () => AdminPatientRepositoryImpl(sl<AdminPatientRemoteDataSource>(), sl<NetworkInfo>()),
  );
  sl.registerLazySingleton<AdminStaffRepository>(
    () => AdminStaffRepositoryImpl(sl<AdminStaffRemoteDataSource>(), sl<NetworkInfo>()),
  );

  // ── Use cases — Analytics / Revenue / Payments / Audit ────────────────
  sl.registerLazySingleton(() => GetAnalyticsSummaryUseCase(sl<AnalyticsRepository>()));
  sl.registerLazySingleton(() => GetRevenueSummaryUseCase(sl<AnalyticsRepository>()));
  sl.registerLazySingleton(() => GetDoctorAnalyticsUseCase(sl<AnalyticsRepository>()));
  sl.registerLazySingleton(() => ExportAnalyticsCsvUseCase(sl<AnalyticsRepository>()));
  sl.registerLazySingleton(() => ExportAnalyticsPdfUseCase(sl<AnalyticsRepository>()));
  sl.registerLazySingleton(() => ExportRevenueCsvUseCase(sl<AnalyticsRepository>()));
  sl.registerLazySingleton(() => GetPaymentsUseCase(sl<PaymentsRepository>()));
  sl.registerLazySingleton(() => GetPaymentReceiptUseCase(sl<PaymentsRepository>()));
  sl.registerLazySingleton(() => MarkPaymentResolvedUseCase(sl<PaymentsRepository>()));
  sl.registerLazySingleton(() => GetAuditLogUseCase(sl<AuditLogRepository>()));

  // ── Use cases — Queue ──────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetAdminQueueUseCase(sl<AdminQueueRepository>()));
  sl.registerLazySingleton(() => CallNextUseCase(sl<AdminQueueRepository>()));
  sl.registerLazySingleton(() => MarkArrivedUseCase(sl<AdminQueueRepository>()));
  sl.registerLazySingleton(() => MarkCompleteUseCase(sl<AdminQueueRepository>()));
  sl.registerLazySingleton(() => MarkNoShowUseCase(sl<AdminQueueRepository>()));
  sl.registerLazySingleton(() => SkipQueueUseCase(sl<AdminQueueRepository>()));
  sl.registerLazySingleton(() => InsertEmergencyUseCase(sl<AdminQueueRepository>()));
  sl.registerLazySingleton(() => GetQueueStatsUseCase(sl<AdminQueueRepository>()));

  // ── Use cases — Appointments ───────────────────────────────────────────
  sl.registerLazySingleton(() => GetPendingAppointmentsUseCase(sl<AdminAppointmentRepository>()));
  sl.registerLazySingleton(() => GetAllAppointmentsUseCase(sl<AdminAppointmentRepository>()));
  sl.registerLazySingleton(() => GetAdminAppointmentDetailUseCase(sl<AdminAppointmentRepository>()));
  sl.registerLazySingleton(() => ApproveAppointmentUseCase(sl<AdminAppointmentRepository>()));
  sl.registerLazySingleton(() => RejectAppointmentUseCase(sl<AdminAppointmentRepository>()));
  sl.registerLazySingleton(() => BulkApproveUseCase(sl<AdminAppointmentRepository>()));
  sl.registerLazySingleton(() => CancelAppointmentAdminUseCase(sl<AdminAppointmentRepository>()));

  // ── Use cases — Dashboard ──────────────────────────────────────────────
  sl.registerLazySingleton(() => GetAdminDashboardUseCase(sl<AdminDashboardRepository>()));

  // ── Use cases — Doctors ────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetDoctorsAtCenterUseCase(sl<AdminDoctorRepository>()));
  sl.registerLazySingleton(() => AddDoctorToCenterUseCase(sl<AdminDoctorRepository>()));
  sl.registerLazySingleton(() => RemoveDoctorFromCenterUseCase(sl<AdminDoctorRepository>()));
  sl.registerLazySingleton(() => ConfigureDoctorScheduleUseCase(sl<AdminDoctorRepository>()));
  sl.registerLazySingleton(() => GetDoctorScheduleUseCase(sl<AdminDoctorRepository>()));
  sl.registerLazySingleton(() => DeleteDoctorScheduleUseCase(sl<AdminDoctorRepository>()));

  // ── Use cases — Patients ───────────────────────────────────────────────
  sl.registerLazySingleton(() => GetPatientsAtCenterUseCase(sl<AdminPatientRepository>()));
  sl.registerLazySingleton(() => GetPatientCenterDetailUseCase(sl<AdminPatientRepository>()));

  // ── Use cases — Staff ──────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetAdminsUseCase(sl<AdminStaffRepository>()));
  sl.registerLazySingleton(() => AddAdminUseCase(sl<AdminStaffRepository>()));
  sl.registerLazySingleton(() => DeactivateAdminUseCase(sl<AdminStaffRepository>()));

  // ── BLoCs (factory — new instance per BlocProvider.create call) ────────
  sl.registerFactory(
    () => AnalyticsDashboardBloc(
      getSummary: sl<GetAnalyticsSummaryUseCase>(),
      exportCsv: sl<ExportAnalyticsCsvUseCase>(),
      exportPdf: sl<ExportAnalyticsPdfUseCase>(),
    ),
  );
  sl.registerFactory(
    () => RevenueBloc(
      getRevenue: sl<GetRevenueSummaryUseCase>(),
      exportCsv: sl<ExportRevenueCsvUseCase>(),
    ),
  );
  sl.registerFactory(
    () => PerDoctorBloc(getDoctorAnalytics: sl<GetDoctorAnalyticsUseCase>()),
  );
  sl.registerFactory(
    () => ExportWizardBloc(
      exportAnalyticsCsv: sl<ExportAnalyticsCsvUseCase>(),
      exportAnalyticsPdf: sl<ExportAnalyticsPdfUseCase>(),
      exportRevenueCsv: sl<ExportRevenueCsvUseCase>(),
    ),
  );
  sl.registerFactory(
    () => PaymentsLedgerBloc(
      getPayments: sl<GetPaymentsUseCase>(),
      markResolved: sl<MarkPaymentResolvedUseCase>(),
      getReceipt: sl<GetPaymentReceiptUseCase>(),
    ),
  );
  sl.registerFactory(
    () => AuditLogBloc(getAuditLog: sl<GetAuditLogUseCase>()),
  );
  sl.registerFactory(
    () => AdminDashboardBloc(getDashboardData: sl<GetAdminDashboardUseCase>()),
  );
  sl.registerFactory(
    () => AdminQueueBloc(
      getQueue: sl<GetAdminQueueUseCase>(),
      callNext: sl<CallNextUseCase>(),
      markArrived: sl<MarkArrivedUseCase>(),
      markComplete: sl<MarkCompleteUseCase>(),
      markNoShow: sl<MarkNoShowUseCase>(),
      skip: sl<SkipQueueUseCase>(),
      insertEmergency: sl<InsertEmergencyUseCase>(),
    ),
  );
  sl.registerFactory(
    () => PendingAppointmentsBloc(
      getPending: sl<GetPendingAppointmentsUseCase>(),
      approve: sl<ApproveAppointmentUseCase>(),
      reject: sl<RejectAppointmentUseCase>(),
      bulkApprove: sl<BulkApproveUseCase>(),
    ),
  );
  sl.registerFactory(
    () => AllAppointmentsBloc(
      getAll: sl<GetAllAppointmentsUseCase>(),
      cancel: sl<CancelAppointmentAdminUseCase>(),
    ),
  );
  sl.registerFactory(
    () => AdminAppointmentDetailBloc(
      getDetail: sl<GetAdminAppointmentDetailUseCase>(),
      approve: sl<ApproveAppointmentUseCase>(),
      reject: sl<RejectAppointmentUseCase>(),
      cancel: sl<CancelAppointmentAdminUseCase>(),
    ),
  );
  sl.registerFactory(
    () => DoctorsRosterBloc(
      getDoctors: sl<GetDoctorsAtCenterUseCase>(),
      addDoctor: sl<AddDoctorToCenterUseCase>(),
      removeDoctor: sl<RemoveDoctorFromCenterUseCase>(),
      configureSchedule: sl<ConfigureDoctorScheduleUseCase>(),
      getSchedule: sl<GetDoctorScheduleUseCase>(),
      deleteSchedule: sl<DeleteDoctorScheduleUseCase>(),
    ),
  );
  sl.registerFactory(
    () => PatientDirectoryBloc(getPatients: sl<GetPatientsAtCenterUseCase>()),
  );
  sl.registerFactory(
    () => PatientCenterDetailBloc(getDetail: sl<GetPatientCenterDetailUseCase>()),
  );
  sl.registerFactory(
    () => AdminStaffBloc(
      getAdmins: sl<GetAdminsUseCase>(),
      addAdmin: sl<AddAdminUseCase>(),
      deactivate: sl<DeactivateAdminUseCase>(),
    ),
  );

  sl.registerLazySingleton(() => CenterSettingsRemoteDataSource(sl<DioClient>()));
  sl.registerLazySingleton<CenterSettingsRepository>(
    () => CenterSettingsRepositoryImpl(sl<CenterSettingsRemoteDataSource>(), sl<NetworkInfo>()),
  );
  sl.registerLazySingleton(() => GetCenterConfigUseCase(sl<CenterSettingsRepository>()));
  sl.registerLazySingleton(() => SaveCenterConfigUseCase(sl<CenterSettingsRepository>()));
  sl.registerLazySingleton(() => GetWorkingHoursUseCase(sl<CenterSettingsRepository>()));
  sl.registerLazySingleton(() => SaveWorkingHoursUseCase(sl<CenterSettingsRepository>()));
  sl.registerLazySingleton(() => GetBookingRulesUseCase(sl<CenterSettingsRepository>()));
  sl.registerLazySingleton(() => SaveBookingRulesUseCase(sl<CenterSettingsRepository>()));
  sl.registerLazySingleton(() => GetCenterBrandingUseCase(sl<CenterSettingsRepository>()));
  sl.registerLazySingleton(() => SaveCenterBrandingUseCase(sl<CenterSettingsRepository>()));
  sl.registerLazySingleton(() => UploadCenterImageUseCase(sl<CenterSettingsRepository>()));
  sl.registerFactory(() => CenterSettingsBloc(
    getCenterConfig: sl<GetCenterConfigUseCase>(),
    saveCenterConfig: sl<SaveCenterConfigUseCase>(),
  ));
  sl.registerFactory(() => WorkingHoursBloc(
    getWorkingHours: sl<GetWorkingHoursUseCase>(),
    saveWorkingHours: sl<SaveWorkingHoursUseCase>(),
  ));
  sl.registerFactory(() => BookingRulesBloc(
    getBookingRules: sl<GetBookingRulesUseCase>(),
    saveBookingRules: sl<SaveBookingRulesUseCase>(),
  ));
  sl.registerFactory(() => BrandingBloc(
    getCenterBranding: sl<GetCenterBrandingUseCase>(),
    saveCenterBranding: sl<SaveCenterBrandingUseCase>(),
    uploadCenterImage: sl<UploadCenterImageUseCase>(),
  ));
}
