import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/reset_password_usecase.dart';

// Events
abstract class ResetPasswordEvent extends Equatable {
  const ResetPasswordEvent();
  @override
  List<Object?> get props => [];
}

class ResetPasswordSubmitted extends ResetPasswordEvent {
  final String token;
  final String newPassword;
  const ResetPasswordSubmitted({required this.token, required this.newPassword});
  @override
  List<Object?> get props => [token, newPassword];
}

// States
abstract class ResetPasswordState extends Equatable {
  const ResetPasswordState();
  @override
  List<Object?> get props => [];
}

class ResetPasswordInitial extends ResetPasswordState {
  const ResetPasswordInitial();
}

class ResetPasswordLoading extends ResetPasswordState {
  const ResetPasswordLoading();
}

class ResetPasswordSuccess extends ResetPasswordState {
  const ResetPasswordSuccess();
}

class ResetPasswordError extends ResetPasswordState {
  final String message;
  const ResetPasswordError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class ResetPasswordBloc extends Bloc<ResetPasswordEvent, ResetPasswordState> {
  final ResetPasswordUseCase _useCase;

  ResetPasswordBloc(this._useCase) : super(const ResetPasswordInitial()) {
    on<ResetPasswordSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    ResetPasswordSubmitted event,
    Emitter<ResetPasswordState> emit,
  ) async {
    emit(const ResetPasswordLoading());
    final result = await _useCase(
      token: event.token,
      newPassword: event.newPassword,
    );
    result.fold(
      (failure) => emit(ResetPasswordError(failure.message)),
      (_) => emit(const ResetPasswordSuccess()),
    );
  }
}
