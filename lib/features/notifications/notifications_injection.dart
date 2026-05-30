import '../../core/di/service_locator.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/network_info.dart';
import 'data/datasources/notifications_datasource.dart';
import 'data/repositories/notifications_repository_impl.dart';
import 'domain/repositories/notifications_repository.dart';
import 'domain/usecases/get_notifications_usecase.dart';
import 'domain/usecases/mark_notification_read_usecase.dart';
import 'domain/usecases/mark_all_notifications_read_usecase.dart';
import 'presentation/bloc/notifications_bloc.dart';

Future<void> initNotificationsFeature() async {
  if (sl.isRegistered<NotificationsBloc>()) return;

  sl.registerLazySingleton(() => NotificationsDatasource(sl<DioClient>()));
  sl.registerLazySingleton<NotificationsRepository>(
    () => NotificationsRepositoryImpl(sl<NotificationsDatasource>(), sl<NetworkInfo>()),
  );
  sl.registerLazySingleton(() => GetNotificationsUseCase(sl<NotificationsRepository>()));
  sl.registerLazySingleton(() => MarkNotificationReadUseCase(sl<NotificationsRepository>()));
  sl.registerLazySingleton(() => MarkAllNotificationsReadUseCase(sl<NotificationsRepository>()));

  sl.registerFactory(() => NotificationsBloc(
    getNotifications: sl<GetNotificationsUseCase>(),
    markRead: sl<MarkNotificationReadUseCase>(),
    markAllRead: sl<MarkAllNotificationsReadUseCase>(),
  ));
}
