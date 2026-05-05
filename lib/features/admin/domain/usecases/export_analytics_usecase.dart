import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/analytics_repository.dart';

enum ExportFormat { csv, excel, pdf }

class ExportAnalyticsCsvUseCase {
  final AnalyticsRepository _repo;
  ExportAnalyticsCsvUseCase(this._repo);

  Future<Either<Failure, String>> call(String centerId, {
    required DateTime from,
    required DateTime to,
  }) =>
      _repo.exportAnalyticsCsv(centerId, from: from, to: to);
}

class ExportAnalyticsPdfUseCase {
  final AnalyticsRepository _repo;
  ExportAnalyticsPdfUseCase(this._repo);

  Future<Either<Failure, String>> call(String centerId, {
    required DateTime from,
    required DateTime to,
  }) =>
      _repo.exportAnalyticsPdf(centerId, from: from, to: to);
}

class ExportRevenueCsvUseCase {
  final AnalyticsRepository _repo;
  ExportRevenueCsvUseCase(this._repo);

  Future<Either<Failure, String>> call(String centerId, {
    required DateTime from,
    required DateTime to,
  }) =>
      _repo.exportRevenueCsv(centerId, from: from, to: to);
}
