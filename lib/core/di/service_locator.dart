import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/dio_client.dart';
import '../network/network_info.dart';
import '../network/realtime_service.dart';
import '../network/user_context.dart';
import '../storage/preferences_storage.dart';
import '../storage/secure_storage.dart';
import '../services/analytics_service.dart';
import '../services/app_update_service.dart';
import '../services/connectivity_cubit.dart';
import '../services/inactivity_service.dart';
import '../services/window_service.dart';
import '../theme/theme_cubit.dart';
import '../../features/auth/auth_injection.dart';
import '../../features/doctor/doctor_injection.dart';
import '../../features/admin/admin_injection.dart';
import '../../features/super_admin/super_admin_injection.dart';

final sl = GetIt.instance;

Future<void> initCoreDependencies() async {
  // Preferences
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);
  sl.registerSingleton<PreferencesStorage>(PreferencesStorage(prefs));

  // Secure storage
  sl.registerSingleton<SecureStorage>(SecureStorage());

  // User context
  sl.registerSingleton<UserContext>(UserContext());

  // Network
  sl.registerSingleton<InternetConnection>(InternetConnection());
  sl.registerSingleton<NetworkInfo>(NetworkInfoImpl(sl<InternetConnection>()));
  sl.registerSingleton<DioClient>(
    DioClient(storage: sl<SecureStorage>(), userContext: sl<UserContext>()),
  );

  // Realtime
  sl.registerSingleton<RealtimeService>(RealtimeService(sl<UserContext>()));

  // Window service
  sl.registerSingleton<WindowService>(WindowService(sl<SharedPreferences>()));

  // Theme cubit (singleton — persists mode)
  sl.registerSingleton<ThemeCubit>(ThemeCubit(sl<PreferencesStorage>()));

  // Connectivity
  sl.registerSingleton<ConnectivityCubit>(
    ConnectivityCubit(
      connectivity: Connectivity(),
      checker: sl<InternetConnection>(),
    ),
  );

  // Analytics (singleton accessor via factory — no DI needed)
  sl.registerSingleton<AnalyticsService>(AnalyticsService());

  // Inactivity service (configured when user logs in)
  sl.registerSingleton<InactivityService>(InactivityService());

  // App update service
  final baseUrl = dotenv.maybeGet('API_BASE_URL') ?? 'https://api.medimind.et';
  sl.registerSingleton<AppUpdateService>(
    AppUpdateService(
      dio: sl<DioClient>().dio,
      baseUrl: baseUrl,
    ),
  );

  // Auth feature
  await initAuthFeature();

  // Workspace features (register ShellBloc + NotificationBloc lazily)
  await initDoctorFeature();
  await initAdminFeature();
  await initSuperAdminFeature();
}
