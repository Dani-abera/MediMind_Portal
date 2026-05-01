part of 'consultation_bloc.dart';

abstract class ConsultationEvent extends Equatable {
  const ConsultationEvent();
  @override
  List<Object?> get props => [];
}

class ConsultationStarted extends ConsultationEvent {
  const ConsultationStarted();
}

class ConsultationTabChanged extends ConsultationEvent {
  /// 0 = active, 1 = today, 2 = past
  final int index;
  const ConsultationTabChanged(this.index);
  @override
  List<Object?> get props => [index];
}

class ConsultationNextPage extends ConsultationEvent {
  const ConsultationNextPage();
}

class ConsultationInitiated extends ConsultationEvent {
  final String appointmentId;
  const ConsultationInitiated(this.appointmentId);
  @override
  List<Object?> get props => [appointmentId];
}
