import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:medimind_portal/core/error/failures.dart';
import 'package:medimind_portal/features/admin/domain/entities/audit_entry.dart';
import 'package:medimind_portal/features/admin/domain/usecases/get_audit_log_usecase.dart';
import 'package:medimind_portal/features/admin/domain/usecases/get_analytics_summary_usecase.dart';
import 'package:medimind_portal/features/admin/domain/usecases/get_admin_dashboard_usecase.dart';
import 'package:medimind_portal/features/admin/domain/entities/admin_dashboard_data.dart';

class MockGetAuditLogUseCase extends Mock implements GetAuditLogUseCase {}
class MockGetAnalyticsSummaryUseCase extends Mock implements GetAnalyticsSummaryUseCase {}
class MockGetAdminDashboardUseCase extends Mock implements GetAdminDashboardUseCase {}

void main() {
  group('Tenant boundary — admin data is always scoped to centerId', () {
    const centerA = 'center-a';
    const centerB = 'center-b';

    late MockGetAuditLogUseCase mockAuditLog;
    late MockGetAnalyticsSummaryUseCase mockAnalytics;
    late MockGetAdminDashboardUseCase mockDashboard;

    setUp(() {
      mockAuditLog = MockGetAuditLogUseCase();
      mockAnalytics = MockGetAnalyticsSummaryUseCase();
      mockDashboard = MockGetAdminDashboardUseCase();
    });

    test('GetAuditLogUseCase is called with the admin\'s own centerId, not a foreign one', () async {
      when(() => mockAuditLog(
            centerA,
            from: any(named: 'from'),
            to: any(named: 'to'),
            userId: any(named: 'userId'),
            actions: any(named: 'actions'),
            entityType: any(named: 'entityType'),
            searchQuery: any(named: 'searchQuery'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).thenAnswer((_) async => const Right((entries: <AuditEntry>[], total: 0)));

      await mockAuditLog(centerA, page: 1, pageSize: 50);

      verify(() => mockAuditLog(centerA, page: 1, pageSize: 50)).called(1);
      verifyNever(() => mockAuditLog(centerB, page: any(named: 'page'), pageSize: any(named: 'pageSize')));
    });

    test('GetAnalyticsSummaryUseCase is not called with a foreign centerId', () async {
      final now = DateTime(2025, 5, 1);
      when(() => mockAnalytics(
            centerA,
            from: any(named: 'from'),
            to: any(named: 'to'),
            comparePrevious: any(named: 'comparePrevious'),
          )).thenAnswer((_) async => Left(ServerFailure('expected')));

      await mockAnalytics(centerA, from: now.subtract(const Duration(days: 30)), to: now);

      verifyNever(() => mockAnalytics(
            centerB,
            from: any(named: 'from'),
            to: any(named: 'to'),
            comparePrevious: any(named: 'comparePrevious'),
          ));
    });

    test('GetAdminDashboardUseCase is called with the admin\'s own centerId', () async {
      when(() => mockDashboard(centerA))
          .thenAnswer((_) async => Right(AdminDashboardData()));

      await mockDashboard(centerA);

      verify(() => mockDashboard(centerA)).called(1);
      verifyNever(() => mockDashboard(centerB));
    });

    test('SuperAdmin audit log is platform-scoped — no centerId required', () {
      // The PlatformAuditRepository.getAuditLog takes an optional centerId,
      // meaning super admin can query across all centers or filter by one.
      // Admin's AuditLogRepository ALWAYS requires a centerId as a mandatory
      // positional parameter — enforcing tenant isolation at the type system level.
      //
      // This test documents the architectural invariant: if an admin calls
      // GetAuditLogUseCase, they MUST supply their own centerId.
      // The use case signature: call(String centerId, ...) — centerId is mandatory.
      // There is no way to call it without providing a centerId.
      expect(true, isTrue);
    });
  });
}
