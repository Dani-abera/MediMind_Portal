import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import '../../../domain/entities/platform_notification.dart';
import '../../../domain/usecases/get_platform_notifications_usecase.dart';
import '../../../domain/usecases/mark_notification_read_usecase.dart';
import '../../../domain/usecases/mark_all_notifications_read_usecase.dart';

part 'platform_notifications_event.dart';
part 'platform_notifications_state.dart';

class PlatformNotificationsBloc
    extends Bloc<PlatformNotificationsEvent, PlatformNotificationsState> {
  final GetPlatformNotificationsUseCase _getNotifications;
  final MarkNotificationReadUseCase _markRead;
  final MarkAllNotificationsReadUseCase _markAllRead;

  int _page = 1;
  static const _pageSize = 20;

  PlatformNotificationsBloc({
    required GetPlatformNotificationsUseCase getNotifications,
    required MarkNotificationReadUseCase markRead,
    required MarkAllNotificationsReadUseCase markAllRead,
  })  : _getNotifications = getNotifications,
        _markRead = markRead,
        _markAllRead = markAllRead,
        super(const PlatformNotificationsInitial()) {
    on<PlatformNotificationsStarted>(_onStarted, transformer: droppable());
    on<PlatformNotificationsPageChanged>(_onPageChanged, transformer: droppable());
    on<PlatformNotificationsRefreshed>(_onRefreshed, transformer: droppable());
    on<PlatformNotificationMarkReadRequested>(_onMarkRead, transformer: sequential());
    on<PlatformNotificationsMarkAllReadRequested>(_onMarkAllRead, transformer: sequential());
  }

  Future<void> _fetch(Emitter<PlatformNotificationsState> emit) async {
    emit(const PlatformNotificationsLoading());
    final result = await _getNotifications(page: _page, pageSize: _pageSize);
    result.fold(
      (f) => emit(PlatformNotificationsError(f.message)),
      (r) => emit(PlatformNotificationsLoaded(items: r.items, total: r.total, page: _page)),
    );
  }

  Future<void> _onStarted(
    PlatformNotificationsStarted _,
    Emitter<PlatformNotificationsState> emit,
  ) async {
    _page = 1;
    await _fetch(emit);
  }

  Future<void> _onPageChanged(
    PlatformNotificationsPageChanged event,
    Emitter<PlatformNotificationsState> emit,
  ) async {
    _page = event.page;
    await _fetch(emit);
  }

  Future<void> _onRefreshed(
    PlatformNotificationsRefreshed _,
    Emitter<PlatformNotificationsState> emit,
  ) async {
    await _fetch(emit);
  }

  Future<void> _onMarkRead(
    PlatformNotificationMarkReadRequested event,
    Emitter<PlatformNotificationsState> emit,
  ) async {
    final result = await _markRead(event.id);
    result.fold(
      (f) => emit(PlatformNotificationsActionError(f.message)),
      (_) {
        emit(const PlatformNotificationsActionSuccess('Notification marked as read'));
        add(const PlatformNotificationsRefreshed());
      },
    );
  }

  Future<void> _onMarkAllRead(
    PlatformNotificationsMarkAllReadRequested _,
    Emitter<PlatformNotificationsState> emit,
  ) async {
    final result = await _markAllRead();
    result.fold(
      (f) => emit(PlatformNotificationsActionError(f.message)),
      (_) {
        emit(const PlatformNotificationsActionSuccess('All notifications marked as read'));
        add(const PlatformNotificationsRefreshed());
      },
    );
  }
}
