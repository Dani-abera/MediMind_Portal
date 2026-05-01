import '../../core/di/service_locator.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/realtime_service.dart';
import '../../core/storage/preferences_storage.dart';
import '../../core/widgets/shell/bloc/shell_bloc.dart';
import '../../shared/blocs/notification_bloc.dart';

Future<void> initDoctorFeature() async {
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
}
