part of 'super_admin_profile_bloc.dart';

abstract class SuperAdminProfileState extends Equatable {
  const SuperAdminProfileState();
  @override
  List<Object?> get props => [];
}

class SuperAdminProfileInitial extends SuperAdminProfileState {
  const SuperAdminProfileInitial();
}

class ProfileLoading extends SuperAdminProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends SuperAdminProfileState {
  final SuperAdminProfile profile;
  const ProfileLoaded(this.profile);
  @override
  List<Object?> get props => [profile];
}

class ProfileSaving extends SuperAdminProfileState {
  const ProfileSaving();
}

class ProfileSaved extends SuperAdminProfileState {
  const ProfileSaved();
}

class ProfileError extends SuperAdminProfileState {
  final String message;
  const ProfileError(this.message);
  @override
  List<Object?> get props => [message];
}
