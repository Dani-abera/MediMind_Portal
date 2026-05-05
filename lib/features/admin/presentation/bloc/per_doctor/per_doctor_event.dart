part of 'per_doctor_bloc.dart';

abstract class PerDoctorEvent extends Equatable {
  const PerDoctorEvent();
  @override List<Object?> get props => [];
}

class PerDoctorStarted extends PerDoctorEvent {
  final String centerId;
  final String doctorId;
  const PerDoctorStarted({required this.centerId, required this.doctorId});
  @override List<Object?> get props => [centerId, doctorId];
}

class PerDoctorSelected extends PerDoctorEvent {
  final String doctorId;
  const PerDoctorSelected(this.doctorId);
  @override List<Object?> get props => [doctorId];
}

class PerDoctorDateRangeChanged extends PerDoctorEvent {
  final DateRangePreset preset;
  final DateTime? customFrom;
  final DateTime? customTo;
  const PerDoctorDateRangeChanged(this.preset, {this.customFrom, this.customTo});
  @override List<Object?> get props => [preset, customFrom, customTo];
}

class PerDoctorCompareAdded extends PerDoctorEvent {
  final String doctorId;
  const PerDoctorCompareAdded(this.doctorId);
  @override List<Object?> get props => [doctorId];
}

class PerDoctorCompareRemoved extends PerDoctorEvent {
  final String doctorId;
  const PerDoctorCompareRemoved(this.doctorId);
  @override List<Object?> get props => [doctorId];
}
