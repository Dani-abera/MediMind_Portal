import '../../core/di/service_locator.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/network_info.dart';
import '../../core/network/realtime_service.dart';
import '../../core/storage/preferences_storage.dart';
import '../../core/widgets/shell/bloc/shell_bloc.dart';
import '../../shared/blocs/notification_bloc.dart';
// Data
import 'data/datasources/appointment_remote_datasource.dart';
import 'data/datasources/consultation_remote_datasource.dart';
import 'data/datasources/doctor_remote_datasource.dart';
import 'data/datasources/patient_remote_datasource.dart';
import 'data/datasources/prescription_remote_datasource.dart';
import 'data/repositories/appointment_repository_impl.dart';
import 'data/repositories/consultation_repository_impl.dart';
import 'data/repositories/doctor_repository_impl.dart';
import 'data/repositories/patient_repository_impl.dart';
import 'data/repositories/prescription_repository_impl.dart';
// Domain
import 'domain/repositories/appointment_repository.dart';
import 'domain/repositories/consultation_repository.dart';
import 'domain/repositories/doctor_repository.dart';
import 'domain/repositories/patient_repository.dart';
import 'domain/repositories/prescription_repository.dart';
import 'domain/usecases/create_prescription_usecase.dart';
import 'domain/usecases/get_appointment_detail_usecase.dart';
import 'domain/usecases/get_appointments_usecase.dart';
import 'domain/usecases/get_dashboard_data_usecase.dart';
import 'domain/usecases/get_doctor_profile_usecase.dart';
import 'domain/usecases/get_doctor_schedules_usecase.dart';
import 'domain/usecases/get_patient_detail_usecase.dart';
import 'domain/usecases/get_patients_usecase.dart';
import 'domain/usecases/get_prescription_templates_usecase.dart';
import 'domain/usecases/get_prescriptions_usecase.dart';
import 'domain/usecases/get_queue_usecase.dart';
import 'domain/usecases/initiate_consultation_usecase.dart';
import 'domain/usecases/save_appointment_note_usecase.dart';
// BLoCs
import 'presentation/bloc/appointment_detail/appointment_detail_bloc.dart';
import 'presentation/bloc/appointment_list/appointment_list_bloc.dart';
import 'presentation/bloc/consultation/consultation_bloc.dart';
import 'presentation/bloc/create_prescription/create_prescription_bloc.dart';
import 'presentation/bloc/dashboard/dashboard_bloc.dart';
import 'presentation/bloc/patient_detail/patient_detail_bloc.dart';
import 'presentation/bloc/patient_list/patient_list_bloc.dart';
import 'presentation/bloc/prescription_detail/prescription_detail_bloc.dart';
import 'presentation/bloc/prescription_list/prescription_list_bloc.dart';
import 'presentation/bloc/prescription_templates/prescription_templates_bloc.dart';
import 'presentation/bloc/profile/profile_bloc.dart';
import 'presentation/bloc/queue/queue_bloc.dart';
import 'presentation/bloc/schedule/schedule_bloc.dart';
import 'presentation/bloc/video_call/video_call_bloc.dart';

Future<void> initDoctorFeature() async {
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

  // ── Datasources ────────────────────────────────────────────────────────
  sl.registerLazySingleton(
      () => AppointmentRemoteDataSource(sl<DioClient>()));
  sl.registerLazySingleton(
      () => PatientRemoteDataSource(sl<DioClient>()));
  sl.registerLazySingleton(
      () => PrescriptionRemoteDataSource(sl<DioClient>()));
  sl.registerLazySingleton(
      () => ConsultationRemoteDataSource(sl<DioClient>()));
  sl.registerLazySingleton(
      () => DoctorRemoteDataSource(sl<DioClient>()));

  // ── Repositories ───────────────────────────────────────────────────────
  sl.registerLazySingleton<AppointmentRepository>(
    () => AppointmentRepositoryImpl(
        sl<AppointmentRemoteDataSource>(), sl<NetworkInfo>()),
  );
  sl.registerLazySingleton<PatientRepository>(
    () => PatientRepositoryImpl(
        sl<PatientRemoteDataSource>(), sl<NetworkInfo>()),
  );
  sl.registerLazySingleton<PrescriptionRepository>(
    () => PrescriptionRepositoryImpl(
        sl<PrescriptionRemoteDataSource>(), sl<NetworkInfo>()),
  );
  sl.registerLazySingleton<ConsultationRepository>(
    () => ConsultationRepositoryImpl(
        sl<ConsultationRemoteDataSource>(), sl<NetworkInfo>()),
  );
  sl.registerLazySingleton<DoctorRepository>(
    () => DoctorRepositoryImpl(
        sl<DoctorRemoteDataSource>(), sl<NetworkInfo>()),
  );

  // ── Use Cases ──────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetDashboardDataUseCase(
        appointments: sl<AppointmentRepository>(),
        prescriptions: sl<PrescriptionRepository>(),
      ));
  sl.registerLazySingleton(
      () => GetQueueUseCase(sl<DoctorRepository>()));
  sl.registerLazySingleton(
      () => GetAppointmentsUseCase(sl<AppointmentRepository>()));
  sl.registerLazySingleton(
      () => GetAppointmentDetailUseCase(sl<AppointmentRepository>()));
  sl.registerLazySingleton(
      () => SaveAppointmentNoteUseCase(sl<AppointmentRepository>()));
  sl.registerLazySingleton(
      () => GetPatientsUseCase(sl<PatientRepository>()));
  sl.registerLazySingleton(
      () => GetPatientDetailUseCase(sl<PatientRepository>()));
  sl.registerLazySingleton(
      () => GetPrescriptionsUseCase(sl<PrescriptionRepository>()));
  sl.registerLazySingleton(
      () => CreatePrescriptionUseCase(sl<PrescriptionRepository>()));
  sl.registerLazySingleton(
      () => GetPrescriptionTemplatesUseCase(sl<PrescriptionRepository>()));
  sl.registerLazySingleton(
      () => GetDoctorProfileUseCase(sl<DoctorRepository>()));
  sl.registerLazySingleton(
      () => GetDoctorSchedulesUseCase(sl<DoctorRepository>()));
  sl.registerLazySingleton(
      () => InitiateConsultationUseCase(sl<ConsultationRepository>()));

  // ── BLoCs (factory — new instance per BlocProvider.create call) ────────
  sl.registerFactory(
    () => DashboardBloc(getDashboardData: sl<GetDashboardDataUseCase>()),
  );
  sl.registerFactory(
    () => QueueBloc(getQueue: sl<GetQueueUseCase>()),
  );
  sl.registerFactory(
    () => AppointmentListBloc(
        getAppointments: sl<GetAppointmentsUseCase>()),
  );
  sl.registerFactory(
    () => AppointmentDetailBloc(
      getAppointmentDetail: sl<GetAppointmentDetailUseCase>(),
      saveNote: sl<SaveAppointmentNoteUseCase>(),
      appointmentRepo: sl<AppointmentRepository>(),
    ),
  );
  sl.registerFactory(
    () => PatientListBloc(getPatients: sl<GetPatientsUseCase>()),
  );
  sl.registerFactory(
    () => PatientDetailBloc(
      getPatientDetail: sl<GetPatientDetailUseCase>(),
      patientRepo: sl<PatientRepository>(),
    ),
  );
  sl.registerFactory(
    () => PrescriptionListBloc(
        getPrescriptions: sl<GetPrescriptionsUseCase>()),
  );
  sl.registerFactory(
    () => CreatePrescriptionBloc(
      createPrescription: sl<CreatePrescriptionUseCase>(),
      prescriptionRepo: sl<PrescriptionRepository>(),
    ),
  );
  sl.registerFactory(
    () => PrescriptionDetailBloc(
        prescriptionRepo: sl<PrescriptionRepository>()),
  );
  sl.registerFactory(
    () => PrescriptionTemplatesBloc(
        getTemplates: sl<GetPrescriptionTemplatesUseCase>(),
        prescriptionRepo: sl<PrescriptionRepository>()),
  );
  sl.registerFactory(
    () => ConsultationBloc(
      initiate: sl<InitiateConsultationUseCase>(),
      repo: sl<ConsultationRepository>(),
    ),
  );
  sl.registerFactory(
    () => VideoCallBloc(repo: sl<ConsultationRepository>()),
  );
  sl.registerFactory(
    () => ScheduleBloc(getSchedules: sl<GetDoctorSchedulesUseCase>()),
  );
  sl.registerFactory(
    () => ProfileBloc(getProfile: sl<GetDoctorProfileUseCase>()),
  );
}
