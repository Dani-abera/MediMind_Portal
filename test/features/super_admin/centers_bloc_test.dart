import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:medimind_portal/core/error/failures.dart';
import 'package:medimind_portal/features/super_admin/domain/entities/platform_center.dart';
import 'package:medimind_portal/features/super_admin/domain/usecases/get_platform_centers_usecase.dart';
import 'package:medimind_portal/features/super_admin/domain/usecases/approve_center_usecase.dart';
import 'package:medimind_portal/features/super_admin/domain/usecases/reject_center_usecase.dart';
import 'package:medimind_portal/features/super_admin/domain/usecases/suspend_center_usecase.dart';
import 'package:medimind_portal/features/super_admin/domain/usecases/reactivate_center_usecase.dart';
import 'package:medimind_portal/features/super_admin/presentation/bloc/centers/centers_bloc.dart';

class MockGetPlatformCentersUseCase extends Mock implements GetPlatformCentersUseCase {}
class MockApproveCenterUseCase extends Mock implements ApproveCenterUseCase {}
class MockRejectCenterUseCase extends Mock implements RejectCenterUseCase {}
class MockSuspendCenterUseCase extends Mock implements SuspendCenterUseCase {}
class MockReactivateCenterUseCase extends Mock implements ReactivateCenterUseCase {}

PlatformCenter _center(String id, {CenterStatus status = CenterStatus.active}) =>
    PlatformCenter(id: id, name: 'Center $id', createdAt: DateTime(2025, 1, 1), status: status);

void main() {
  late MockGetPlatformCentersUseCase mockGetCenters;
  late MockApproveCenterUseCase mockApprove;
  late MockRejectCenterUseCase mockReject;
  late MockSuspendCenterUseCase mockSuspend;
  late MockReactivateCenterUseCase mockReactivate;

  final trialEnd = DateTime(2025, 6, 1);

  setUp(() {
    mockGetCenters = MockGetPlatformCentersUseCase();
    mockApprove = MockApproveCenterUseCase();
    mockReject = MockRejectCenterUseCase();
    mockSuspend = MockSuspendCenterUseCase();
    mockReactivate = MockReactivateCenterUseCase();

    registerFallbackValue(trialEnd);
  });

  CentersBloc bloc() => CentersBloc(
        getCenters: mockGetCenters,
        approve: mockApprove,
        reject: mockReject,
        suspend: mockSuspend,
        reactivate: mockReactivate,
      );

  void stubGetSuccess([List<PlatformCenter>? centers]) {
    when(() => mockGetCenters(
          status: any(named: 'status'),
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
        )).thenAnswer((_) async => Right((
          centers: centers ?? [_center('c-1'), _center('c-2')],
          total: centers?.length ?? 2,
        )));
  }

  void stubGetFailure(String msg) {
    when(() => mockGetCenters(
          status: any(named: 'status'),
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
        )).thenAnswer((_) async => Left(ServerFailure(msg)));
  }

  group('CentersStarted', () {
    blocTest<CentersBloc, CentersState>(
      'emits Loading then Loaded on success',
      build: () {
        stubGetSuccess();
        return bloc();
      },
      act: (b) => b.add(const CentersStarted()),
      expect: () => [isA<CentersLoading>(), isA<CentersLoaded>()],
    );

    blocTest<CentersBloc, CentersState>(
      'Loaded state contains correct centers and total',
      build: () {
        stubGetSuccess([_center('c-1'), _center('c-2'), _center('c-3')]);
        return bloc();
      },
      act: (b) => b.add(const CentersStarted()),
      expect: () => [
        isA<CentersLoading>(),
        predicate<CentersState>((s) =>
            s is CentersLoaded && s.total == 3 && s.centers.length == 3),
      ],
    );

    blocTest<CentersBloc, CentersState>(
      'emits Error on network failure',
      build: () {
        stubGetFailure('Network error');
        return bloc();
      },
      act: (b) => b.add(const CentersStarted()),
      expect: () => [
        isA<CentersLoading>(),
        predicate<CentersState>(
            (s) => s is CentersError && s.message == 'Network error'),
      ],
    );
  });

  group('CentersFiltered', () {
    blocTest<CentersBloc, CentersState>(
      'filters by pending status and resets to page 1',
      build: () {
        stubGetSuccess([_center('c-1', status: CenterStatus.pending)]);
        return bloc();
      },
      act: (b) => b.add(const CentersFiltered(statusFilter: 'pending')),
      expect: () => [isA<CentersLoading>(), isA<CentersLoaded>()],
      verify: (_) {
        verify(() => mockGetCenters(
              status: 'pending',
              page: 1,
              pageSize: any(named: 'pageSize'),
            )).called(1);
      },
    );

    blocTest<CentersBloc, CentersState>(
      'clears filter when status is null',
      build: () {
        stubGetSuccess();
        return bloc();
      },
      act: (b) => b.add(const CentersFiltered()),
      expect: () => [isA<CentersLoading>(), isA<CentersLoaded>()],
      verify: (_) {
        verify(() => mockGetCenters(
              status: null,
              page: 1,
              pageSize: any(named: 'pageSize'),
            )).called(1);
      },
    );
  });

  group('CentersPageChanged', () {
    blocTest<CentersBloc, CentersState>(
      'fetches page 2 when page changed to 2',
      build: () {
        stubGetSuccess();
        return bloc();
      },
      act: (b) => b.add(const CentersPageChanged(2)),
      expect: () => [isA<CentersLoading>(), isA<CentersLoaded>()],
      verify: (_) {
        verify(() => mockGetCenters(
              status: any(named: 'status'),
              page: 2,
              pageSize: any(named: 'pageSize'),
            )).called(1);
      },
    );
  });

  group('CenterApproveRequested', () {
    blocTest<CentersBloc, CentersState>(
      'emits ActionSuccess and then re-fetches list',
      build: () {
        stubGetSuccess();
        when(() => mockApprove(
              any(),
              trialEndDate: any(named: 'trialEndDate'),
              notes: any(named: 'notes'),
            )).thenAnswer((_) async => const Right(null));
        return bloc();
      },
      act: (b) => b.add(CenterApproveRequested('c-1', trialEnd)),
      expect: () => [
        isA<CentersActionSuccess>(),
        isA<CentersLoading>(),
        isA<CentersLoaded>(),
      ],
    );

    blocTest<CentersBloc, CentersState>(
      'emits ActionError when approve fails',
      build: () {
        when(() => mockApprove(
              any(),
              trialEndDate: any(named: 'trialEndDate'),
              notes: any(named: 'notes'),
            )).thenAnswer((_) async => Left(ServerFailure('Approve failed')));
        return bloc();
      },
      act: (b) => b.add(CenterApproveRequested('c-1', trialEnd)),
      expect: () => [
        predicate<CentersState>(
            (s) => s is CentersActionError && s.message == 'Approve failed'),
      ],
    );
  });

  group('CenterRejectRequested', () {
    blocTest<CentersBloc, CentersState>(
      'emits ActionSuccess with reason and re-fetches',
      build: () {
        stubGetSuccess();
        when(() => mockReject(any(), reason: any(named: 'reason')))
            .thenAnswer((_) async => const Right(null));
        return bloc();
      },
      act: (b) => b.add(const CenterRejectRequested('c-1', 'Incomplete documents')),
      expect: () => [
        isA<CentersActionSuccess>(),
        isA<CentersLoading>(),
        isA<CentersLoaded>(),
      ],
    );
  });

  group('CenterReactivateRequested', () {
    blocTest<CentersBloc, CentersState>(
      'emits ActionSuccess and re-fetches list',
      build: () {
        stubGetSuccess();
        when(() => mockReactivate(any()))
            .thenAnswer((_) async => const Right(null));
        return bloc();
      },
      act: (b) => b.add(const CenterReactivateRequested('c-1')),
      expect: () => [
        isA<CentersActionSuccess>(),
        isA<CentersLoading>(),
        isA<CentersLoaded>(),
      ],
    );
  });
}
