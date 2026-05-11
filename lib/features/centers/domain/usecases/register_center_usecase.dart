import '../entities/center.dart';
import '../repositories/center_repository.dart';

class RegisterCenterUseCase {
  final CenterRepository repository;

  RegisterCenterUseCase(this.repository);

  Future<HealthcareCenter> call(Map<String, dynamic> params) async {
    return await repository.registerCenter(params);
  }
}
