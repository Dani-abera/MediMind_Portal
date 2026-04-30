import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/dio_client.dart';
import '../network/network_info.dart';
import '../network/realtime_service.dart';
import '../network/user_context.dart';
import '../storage/preferences_storage.dart';
import '../storage/secure_storage.dart';
import '../services/window_service.dart';
import '../../features/auth/auth_injection.dart';

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
  sl.registerSingleton<NetworkInfo>(
    NetworkInfoImpl(sl<InternetConnection>()),
  );

  sl.registerSingleton<DioClient>(
    DioClient(
      storage: sl<SecureStorage>(),
      userContext: sl<UserContext>(),
    ),
  );

  // Realtime
  sl.registerSingleton<RealtimeService>(
    RealtimeService(sl<UserContext>()),
  );

  // Window service
  sl.registerSingleton<WindowService>(
    WindowService(sl<SharedPreferences>()),
  );

  // Auth feature (datasources, repo, use cases, blocs, AuthBloc)
  await initAuthFeature();
}
