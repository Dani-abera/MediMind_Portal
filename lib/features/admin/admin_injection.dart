import '../../core/di/service_locator.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/network_info.dart';
import '../../core/network/realtime_service.dart';
import '../../core/storage/preferences_storage.dart';
import '../../core/widgets/shell/bloc/shell_bloc.dart';
import '../../shared/blocs/notification_bloc.dart';
// Data — datasources
import 'data/datasources/admin_appointment_remote_datasource.dart';
import 'data/datasources/admin_dashboard_remote_datasource.dart';
import 'data/datasources/admin_doctor_remote_datasource.dart';
import 'data/datasources/admin_patient_remote_datasource.dart';
import 'data/datasources/admin_queue_remote_datasource.dart';
import 'data/datasources/admin_staff_remote_datasource.dart';
// Data — repositories
import 'data/repositories/admin_appointment_repository_impl.dart';
import 'data/repositories/admin_dashboard_repository_impl.dart';
import 'data/repositories/admin_doctor_repository_impl.dart';
import 'data/repositories/admin_patient_repository_impl.dart';
import 'data/repositories/admin_queue_repository_impl.dart';
import 'data/repositories/admin_staff_repository_impl.dart';
// Domain — repository interfaces
import 'domain/repositories/admin_appointment_repository.dart';
import 'domain/repositories/admin_dashboard_repository.dart';
import 'domain/repositories/admin_doctor_repository.dart';
import 'domain/repositories/admin_patient_repository.dart';
import 'domain/repositories/admin_queue_repository.dart';
import 'domain/repositories/admin_staff_repository.dart';
// Domain — use cases
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
  sl.registerLazySingleton(() => AdminQueueRemoteDataSource(sl<DioClient>()));
  sl.registerLazySingleton(() => AdminAppointmentRemoteDataSource(sl<DioClient>()));
  sl.registerLazySingleton(() => AdminDashboardRemoteDataSource(sl<DioClient>()));
  sl.registerLazySingleton(() => AdminDoctorRemoteDataSource(sl<DioClient>()));
  sl.registerLazySingleton(() => AdminPatientRemoteDataSource(sl<DioClient>()));
  sl.registerLazySingleton(() => AdminStaffRemoteDataSource(sl<DioClient>()));

  // ── Repositories ───────────────────────────────────────────────────────
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
}
