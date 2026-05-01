part of 'queue_bloc.dart';

abstract class QueueEvent extends Equatable {
  const QueueEvent();
  @override
  List<Object?> get props => [];
}

class QueueStarted extends QueueEvent {
  final String? centerId;
  const QueueStarted([this.centerId]);
  @override
  List<Object?> get props => [centerId];
}

class QueueRefreshed extends QueueEvent {
  const QueueRefreshed();
}

class QueueCenterChanged extends QueueEvent {
  final String centerId;
  const QueueCenterChanged(this.centerId);
  @override
  List<Object?> get props => [centerId];
}
