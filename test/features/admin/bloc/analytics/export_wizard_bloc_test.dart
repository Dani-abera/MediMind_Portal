import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:medimind_portal/core/error/failures.dart';
import 'package:medimind_portal/features/admin/domain/entities/analytics_data.dart';
import 'package:medimind_portal/features/admin/domain/usecases/export_analytics_usecase.dart';
import 'package:medimind_portal/features/admin/presentation/bloc/export_wizard/export_wizard_bloc.dart';

class MockExportAnalyticsCsvUseCase extends Mock implements ExportAnalyticsCsvUseCase {}
class MockExportAnalyticsPdfUseCase extends Mock implements ExportAnalyticsPdfUseCase {}
class MockExportRevenueCsvUseCase extends Mock implements ExportRevenueCsvUseCase {}

void main() {
  late MockExportAnalyticsCsvUseCase mockCsv;
  late MockExportAnalyticsPdfUseCase mockPdf;
  late MockExportRevenueCsvUseCase mockRevenueCsv;

  const centerId = 'center-1';

  setUp(() {
    mockCsv = MockExportAnalyticsCsvUseCase();
    mockPdf = MockExportAnalyticsPdfUseCase();
    mockRevenueCsv = MockExportRevenueCsvUseCase();
  });

  ExportWizardBloc bloc() => ExportWizardBloc(
        exportAnalyticsCsv: mockCsv,
        exportAnalyticsPdf: mockPdf,
        exportRevenueCsv: mockRevenueCsv,
      );

  group('Step navigation', () {
    blocTest<ExportWizardBloc, ExportWizardState>(
      'Started emits Step1',
      build: () => bloc(),
      act: (b) => b.add(const ExportWizardStarted(centerId)),
      expect: () => [isA<ExportWizardStep1>()],
    );

    blocTest<ExportWizardBloc, ExportWizardState>(
      'DataTypeSelected advances to Step2',
      build: () => bloc(),
      act: (b) {
        b.add(const ExportWizardStarted(centerId));
        b.add(const ExportDataTypeSelected(ExportDataType.appointments));
      },
      expect: () => [isA<ExportWizardStep1>(), isA<ExportWizardStep2>()],
    );

    blocTest<ExportWizardBloc, ExportWizardState>(
      'DateRangeSelected advances Step2 → Step3',
      build: () => bloc(),
      act: (b) {
        b.add(const ExportWizardStarted(centerId));
        b.add(const ExportDataTypeSelected(ExportDataType.revenue));
        b.add(const ExportDateRangeSelected(DateRangePreset.last30));
      },
      expect: () => [isA<ExportWizardStep1>(), isA<ExportWizardStep2>(), isA<ExportWizardStep3>()],
    );

    blocTest<ExportWizardBloc, ExportWizardState>(
      'FormatSelected advances Step3 → Step4',
      build: () => bloc(),
      act: (b) {
        b.add(const ExportWizardStarted(centerId));
        b.add(const ExportDataTypeSelected(ExportDataType.appointments));
        b.add(const ExportDateRangeSelected(DateRangePreset.last7));
        b.add(const ExportFormatSelected(ExportFormat.csv));
      },
      expect: () => [
        isA<ExportWizardStep1>(),
        isA<ExportWizardStep2>(),
        isA<ExportWizardStep3>(),
        isA<ExportWizardStep4>(),
      ],
    );

    blocTest<ExportWizardBloc, ExportWizardState>(
      'StepBack goes from Step2 to Step1',
      build: () => bloc(),
      act: (b) {
        b.add(const ExportWizardStarted(centerId));
        b.add(const ExportDataTypeSelected(ExportDataType.appointments));
        b.add(const ExportWizardStepBack());
      },
      expect: () => [isA<ExportWizardStep1>(), isA<ExportWizardStep2>(), isA<ExportWizardStep1>()],
    );

    blocTest<ExportWizardBloc, ExportWizardState>(
      'Reset returns to Step1',
      build: () => bloc(),
      act: (b) {
        b.add(const ExportWizardStarted(centerId));
        b.add(const ExportDataTypeSelected(ExportDataType.appointments));
        b.add(const ExportDateRangeSelected(DateRangePreset.last30));
        b.add(const ExportWizardReset());
      },
      expect: () => [
        isA<ExportWizardStep1>(),
        isA<ExportWizardStep2>(),
        isA<ExportWizardStep3>(),
        isA<ExportWizardStep1>(),
      ],
    );
  });

  group('ExportGenerateRequested', () {
    blocTest<ExportWizardBloc, ExportWizardState>(
      'generates CSV for appointments data',
      build: () {
        when(() => mockCsv(any(), from: any(named: 'from'), to: any(named: 'to')))
            .thenAnswer((_) async => const Right(''));
        return bloc();
      },
      act: (b) async {
        b.add(const ExportWizardStarted(centerId));
        b.add(const ExportDataTypeSelected(ExportDataType.appointments));
        b.add(const ExportDateRangeSelected(DateRangePreset.last30));
        b.add(const ExportFormatSelected(ExportFormat.csv));
        b.add(const ExportGenerateRequested());
      },
      expect: () => [
        isA<ExportWizardStep1>(),
        isA<ExportWizardStep2>(),
        isA<ExportWizardStep3>(),
        isA<ExportWizardStep4>(),
        isA<ExportWizardExporting>(),
        isA<ExportWizardDone>(),
      ],
      verify: (_) => verify(() => mockCsv(any(), from: any(named: 'from'), to: any(named: 'to'))).called(1),
    );

    blocTest<ExportWizardBloc, ExportWizardState>(
      'generates revenue CSV when data type is revenue',
      build: () {
        when(() => mockRevenueCsv(any(), from: any(named: 'from'), to: any(named: 'to')))
            .thenAnswer((_) async => const Right(''));
        return bloc();
      },
      act: (b) async {
        b.add(const ExportWizardStarted(centerId));
        b.add(const ExportDataTypeSelected(ExportDataType.revenue));
        b.add(const ExportDateRangeSelected(DateRangePreset.last30));
        b.add(const ExportFormatSelected(ExportFormat.csv));
        b.add(const ExportGenerateRequested());
      },
      expect: () => [
        isA<ExportWizardStep1>(),
        isA<ExportWizardStep2>(),
        isA<ExportWizardStep3>(),
        isA<ExportWizardStep4>(),
        isA<ExportWizardExporting>(),
        isA<ExportWizardDone>(),
      ],
      verify: (_) {
        verify(() => mockRevenueCsv(any(), from: any(named: 'from'), to: any(named: 'to'))).called(1);
        verifyNever(() => mockCsv(any(), from: any(named: 'from'), to: any(named: 'to')));
      },
    );

    blocTest<ExportWizardBloc, ExportWizardState>(
      'emits Failed on export error',
      build: () {
        when(() => mockCsv(any(), from: any(named: 'from'), to: any(named: 'to')))
            .thenAnswer((_) async => const Left(ServerFailure('Export error')));
        return bloc();
      },
      act: (b) async {
        b.add(const ExportWizardStarted(centerId));
        b.add(const ExportDataTypeSelected(ExportDataType.appointments));
        b.add(const ExportDateRangeSelected(DateRangePreset.last7));
        b.add(const ExportFormatSelected(ExportFormat.csv));
        b.add(const ExportGenerateRequested());
      },
      expect: () => [
        isA<ExportWizardStep1>(),
        isA<ExportWizardStep2>(),
        isA<ExportWizardStep3>(),
        isA<ExportWizardStep4>(),
        isA<ExportWizardExporting>(),
        isA<ExportWizardFailed>(),
      ],
      verify: (b) {
        final failed = b.state as ExportWizardFailed;
        expect(failed.message, 'Export error');
      },
    );

    blocTest<ExportWizardBloc, ExportWizardState>(
      'does nothing when not in step4',
      build: () => bloc(),
      act: (b) {
        b.add(const ExportWizardStarted(centerId));
        b.add(const ExportGenerateRequested()); // step1 — should no-op
      },
      expect: () => [isA<ExportWizardStep1>()],
      verify: (_) {
        verifyNever(() => mockCsv(any(), from: any(named: 'from'), to: any(named: 'to')));
        verifyNever(() => mockPdf(any(), from: any(named: 'from'), to: any(named: 'to')));
      },
    );
  });
}
