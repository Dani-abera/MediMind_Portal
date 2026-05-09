import 'package:shared_preferences/shared_preferences.dart';
import '../../core/di/service_locator.dart';
import '../../core/network/auth_interceptor.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/network_info.dart';
import '../../core/network/user_context.dart';
import '../../core/storage/secure_storage.dart';
import 'data/datasources/auth_local_datasource.dart';
import 'data/datasources/auth_remote_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/usecases/admin_login_usecase.dart';
import 'domain/usecases/admin_register_usecase.dart';
import 'domain/usecases/admin_verify_otp_usecase.dart';
import 'domain/usecases/change_password_usecase.dart';
import 'domain/usecases/check_auth_status_usecase.dart';
import 'domain/usecases/doctor_request_otp_usecase.dart';
import 'domain/usecases/doctor_verify_otp_usecase.dart';
import 'domain/usecases/forgot_password_usecase.dart';
import 'domain/usecases/logout_usecase.dart';
import 'domain/usecases/reset_password_usecase.dart';
import 'domain/usecases/super_admin_login_usecase.dart';
import 'domain/usecases/super_admin_verify_2fa_usecase.dart';
import 'presentation/bloc/admin_login/admin_login_bloc.dart';
import 'presentation/bloc/auth_bloc.dart';
import 'presentation/bloc/auth_event.dart';
import 'presentation/bloc/doctor_login/doctor_login_bloc.dart';
import 'presentation/bloc/forgot_password/forgot_password_bloc.dart';
import 'presentation/bloc/reset_password/reset_password_bloc.dart';
import 'presentation/bloc/super_admin_login/super_admin_login_bloc.dart';
import 'presentation/cubit/account_lockout_cubit.dart';
import 'presentation/cubit/admin_register_cubit.dart';

Future<void> initAuthFeature() async {
  await AuthLocalDataSourceImpl.openBox();

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<DioClient>().dio),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sl<SecureStorage>()),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remote: sl<AuthRemoteDataSource>(),
      local: sl<AuthLocalDataSource>(),
      network: sl<NetworkInfo>(),
      ctx: sl<UserContext>(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => DoctorRequestOtpUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => DoctorVerifyOtpUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => AdminLoginUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => AdminRegisterUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => AdminVerifyOtpUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SuperAdminLoginUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SuperAdminVerify2faUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => ChangePasswordUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => LogoutUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => CheckAuthStatusUseCase(sl<AuthRepository>()));

  // AuthBloc (singleton — lives for the app lifetime)
  if (sl.isRegistered<AuthBloc>()) sl.unregister<AuthBloc>();
  sl.registerSingleton<AuthBloc>(
    AuthBloc(
      checkAuth: sl<CheckAuthStatusUseCase>(),
      logout: sl<LogoutUseCase>(),
    ),
  );

  // Wire mid-session refresh failure → AuthBloc navigation to login
  final authInterceptor = sl<DioClient>().dio.interceptors
      .whereType<AuthInterceptor>()
      .firstOrNull;
  authInterceptor?.onRefreshFailed =
      () => sl<AuthBloc>().add(const AuthTokenExpired());

  // Login blocs (factory — fresh instance per page visit)
  sl.registerFactory<DoctorLoginBloc>(
    () => DoctorLoginBloc(
      requestOtp: sl<DoctorRequestOtpUseCase>(),
      verifyOtp: sl<DoctorVerifyOtpUseCase>(),
    ),
  );
  sl.registerFactory<AdminLoginBloc>(
    () => AdminLoginBloc(
      login: sl<AdminLoginUseCase>(),
      verifyOtp: sl<AdminVerifyOtpUseCase>(),
    ),
  );
  sl.registerFactory<SuperAdminLoginBloc>(
    () => SuperAdminLoginBloc(
      login: sl<SuperAdminLoginUseCase>(),
      verify2fa: sl<SuperAdminVerify2faUseCase>(),
    ),
  );
  sl.registerFactory<AdminRegisterCubit>(
    () => AdminRegisterCubit(sl<AdminRegisterUseCase>()),
  );
  sl.registerFactory<ForgotPasswordBloc>(
    () => ForgotPasswordBloc(sl<ForgotPasswordUseCase>()),
  );
  sl.registerFactory<ResetPasswordBloc>(
    () => ResetPasswordBloc(sl<ResetPasswordUseCase>()),
  );

  // Account lockout cubit (singleton — persists lockout state)
  sl.registerLazySingleton<AccountLockoutCubit>(
    () => AccountLockoutCubit(sl<SharedPreferences>()),
  );
}
