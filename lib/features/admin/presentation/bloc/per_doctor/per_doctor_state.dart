part of 'per_doctor_bloc.dart';

abstract class PerDoctorState extends Equatable {
  const PerDoctorState();
  @override List<Object?> get props => [];
}

class PerDoctorInitial extends PerDoctorState { const PerDoctorInitial(); }
class PerDoctorLoading extends PerDoctorState { const PerDoctorLoading(); }

class PerDoctorLoaded extends PerDoctorState {
  final DoctorAnalyticsDetail detail;
  final DateRangeSelection range;
  final List<DoctorAnalyticsDetail> comparisons;
  const PerDoctorLoaded({required this.detail, required this.range, this.comparisons = const []});
  bool get isComparing => comparisons.isNotEmpty;
  @override List<Object?> get props => [detail, range, comparisons];
}

class PerDoctorError extends PerDoctorState {
  final String message;
  const PerDoctorError(this.message);
  @override List<Object?> get props => [message];
}
