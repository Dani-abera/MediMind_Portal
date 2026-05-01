part of 'queue_bloc.dart';

abstract class QueueState extends Equatable {
  const QueueState();
  @override
  List<Object?> get props => [];
}

class QueueInitial extends QueueState {
  const QueueInitial();
}

class QueueLoading extends QueueState {
  const QueueLoading();
}

class QueueLoaded extends QueueState {
  final List<QueueEntry> entries;
  final String? centerId;
  const QueueLoaded(this.entries, {this.centerId});
  @override
  List<Object?> get props => [entries, centerId];
}

class QueueError extends QueueState {
  final String message;
  const QueueError(this.message);
  @override
  List<Object?> get props => [message];
}
