import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class CheckAuthStatusUseCase {
  final AuthRepository _repo;
  const CheckAuthStatusUseCase(this._repo);

  Future<Either<Failure, User>> call() => _repo.getCurrentUser();
}
