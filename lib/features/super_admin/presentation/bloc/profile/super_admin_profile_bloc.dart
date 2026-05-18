import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import '../../../domain/entities/super_admin_profile.dart';
import '../../../domain/usecases/get_super_admin_profile_usecase.dart';
import '../../../domain/usecases/update_super_admin_profile_usecase.dart';

part 'super_admin_profile_event.dart';
part 'super_admin_profile_state.dart';

class SuperAdminProfileBloc
    extends Bloc<SuperAdminProfileEvent, SuperAdminProfileState> {
  final GetSuperAdminProfileUseCase _getProfile;
  final UpdateSuperAdminProfileUseCase _updateProfile;

  SuperAdminProfile _profile = const SuperAdminProfile();

  SuperAdminProfileBloc({
    required GetSuperAdminProfileUseCase getProfile,
    required UpdateSuperAdminProfileUseCase updateProfile,
  })  : _getProfile = getProfile,
        _updateProfile = updateProfile,
        super(const SuperAdminProfileInitial()) {
    on<ProfileStarted>(_onStarted, transformer: droppable());
    on<ProfileChanged>(_onChanged);
    on<ProfileUpdateRequested>(_onUpdateRequested, transformer: droppable());
  }

  Future<void> _onStarted(
      ProfileStarted event, Emitter<SuperAdminProfileState> emit) async {
    emit(const ProfileLoading());
    final result = await _getProfile();
    result.fold(
      (f) => emit(ProfileError(f.message)),
      (profile) {
        _profile = profile;
        emit(ProfileLoaded(profile));
      },
    );
  }

  void _onChanged(ProfileChanged event, Emitter<SuperAdminProfileState> emit) {
    _profile = event.profile;
    emit(ProfileLoaded(_profile));
  }

  Future<void> _onUpdateRequested(
      ProfileUpdateRequested event, Emitter<SuperAdminProfileState> emit) async {
    emit(const ProfileSaving());
    final result = await _updateProfile(_profile);
    result.fold(
      (f) => emit(ProfileError(f.message)),
      (profile) {
        _profile = profile;
        emit(const ProfileSaved());
        emit(ProfileLoaded(_profile));
      },
    );
  }
}
