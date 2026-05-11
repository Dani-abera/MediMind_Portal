import '../../domain/entities/center.dart';
import '../../domain/repositories/center_repository.dart';
import '../datasources/center_remote_datasource.dart';

class CenterRepositoryImpl implements CenterRepository {
  final CenterRemoteDataSource _remoteDataSource;

  CenterRepositoryImpl(this._remoteDataSource);

  @override
  Future<HealthcareCenter> registerCenter(Map<String, dynamic> data) async {
    return await _remoteDataSource.registerCenter(data);
  }

  @override
  Future<HealthcareCenter> getMyCenter() async {
    return await _remoteDataSource.getMyCenter();
  }
}
