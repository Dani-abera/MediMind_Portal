import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import '../../domain/entities/notification_item.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_notification_read_usecase.dart';
import '../../domain/usecases/mark_all_notifications_read_usecase.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final GetNotificationsUseCase _getNotifications;
  final MarkNotificationReadUseCase _markRead;
  final MarkAllNotificationsReadUseCase _markAllRead;

  NotificationsBloc({
    required GetNotificationsUseCase getNotifications,
    required MarkNotificationReadUseCase markRead,
    required MarkAllNotificationsReadUseCase markAllRead,
  })  : _getNotifications = getNotifications,
        _markRead = markRead,
        _markAllRead = markAllRead,
        super(const NotificationsInitial()) {
    on<NotificationsStarted>(_onStarted, transformer: droppable());
    on<NotificationsRefreshed>(_onRefreshed, transformer: droppable());
    on<NotificationMarkReadRequested>(_onMarkRead, transformer: sequential());
    on<NotificationsMarkAllReadRequested>(_onMarkAllRead, transformer: sequential());
  }

  Future<void> _fetch(Emitter<NotificationsState> emit) async {
    emit(const NotificationsLoading());
    final result = await _getNotifications();
    result.fold(
      (f) => emit(NotificationsError(f.message)),
      (items) => emit(NotificationsLoaded(items)),
    );
  }

  Future<void> _onStarted(NotificationsStarted _, Emitter<NotificationsState> emit) async {
    await _fetch(emit);
  }

  Future<void> _onRefreshed(NotificationsRefreshed _, Emitter<NotificationsState> emit) async {
    await _fetch(emit);
  }

  Future<void> _onMarkRead(
    NotificationMarkReadRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    final result = await _markRead(event.id);
    result.fold(
      (f) => emit(NotificationsActionError(f.message)),
      (_) {
        emit(const NotificationsActionSuccess('Marked as read'));
        add(const NotificationsRefreshed());
      },
    );
  }

  Future<void> _onMarkAllRead(
    NotificationsMarkAllReadRequested _,
    Emitter<NotificationsState> emit,
  ) async {
    final result = await _markAllRead();
    result.fold(
      (f) => emit(NotificationsActionError(f.message)),
      (_) {
        emit(const NotificationsActionSuccess('All notifications marked as read'));
        add(const NotificationsRefreshed());
      },
    );
  }
}
