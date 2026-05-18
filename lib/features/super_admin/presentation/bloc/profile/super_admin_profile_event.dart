part of 'super_admin_profile_bloc.dart';

abstract class SuperAdminProfileEvent extends Equatable {
  const SuperAdminProfileEvent();
  @override
  List<Object?> get props => [];
}

class ProfileStarted extends SuperAdminProfileEvent {
  const ProfileStarted();
}

class ProfileChanged extends SuperAdminProfileEvent {
  final SuperAdminProfile profile;
  const ProfileChanged(this.profile);
  @override
  List<Object?> get props => [profile];
}

class ProfileUpdateRequested extends SuperAdminProfileEvent {
  const ProfileUpdateRequested();
}
