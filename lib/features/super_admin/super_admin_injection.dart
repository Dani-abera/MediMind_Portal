import '../../core/di/service_locator.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/network_info.dart';
import '../../core/network/realtime_service.dart';
import '../../core/storage/preferences_storage.dart';
import '../../core/widgets/shell/bloc/shell_bloc.dart';
import '../../shared/blocs/notification_bloc.dart';
import 'data/datasources/platform_centers_datasource.dart';
import 'data/datasources/platform_doctors_datasource.dart';
import 'data/datasources/platform_users_datasource.dart';
import 'data/datasources/platform_subscriptions_datasource.dart';
import 'data/datasources/platform_analytics_datasource.dart';
import 'data/datasources/platform_audit_datasource.dart';
import 'data/datasources/platform_settings_datasource.dart';
import 'data/datasources/platform_profile_datasource.dart';
import 'data/repositories/platform_centers_repository_impl.dart';
import 'data/repositories/platform_doctors_repository_impl.dart';
import 'data/repositories/platform_users_repository_impl.dart';
import 'data/repositories/platform_subscriptions_repository_impl.dart';
import 'data/repositories/platform_analytics_repository_impl.dart';
import 'data/repositories/platform_audit_repository_impl.dart';
import 'data/repositories/platform_settings_repository_impl.dart';
import 'data/repositories/platform_profile_repository_impl.dart';
import 'domain/repositories/platform_centers_repository.dart';
import 'domain/repositories/platform_doctors_repository.dart';
import 'domain/repositories/platform_users_repository.dart';
import 'domain/repositories/platform_subscriptions_repository.dart';
import 'domain/repositories/platform_analytics_repository.dart';
import 'domain/repositories/platform_audit_repository.dart';
import 'domain/repositories/platform_settings_repository.dart';
import 'domain/repositories/super_admin_profile_repository.dart';
import 'domain/usecases/get_platform_centers_usecase.dart';
import 'domain/usecases/get_platform_center_detail_usecase.dart';
import 'domain/usecases/approve_center_usecase.dart';
import 'domain/usecases/reject_center_usecase.dart';
import 'domain/usecases/suspend_center_usecase.dart';
import 'domain/usecases/reactivate_center_usecase.dart';
import 'domain/usecases/change_center_subscription_usecase.dart';
import 'domain/usecases/get_platform_doctors_usecase.dart';
import 'domain/usecases/get_platform_doctor_detail_usecase.dart';
import 'domain/usecases/verify_doctor_license_usecase.dart';
import 'domain/usecases/suspend_platform_doctor_usecase.dart';
import 'domain/usecases/get_platform_users_usecase.dart';
import 'domain/usecases/suspend_user_usecase.dart';
import 'domain/usecases/reactivate_user_usecase.dart';
import 'domain/usecases/force_logout_user_usecase.dart';
import 'domain/usecases/delete_user_usecase.dart';
import 'domain/usecases/get_platform_subscriptions_usecase.dart';
import 'domain/usecases/change_plan_usecase.dart';
import 'domain/usecases/get_platform_dashboard_usecase.dart';
import 'domain/usecases/get_platform_analytics_usecase.dart';
import 'domain/usecases/get_platform_audit_log_usecase.dart';
import 'domain/usecases/export_platform_audit_usecase.dart';
import 'domain/usecases/get_platform_settings_usecase.dart';
import 'domain/usecases/save_platform_settings_usecase.dart';
import 'domain/usecases/get_super_admin_profile_usecase.dart';
import 'domain/usecases/update_super_admin_profile_usecase.dart';
import 'presentation/bloc/platform_dashboard/platform_dashboard_bloc.dart';
import 'presentation/bloc/centers/centers_bloc.dart';
import 'presentation/bloc/doctors/platform_doctors_bloc.dart';
import 'presentation/bloc/users/platform_users_bloc.dart';
import 'presentation/bloc/subscriptions/platform_subscriptions_bloc.dart';
import 'presentation/bloc/platform_analytics/platform_analytics_bloc.dart';
import 'presentation/bloc/platform_audit/platform_audit_bloc.dart';
import 'presentation/bloc/platform_settings/platform_settings_bloc.dart';
import 'presentation/bloc/profile/super_admin_profile_bloc.dart';

Future<void> initSuperAdminFeature() async {
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

  sl.registerLazySingleton(() => PlatformCentersDatasource(sl<DioClient>()));
  sl.registerLazySingleton(() => PlatformDoctorsDatasource(sl<DioClient>()));
  sl.registerLazySingleton(() => PlatformUsersDatasource(sl<DioClient>()));
  sl.registerLazySingleton(() => PlatformSubscriptionsDatasource(sl<DioClient>()));
  sl.registerLazySingleton(() => PlatformAnalyticsDatasource(sl<DioClient>()));
  sl.registerLazySingleton(() => PlatformAuditDatasource(sl<DioClient>()));
  sl.registerLazySingleton(() => PlatformSettingsDatasource(sl<DioClient>()));
  sl.registerLazySingleton(() => PlatformProfileDatasource(sl<DioClient>()));

  sl.registerLazySingleton<PlatformCentersRepository>(
    () => PlatformCentersRepositoryImpl(sl<PlatformCentersDatasource>(), sl<NetworkInfo>()),
  );
  sl.registerLazySingleton<PlatformDoctorsRepository>(
    () => PlatformDoctorsRepositoryImpl(sl<PlatformDoctorsDatasource>(), sl<NetworkInfo>()),
  );
  sl.registerLazySingleton<PlatformUsersRepository>(
    () => PlatformUsersRepositoryImpl(sl<PlatformUsersDatasource>(), sl<NetworkInfo>()),
  );
  sl.registerLazySingleton<PlatformSubscriptionsRepository>(
    () => PlatformSubscriptionsRepositoryImpl(sl<PlatformSubscriptionsDatasource>(), sl<NetworkInfo>()),
  );
  sl.registerLazySingleton<PlatformAnalyticsRepository>(
    () => PlatformAnalyticsRepositoryImpl(sl<PlatformAnalyticsDatasource>(), sl<NetworkInfo>()),
  );
  sl.registerLazySingleton<PlatformAuditRepository>(
    () => PlatformAuditRepositoryImpl(sl<PlatformAuditDatasource>(), sl<NetworkInfo>()),
  );
  sl.registerLazySingleton<PlatformSettingsRepository>(
    () => PlatformSettingsRepositoryImpl(sl<PlatformSettingsDatasource>(), sl<NetworkInfo>()),
  );
  sl.registerLazySingleton<SuperAdminProfileRepository>(
    () => PlatformProfileRepositoryImpl(sl<PlatformProfileDatasource>(), sl<NetworkInfo>()),
  );

  sl.registerLazySingleton(() => GetPlatformCentersUseCase(sl<PlatformCentersRepository>()));
  sl.registerLazySingleton(() => GetPlatformCenterDetailUseCase(sl<PlatformCentersRepository>()));
  sl.registerLazySingleton(() => ApproveCenterUseCase(sl<PlatformCentersRepository>()));
  sl.registerLazySingleton(() => RejectCenterUseCase(sl<PlatformCentersRepository>()));
  sl.registerLazySingleton(() => SuspendCenterUseCase(sl<PlatformCentersRepository>()));
  sl.registerLazySingleton(() => ReactivateCenterUseCase(sl<PlatformCentersRepository>()));
  sl.registerLazySingleton(() => ChangeCenterSubscriptionUseCase(sl<PlatformCentersRepository>()));
  sl.registerLazySingleton(() => GetPlatformDoctorsUseCase(sl<PlatformDoctorsRepository>()));
  sl.registerLazySingleton(() => GetPlatformDoctorDetailUseCase(sl<PlatformDoctorsRepository>()));
  sl.registerLazySingleton(() => VerifyDoctorLicenseUseCase(sl<PlatformDoctorsRepository>()));
  sl.registerLazySingleton(() => SuspendPlatformDoctorUseCase(sl<PlatformDoctorsRepository>()));
  sl.registerLazySingleton(() => GetPlatformUsersUseCase(sl<PlatformUsersRepository>()));
  sl.registerLazySingleton(() => SuspendUserUseCase(sl<PlatformUsersRepository>()));
  sl.registerLazySingleton(() => ReactivateUserUseCase(sl<PlatformUsersRepository>()));
  sl.registerLazySingleton(() => ForceLogoutUserUseCase(sl<PlatformUsersRepository>()));
  sl.registerLazySingleton(() => DeleteUserUseCase(sl<PlatformUsersRepository>()));
  sl.registerLazySingleton(() => GetPlatformSubscriptionsUseCase(sl<PlatformSubscriptionsRepository>()));
  sl.registerLazySingleton(() => ChangePlanUseCase(sl<PlatformSubscriptionsRepository>()));
  sl.registerLazySingleton(() => GetPlatformDashboardUseCase(sl<PlatformAnalyticsRepository>()));
  sl.registerLazySingleton(() => GetPlatformAnalyticsUseCase(sl<PlatformAnalyticsRepository>()));
  sl.registerLazySingleton(() => GetPlatformAuditLogUseCase(sl<PlatformAuditRepository>()));
  sl.registerLazySingleton(() => ExportPlatformAuditUseCase(sl<PlatformAuditRepository>()));
  sl.registerLazySingleton(() => GetPlatformSettingsUseCase(sl<PlatformSettingsRepository>()));
  sl.registerLazySingleton(() => SavePlatformSettingsUseCase(sl<PlatformSettingsRepository>()));
  sl.registerLazySingleton(() => GetSuperAdminProfileUseCase(sl<SuperAdminProfileRepository>()));
  sl.registerLazySingleton(() => UpdateSuperAdminProfileUseCase(sl<SuperAdminProfileRepository>()));

  sl.registerFactory(() => PlatformDashboardBloc(
    getDashboard: sl<GetPlatformDashboardUseCase>(),
  ));
  sl.registerFactory(() => CentersBloc(
    getCenters: sl<GetPlatformCentersUseCase>(),
    approve: sl<ApproveCenterUseCase>(),
    reject: sl<RejectCenterUseCase>(),
    suspend: sl<SuspendCenterUseCase>(),
    reactivate: sl<ReactivateCenterUseCase>(),
  ));
  sl.registerFactory(() => PlatformDoctorsBloc(
    getDoctors: sl<GetPlatformDoctorsUseCase>(),
    verify: sl<VerifyDoctorLicenseUseCase>(),
    suspend: sl<SuspendPlatformDoctorUseCase>(),
  ));
  sl.registerFactory(() => PlatformUsersBloc(
    getUsers: sl<GetPlatformUsersUseCase>(),
    suspend: sl<SuspendUserUseCase>(),
    reactivate: sl<ReactivateUserUseCase>(),
    forceLogout: sl<ForceLogoutUserUseCase>(),
    delete: sl<DeleteUserUseCase>(),
  ));
  sl.registerFactory(() => PlatformSubscriptionsBloc(
    getSubscriptions: sl<GetPlatformSubscriptionsUseCase>(),
    changePlan: sl<ChangePlanUseCase>(),
  ));
  sl.registerFactory(() => PlatformAnalyticsBloc(
    getAnalytics: sl<GetPlatformAnalyticsUseCase>(),
  ));
  sl.registerFactory(() => PlatformAuditBloc(
    getAuditLog: sl<GetPlatformAuditLogUseCase>(),
    exportAuditLog: sl<ExportPlatformAuditUseCase>(),
  ));
  sl.registerFactory(() => PlatformSettingsBloc(
    getSettings: sl<GetPlatformSettingsUseCase>(),
    saveSettings: sl<SavePlatformSettingsUseCase>(),
  ));
  sl.registerFactory(() => SuperAdminProfileBloc(
    getProfile: sl<GetSuperAdminProfileUseCase>(),
    updateProfile: sl<UpdateSuperAdminProfileUseCase>(),
  ));
}
