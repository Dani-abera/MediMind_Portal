import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../centers/domain/entities/center.dart';
import '../../../../centers/domain/usecases/register_center_usecase.dart';

// States
abstract class CenterRegistrationState extends Equatable {
  const CenterRegistrationState();

  @override
  List<Object?> get props => [];
}

class CenterRegistrationInitial extends CenterRegistrationState {}

class CenterRegistrationLoading extends CenterRegistrationState {}

class CenterRegistrationSuccess extends CenterRegistrationState {
  final HealthcareCenter center;

  const CenterRegistrationSuccess(this.center);

  @override
  List<Object?> get props => [center];
}

class CenterRegistrationFailure extends CenterRegistrationState {
  final String message;

  const CenterRegistrationFailure(this.message);

  @override
  List<Object?> get props => [message];
}

// Events
abstract class CenterRegistrationEvent extends Equatable {
  const CenterRegistrationEvent();
}

class RegisterCenterSubmitted extends CenterRegistrationEvent {
  final Map<String, dynamic> data;

  const RegisterCenterSubmitted(this.data);

  @override
  List<Object?> get props => [data];
}

// Bloc
class CenterRegistrationBloc extends Bloc<CenterRegistrationEvent, CenterRegistrationState> {
  final RegisterCenterUseCase _registerCenter;

  CenterRegistrationBloc({
    required RegisterCenterUseCase registerCenter,
  })  : _registerCenter = registerCenter,
        super(CenterRegistrationInitial()) {
    on<RegisterCenterSubmitted>(_onRegisterCenterSubmitted);
  }

  Future<void> _onRegisterCenterSubmitted(
    RegisterCenterSubmitted event,
    Emitter<CenterRegistrationState> emit,
  ) async {
    emit(CenterRegistrationLoading());
    try {
      final center = await _registerCenter(event.data);
      emit(CenterRegistrationSuccess(center));
    } catch (e) {
      emit(CenterRegistrationFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
