part of 'admin_queue_bloc.dart';

abstract class AdminQueueEvent extends Equatable {
  const AdminQueueEvent();
  @override List<Object?> get props => [];
}

class AdminQueueOpened extends AdminQueueEvent {
  final String centerId;
  const AdminQueueOpened(this.centerId);
  @override List<Object?> get props => [centerId];
}
class AdminQueueRefreshed extends AdminQueueEvent { const AdminQueueRefreshed(); }
class AdminQueueNextCalled extends AdminQueueEvent { const AdminQueueNextCalled(); }
class AdminQueueMarkArrived extends AdminQueueEvent {
  final String queueId;
  const AdminQueueMarkArrived(this.queueId);
  @override List<Object?> get props => [queueId];
}
class AdminQueueMarkComplete extends AdminQueueEvent {
  final String queueId;
  const AdminQueueMarkComplete(this.queueId);
  @override List<Object?> get props => [queueId];
}
class AdminQueueMarkNoShow extends AdminQueueEvent {
  final String queueId;
  const AdminQueueMarkNoShow(this.queueId);
  @override List<Object?> get props => [queueId];
}
class AdminQueueSkipped extends AdminQueueEvent {
  final String queueId;
  const AdminQueueSkipped(this.queueId);
  @override List<Object?> get props => [queueId];
}
class AdminQueueEmergencyInserted extends AdminQueueEvent {
  final String appointmentId;
  const AdminQueueEmergencyInserted(this.appointmentId);
  @override List<Object?> get props => [appointmentId];
}
class AdminQueueSignalRUpdate extends AdminQueueEvent {
  final Map<String, dynamic> payload;
  const AdminQueueSignalRUpdate(this.payload);
  @override List<Object?> get props => [payload];
}
