part of 'admin_queue_bloc.dart';

abstract class AdminQueueState extends Equatable {
  const AdminQueueState();
  @override List<Object?> get props => [];
}
class AdminQueueInitial extends AdminQueueState { const AdminQueueInitial(); }
class AdminQueueLoading extends AdminQueueState { const AdminQueueLoading(); }
class AdminQueueLoaded extends AdminQueueState {
  final List<QueueItem> items;
  final QueueItem? nowServing;
  final QueueStats stats;
  final String centerId;
  final DateTime updatedAt;
  const AdminQueueLoaded({
    required this.items, this.nowServing,
    required this.stats, required this.centerId, required this.updatedAt,
  });
  @override List<Object?> get props => [items, nowServing, stats, centerId, updatedAt];
}
class AdminQueueActionInProgress extends AdminQueueState {
  final String queueId;
  const AdminQueueActionInProgress(this.queueId);
  @override List<Object?> get props => [queueId];
}
class AdminQueueActionSuccess extends AdminQueueState {
  final String message;
  const AdminQueueActionSuccess(this.message);
  @override List<Object?> get props => [message];
}
class AdminQueueActionError extends AdminQueueState {
  final String message;
  const AdminQueueActionError(this.message);
  @override List<Object?> get props => [message];
}
class AdminQueueError extends AdminQueueState {
  final String message;
  const AdminQueueError(this.message);
  @override List<Object?> get props => [message];
}
