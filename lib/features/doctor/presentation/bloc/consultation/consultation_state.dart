part of 'consultation_bloc.dart';

abstract class ConsultationState extends Equatable {
  const ConsultationState();
  @override
  List<Object?> get props => [];
}

class ConsultationInitial extends ConsultationState {
  const ConsultationInitial();
}

class ConsultationLoading extends ConsultationState {
  const ConsultationLoading();
}

class ConsultationLoaded extends ConsultationState {
  final List<VideoConsultation> active;
  final List<VideoConsultation> today;
  final List<VideoConsultation> past;
  final bool hasMorePast;
  final int tab;
  const ConsultationLoaded({
    required this.active,
    required this.today,
    required this.past,
    required this.hasMorePast,
    required this.tab,
  });
  @override
  List<Object?> get props => [active, today, past, hasMorePast, tab];

  ConsultationLoaded copyWith({
    List<VideoConsultation>? active,
    List<VideoConsultation>? today,
    List<VideoConsultation>? past,
    bool? hasMorePast,
    int? tab,
  }) {
    return ConsultationLoaded(
      active: active ?? this.active,
      today: today ?? this.today,
      past: past ?? this.past,
      hasMorePast: hasMorePast ?? this.hasMorePast,
      tab: tab ?? this.tab,
    );
  }
}

class ConsultationInitiateInProgress extends ConsultationState {
  const ConsultationInitiateInProgress();
}

class ConsultationInitiateSuccess extends ConsultationState {
  final VideoConsultation consultation;
  const ConsultationInitiateSuccess(this.consultation);
  @override
  List<Object?> get props => [consultation];
}

class ConsultationError extends ConsultationState {
  final String message;
  const ConsultationError(this.message);
  @override
  List<Object?> get props => [message];
}
