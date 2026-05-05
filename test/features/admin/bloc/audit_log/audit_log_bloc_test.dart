import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:medimind_portal/core/error/failures.dart';
import 'package:medimind_portal/features/admin/domain/entities/audit_entry.dart';
import 'package:medimind_portal/features/admin/domain/usecases/get_audit_log_usecase.dart';
import 'package:medimind_portal/features/admin/presentation/bloc/audit_log/audit_log_bloc.dart';

class MockGetAuditLogUseCase extends Mock implements GetAuditLogUseCase {}

AuditEntry _entry(String id) => AuditEntry(
      id: id,
      timestamp: DateTime(2025, 1, 1),
      userId: 'user-1',
      userName: 'Alice',
      userRole: 'admin',
      action: AuditAction.appointmentApproved,
      entityType: 'Appointment',
      entityId: 'appt-1',
      ipAddress: '127.0.0.1',
      userAgent: null,
      metadata: const {},
    );

void main() {
  late MockGetAuditLogUseCase mockGetAuditLog;

  const centerId = 'center-1';

  final emptyResult = (entries: <AuditEntry>[], total: 0);
  final loadedResult = (entries: [_entry('e-1'), _entry('e-2')], total: 2);

  setUp(() {
    mockGetAuditLog = MockGetAuditLogUseCase();
  });

  AuditLogBloc bloc() => AuditLogBloc(getAuditLog: mockGetAuditLog);

  void stubSuccess([({List<AuditEntry> entries, int total})? result]) {
    when(() => mockGetAuditLog(
          any(),
          from: any(named: 'from'),
          to: any(named: 'to'),
          userId: any(named: 'userId'),
          actions: any(named: 'actions'),
          entityType: any(named: 'entityType'),
          searchQuery: any(named: 'searchQuery'),
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
        )).thenAnswer((_) async => Right(result ?? emptyResult));
  }

  void stubFailure(String msg) {
    when(() => mockGetAuditLog(
          any(),
          from: any(named: 'from'),
          to: any(named: 'to'),
          userId: any(named: 'userId'),
          actions: any(named: 'actions'),
          entityType: any(named: 'entityType'),
          searchQuery: any(named: 'searchQuery'),
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
        )).thenAnswer((_) async => Left(ServerFailure(msg)));
  }

  group('AuditLogStarted', () {
    blocTest<AuditLogBloc, AuditLogState>(
      'emits Loading then Loaded on success',
      build: () {
        stubSuccess();
        return bloc();
      },
      act: (b) => b.add(const AuditLogStarted(centerId)),
      expect: () => [isA<AuditLogLoading>(), isA<AuditLogLoaded>()],
    );

    blocTest<AuditLogBloc, AuditLogState>(
      'emits Loading then Error on failure',
      build: () {
        stubFailure('Network error');
        return bloc();
      },
      act: (b) => b.add(const AuditLogStarted(centerId)),
      expect: () => [isA<AuditLogLoading>(), isA<AuditLogError>()],
      verify: (b) => expect((b.state as AuditLogError).message, 'Network error'),
    );

    blocTest<AuditLogBloc, AuditLogState>(
      'loaded state contains entries and total',
      build: () {
        stubSuccess(loadedResult);
        return bloc();
      },
      act: (b) => b.add(const AuditLogStarted(centerId)),
      verify: (b) {
        final s = b.state as AuditLogLoaded;
        expect(s.entries.length, 2);
        expect(s.total, 2);
        expect(s.page, 1);
      },
    );
  });

  group('AuditLogFiltered', () {
    blocTest<AuditLogBloc, AuditLogState>(
      'resets to page 1 and refetches with new filters',
      build: () {
        stubSuccess();
        return bloc();
      },
      act: (b) async {
        b.add(const AuditLogStarted(centerId));
        await Future<void>.delayed(Duration.zero);
        b.add(AuditLogFiltered(const AuditLogFilters(searchQuery: 'doctor')));
      },
      expect: () => [
        isA<AuditLogLoading>(),
        isA<AuditLogLoaded>(),
        isA<AuditLogLoading>(),
        isA<AuditLogLoaded>(),
      ],
      verify: (_) => verify(() => mockGetAuditLog(
            any(),
            from: any(named: 'from'),
            to: any(named: 'to'),
            userId: any(named: 'userId'),
            actions: any(named: 'actions'),
            entityType: any(named: 'entityType'),
            searchQuery: any(named: 'searchQuery'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).called(2),
    );

    blocTest<AuditLogBloc, AuditLogState>(
      'loaded state reflects applied filters',
      build: () {
        stubSuccess();
        return bloc();
      },
      act: (b) async {
        b.add(const AuditLogStarted(centerId));
        await Future<void>.delayed(Duration.zero);
        b.add(AuditLogFiltered(const AuditLogFilters(searchQuery: 'alice')));
      },
      verify: (b) {
        final s = b.state as AuditLogLoaded;
        expect(s.filters.searchQuery, 'alice');
        expect(s.page, 1);
      },
    );
  });

  group('AuditLogPageChanged', () {
    blocTest<AuditLogBloc, AuditLogState>(
      'changes page and refetches',
      build: () {
        stubSuccess();
        return bloc();
      },
      act: (b) async {
        b.add(const AuditLogStarted(centerId));
        await Future<void>.delayed(Duration.zero);
        b.add(const AuditLogPageChanged(3));
      },
      expect: () => [
        isA<AuditLogLoading>(),
        isA<AuditLogLoaded>(),
        isA<AuditLogLoading>(),
        isA<AuditLogLoaded>(),
      ],
      verify: (b) => expect((b.state as AuditLogLoaded).page, 3),
    );
  });

  group('AuditLogRefreshed', () {
    blocTest<AuditLogBloc, AuditLogState>(
      'fetches again and emits updated Loaded',
      build: () {
        var callCount = 0;
        when(() => mockGetAuditLog(
              any(),
              from: any(named: 'from'),
              to: any(named: 'to'),
              userId: any(named: 'userId'),
              actions: any(named: 'actions'),
              entityType: any(named: 'entityType'),
              searchQuery: any(named: 'searchQuery'),
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenAnswer((_) async {
          callCount++;
          return callCount == 1 ? Right(emptyResult) : Right(loadedResult);
        });
        return bloc();
      },
      act: (b) async {
        b.add(const AuditLogStarted(centerId));
        await Future<void>.delayed(Duration.zero);
        b.add(const AuditLogRefreshed());
      },
      expect: () => [
        isA<AuditLogLoading>(),
        isA<AuditLogLoaded>(),
        isA<AuditLogLoaded>(),
      ],
      verify: (b) {
        final state = b.state as AuditLogLoaded;
        expect(state.entries.length, 2);
      },
    );
  });

  group('AuditLogExportRequested', () {
    blocTest<AuditLogBloc, AuditLogState>(
      'does nothing when not in Loaded state',
      build: () => bloc(),
      act: (b) => b.add(const AuditLogExportRequested()),
      expect: () => [],
      verify: (_) => verifyNever(() => mockGetAuditLog(
            any(),
            from: any(named: 'from'),
            to: any(named: 'to'),
            userId: any(named: 'userId'),
            actions: any(named: 'actions'),
            entityType: any(named: 'entityType'),
            searchQuery: any(named: 'searchQuery'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )),
    );
  });
}
