part of 'platform_doctors_bloc.dart';

abstract class PlatformDoctorsEvent extends Equatable {
  const PlatformDoctorsEvent();
  @override
  List<Object?> get props => [];
}

class PlatformDoctorsStarted extends PlatformDoctorsEvent {
  final String? statusFilter;
  const PlatformDoctorsStarted({this.statusFilter});
  @override
  List<Object?> get props => [statusFilter];
}

class PlatformDoctorsFiltered extends PlatformDoctorsEvent {
  final String? statusFilter;
  const PlatformDoctorsFiltered({this.statusFilter});
  @override
  List<Object?> get props => [statusFilter];
}

class PlatformDoctorsPageChanged extends PlatformDoctorsEvent {
  final int page;
  const PlatformDoctorsPageChanged(this.page);
  @override
  List<Object?> get props => [page];
}

class PlatformDoctorsRefreshed extends PlatformDoctorsEvent {
  const PlatformDoctorsRefreshed();
}

class DoctorVerifyLicenseRequested extends PlatformDoctorsEvent {
  final String doctorId;
  final String? notes;
  const DoctorVerifyLicenseRequested(this.doctorId, {this.notes});
  @override
  List<Object?> get props => [doctorId, notes];
}

class DoctorSuspendRequested extends PlatformDoctorsEvent {
  final String doctorId;
  final String reason;
  const DoctorSuspendRequested(this.doctorId, this.reason);
  @override
  List<Object?> get props => [doctorId, reason];
}
