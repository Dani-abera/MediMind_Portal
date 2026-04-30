import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/forgot_password_usecase.dart';

// Events
abstract class ForgotPasswordEvent extends Equatable {
  const ForgotPasswordEvent();
  @override
  List<Object?> get props => [];
}

class ForgotPasswordSubmitted extends ForgotPasswordEvent {
  final String email;
  const ForgotPasswordSubmitted(this.email);
  @override
  List<Object?> get props => [email];
}

class ForgotPasswordReset extends ForgotPasswordEvent {
  const ForgotPasswordReset();
}

// States
abstract class ForgotPasswordState extends Equatable {
  const ForgotPasswordState();
  @override
  List<Object?> get props => [];
}

class ForgotPasswordInitial extends ForgotPasswordState {
  const ForgotPasswordInitial();
}

class ForgotPasswordLoading extends ForgotPasswordState {
  const ForgotPasswordLoading();
}

class ForgotPasswordSuccess extends ForgotPasswordState {
  const ForgotPasswordSuccess();
}

class ForgotPasswordError extends ForgotPasswordState {
  final String message;
  const ForgotPasswordError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class ForgotPasswordBloc
    extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  final ForgotPasswordUseCase _useCase;

  ForgotPasswordBloc(this._useCase) : super(const ForgotPasswordInitial()) {
    on<ForgotPasswordSubmitted>(_onSubmitted);
    on<ForgotPasswordReset>((_, emit) => emit(const ForgotPasswordInitial()));
  }

  Future<void> _onSubmitted(
    ForgotPasswordSubmitted event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(const ForgotPasswordLoading());
    final result = await _useCase(event.email);
    result.fold(
      (failure) => emit(ForgotPasswordError(failure.message)),
      (_) => emit(const ForgotPasswordSuccess()),
    );
  }
}
