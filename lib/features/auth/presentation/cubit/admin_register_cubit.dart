import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/admin_register_usecase.dart';

abstract class AdminRegisterState {}

class AdminRegisterInitial extends AdminRegisterState {}

class AdminRegisterLoading extends AdminRegisterState {}

class AdminRegisterSuccess extends AdminRegisterState {}

class AdminRegisterError extends AdminRegisterState {
  final String message;
  AdminRegisterError(this.message);
}

class AdminRegisterCubit extends Cubit<AdminRegisterState> {
  final AdminRegisterUseCase _register;

  AdminRegisterCubit(this._register) : super(AdminRegisterInitial());

  Future<void> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    emit(AdminRegisterLoading());
    final result = await _register(
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
    );
    result.fold(
      (failure) => emit(AdminRegisterError(failure.message)),
      (_) => emit(AdminRegisterSuccess()),
    );
  }

  void reset() => emit(AdminRegisterInitial());
}
