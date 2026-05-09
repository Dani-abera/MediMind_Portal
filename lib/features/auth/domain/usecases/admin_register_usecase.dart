import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class AdminRegisterUseCase {
  final AuthRepository _repo;
  const AdminRegisterUseCase(this._repo);

  Future<Either<Failure, void>> call({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) =>
      _repo.adminRegister(
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
      );
}
