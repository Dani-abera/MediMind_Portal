import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import '../../../domain/entities/doctor_profile.dart';
import '../../../domain/usecases/get_doctor_profile_usecase.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetDoctorProfileUseCase _getProfile;

  ProfileBloc({required GetDoctorProfileUseCase getProfile})
      : _getProfile = getProfile,
        super(const ProfileInitial()) {
    on<ProfileStarted>(_onStarted, transformer: droppable());
    on<ProfileRefreshed>(_onRefreshed, transformer: droppable());
  }

  Future<void> _onStarted(
    ProfileStarted event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    final result = await _getProfile();
    result.fold(
      (f) => emit(ProfileError(f.message)),
      (profile) => emit(ProfileLoaded(profile)),
    );
  }

  Future<void> _onRefreshed(
    ProfileRefreshed event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    final result = await _getProfile();
    result.fold(
      (f) => emit(ProfileError(f.message)),
      (profile) => emit(ProfileLoaded(profile)),
    );
  }
}
