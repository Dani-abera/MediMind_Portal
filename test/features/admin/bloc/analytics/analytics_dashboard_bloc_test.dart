import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:medimind_portal/core/error/failures.dart';
import 'package:medimind_portal/features/admin/domain/entities/analytics_data.dart';
import 'package:medimind_portal/features/admin/domain/usecases/get_analytics_summary_usecase.dart';
import 'package:medimind_portal/features/admin/domain/usecases/export_analytics_usecase.dart';
import 'package:medimind_portal/features/admin/presentation/bloc/analytics/analytics_dashboard_bloc.dart';

class MockGetAnalyticsSummaryUseCase extends Mock implements GetAnalyticsSummaryUseCase {}
class MockExportAnalyticsCsvUseCase extends Mock implements ExportAnalyticsCsvUseCase {}
class MockExportAnalyticsPdfUseCase extends Mock implements ExportAnalyticsPdfUseCase {}

void main() {
  late MockGetAnalyticsSummaryUseCase mockGetSummary;
  late MockExportAnalyticsCsvUseCase mockExportCsv;
  late MockExportAnalyticsPdfUseCase mockExportPdf;

  const centerId = 'center-1';
  const emptySummary = AnalyticsSummary();

  setUp(() {
    mockGetSummary = MockGetAnalyticsSummaryUseCase();
    mockExportCsv = MockExportAnalyticsCsvUseCase();
    mockExportPdf = MockExportAnalyticsPdfUseCase();
  });

  AnalyticsDashboardBloc bloc() => AnalyticsDashboardBloc(
        getSummary: mockGetSummary,
        exportCsv: mockExportCsv,
        exportPdf: mockExportPdf,
      );

  group('AnalyticsDashboardStarted', () {
    blocTest<AnalyticsDashboardBloc, AnalyticsDashboardState>(
      'emits Loading then Loaded on success',
      build: () {
        when(() => mockGetSummary(centerId,
                from: any(named: 'from'),
                to: any(named: 'to'),
                comparePrevious: any(named: 'comparePrevious')))
            .thenAnswer((_) async => const Right(emptySummary));
        return bloc();
      },
      act: (b) => b.add(const AnalyticsDashboardStarted(centerId)),
      expect: () => [
        isA<AnalyticsDashboardLoading>(),
        isA<AnalyticsDashboardLoaded>(),
      ],
    );

    blocTest<AnalyticsDashboardBloc, AnalyticsDashboardState>(
      'emits Error on network failure',
      build: () {
        when(() => mockGetSummary(centerId,
                from: any(named: 'from'),
                to: any(named: 'to'),
                comparePrevious: any(named: 'comparePrevious')))
            .thenAnswer((_) async => const Left(NetworkFailure()));
        return bloc();
      },
      act: (b) => b.add(const AnalyticsDashboardStarted(centerId)),
      expect: () => [
        isA<AnalyticsDashboardLoading>(),
        isA<AnalyticsDashboardError>(),
      ],
    );

    blocTest<AnalyticsDashboardBloc, AnalyticsDashboardState>(
      'loaded state contains correct preset and data',
      build: () {
        when(() => mockGetSummary(centerId,
                from: any(named: 'from'),
                to: any(named: 'to'),
                comparePrevious: any(named: 'comparePrevious')))
            .thenAnswer((_) async => const Right(
                  AnalyticsSummary(totalAppointments: 42, noShowRate: 5.5),
                ));
        return bloc();
      },
      act: (b) => b.add(const AnalyticsDashboardStarted(centerId, preset: DateRangePreset.last7)),
      verify: (b) {
        final state = b.state as AnalyticsDashboardLoaded;
        expect(state.data.totalAppointments, 42);
        expect(state.range.preset, DateRangePreset.last7);
        expect(state.comparePeriod, false);
      },
    );
  });

  group('AnalyticsDateRangeChanged', () {
    blocTest<AnalyticsDashboardBloc, AnalyticsDashboardState>(
      'refetches with new date range',
      build: () {
        when(() => mockGetSummary(any(),
                from: any(named: 'from'),
                to: any(named: 'to'),
                comparePrevious: any(named: 'comparePrevious')))
            .thenAnswer((_) async => const Right(emptySummary));
        return bloc();
      },
      act: (b) async {
        b.add(const AnalyticsDashboardStarted(centerId));
        await Future<void>.delayed(Duration.zero);
        b.add(const AnalyticsDateRangeChanged(DateRangePreset.last90));
      },
      expect: () => [
        isA<AnalyticsDashboardLoading>(),
        isA<AnalyticsDashboardLoaded>(),
        isA<AnalyticsDashboardLoading>(),
        isA<AnalyticsDashboardLoaded>(),
      ],
      verify: (_) => verify(() => mockGetSummary(any(),
              from: any(named: 'from'),
              to: any(named: 'to'),
              comparePrevious: any(named: 'comparePrevious')))
          .called(2),
    );

    blocTest<AnalyticsDashboardBloc, AnalyticsDashboardState>(
      'loaded state has last90 preset after range change',
      build: () {
        when(() => mockGetSummary(any(),
                from: any(named: 'from'),
                to: any(named: 'to'),
                comparePrevious: any(named: 'comparePrevious')))
            .thenAnswer((_) async => const Right(emptySummary));
        return bloc();
      },
      act: (b) async {
        b.add(const AnalyticsDashboardStarted(centerId));
        await Future<void>.delayed(Duration.zero);
        b.add(const AnalyticsDateRangeChanged(DateRangePreset.last90));
      },
      verify: (b) {
        final state = b.state as AnalyticsDashboardLoaded;
        expect(state.range.preset, DateRangePreset.last90);
      },
    );
  });

  group('AnalyticsComparePeriodToggled', () {
    blocTest<AnalyticsDashboardBloc, AnalyticsDashboardState>(
      'sets compare flag and triggers refresh',
      build: () {
        when(() => mockGetSummary(any(),
                from: any(named: 'from'),
                to: any(named: 'to'),
                comparePrevious: any(named: 'comparePrevious')))
            .thenAnswer((_) async => const Right(emptySummary));
        return bloc();
      },
      act: (b) async {
        b.add(const AnalyticsDashboardStarted(centerId));
        await Future<void>.delayed(Duration.zero);
        b.add(const AnalyticsComparePeriodToggled(true));
      },
      verify: (b) {
        final state = b.state as AnalyticsDashboardLoaded;
        expect(state.comparePeriod, true);
      },
    );
  });

  group('AnalyticsExportRequested', () {
    blocTest<AnalyticsDashboardBloc, AnalyticsDashboardState>(
      'emits Exporting then ExportDone on CSV success',
      build: () {
        when(() => mockGetSummary(any(),
                from: any(named: 'from'),
                to: any(named: 'to'),
                comparePrevious: any(named: 'comparePrevious')))
            .thenAnswer((_) async => const Right(emptySummary));
        when(() => mockExportCsv(any(), from: any(named: 'from'), to: any(named: 'to')))
            .thenAnswer((_) async => const Right('https://export.url/file.csv'));
        return bloc();
      },
      act: (b) async {
        b.add(const AnalyticsDashboardStarted(centerId));
        await Future<void>.delayed(Duration.zero);
        b.add(const AnalyticsExportRequested(ExportFormat.csv));
      },
      expect: () => [
        isA<AnalyticsDashboardLoading>(),
        isA<AnalyticsDashboardLoaded>(),
        isA<AnalyticsExporting>(),
        isA<AnalyticsExportDone>(),
      ],
      verify: (_) => verify(() => mockExportCsv(any(),
              from: any(named: 'from'), to: any(named: 'to')))
          .called(1),
    );

    blocTest<AnalyticsDashboardBloc, AnalyticsDashboardState>(
      'emits ExportError on export failure',
      build: () {
        when(() => mockGetSummary(any(),
                from: any(named: 'from'),
                to: any(named: 'to'),
                comparePrevious: any(named: 'comparePrevious')))
            .thenAnswer((_) async => const Right(emptySummary));
        when(() => mockExportCsv(any(), from: any(named: 'from'), to: any(named: 'to')))
            .thenAnswer((_) async => const Left(ServerFailure('Export failed')));
        return bloc();
      },
      act: (b) async {
        b.add(const AnalyticsDashboardStarted(centerId));
        await Future<void>.delayed(Duration.zero);
        b.add(const AnalyticsExportRequested(ExportFormat.csv));
      },
      expect: () => [
        isA<AnalyticsDashboardLoading>(),
        isA<AnalyticsDashboardLoaded>(),
        isA<AnalyticsExporting>(),
        isA<AnalyticsExportError>(),
      ],
    );
  });
}
