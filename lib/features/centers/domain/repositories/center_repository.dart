import '../entities/center.dart';

abstract class CenterRepository {
  Future<HealthcareCenter> registerCenter(Map<String, dynamic> data);
  Future<HealthcareCenter> getMyCenter();
}
