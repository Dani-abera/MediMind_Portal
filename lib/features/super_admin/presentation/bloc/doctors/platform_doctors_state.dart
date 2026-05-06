part of 'platform_doctors_bloc.dart';

abstract class PlatformDoctorsState extends Equatable {
  const PlatformDoctorsState();
  @override
  List<Object?> get props => [];
}

class PlatformDoctorsInitial extends PlatformDoctorsState {
  const PlatformDoctorsInitial();
}

class PlatformDoctorsLoading extends PlatformDoctorsState {
  const PlatformDoctorsLoading();
}

class PlatformDoctorsLoaded extends PlatformDoctorsState {
  final List<PlatformDoctor> doctors;
  final int total;
  final int page;
  const PlatformDoctorsLoaded({required this.doctors, required this.total, this.page = 1});
  @override
  List<Object?> get props => [doctors, total, page];
}

class PlatformDoctorsActionSuccess extends PlatformDoctorsState {
  final String message;
  const PlatformDoctorsActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class PlatformDoctorsActionError extends PlatformDoctorsState {
  final String message;
  const PlatformDoctorsActionError(this.message);
  @override
  List<Object?> get props => [message];
}

class PlatformDoctorsError extends PlatformDoctorsState {
  final String message;
  const PlatformDoctorsError(this.message);
  @override
  List<Object?> get props => [message];
}
