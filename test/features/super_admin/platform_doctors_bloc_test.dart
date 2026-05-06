import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:medimind_portal/core/error/failures.dart';
import 'package:medimind_portal/features/super_admin/domain/entities/platform_doctor.dart';
import 'package:medimind_portal/features/super_admin/domain/usecases/get_platform_doctors_usecase.dart';
import 'package:medimind_portal/features/super_admin/domain/usecases/verify_doctor_license_usecase.dart';
import 'package:medimind_portal/features/super_admin/domain/usecases/suspend_platform_doctor_usecase.dart';
import 'package:medimind_portal/features/super_admin/presentation/bloc/doctors/platform_doctors_bloc.dart';

class MockGetPlatformDoctorsUseCase extends Mock implements GetPlatformDoctorsUseCase {}
class MockVerifyDoctorLicenseUseCase extends Mock implements VerifyDoctorLicenseUseCase {}
class MockSuspendPlatformDoctorUseCase extends Mock implements SuspendPlatformDoctorUseCase {}

PlatformDoctor _doctor(String id, {bool verified = true}) => PlatformDoctor(
      id: id,
      fullName: 'Dr. $id',
      licenseNumber: 'LIC-$id',
      specialization: 'General',
      licenseVerified: verified,
      createdAt: DateTime(2025, 1, 1),
    );

void main() {
  late MockGetPlatformDoctorsUseCase mockGetDoctors;
  late MockVerifyDoctorLicenseUseCase mockVerify;
  late MockSuspendPlatformDoctorUseCase mockSuspend;

  setUp(() {
    mockGetDoctors = MockGetPlatformDoctorsUseCase();
    mockVerify = MockVerifyDoctorLicenseUseCase();
    mockSuspend = MockSuspendPlatformDoctorUseCase();
  });

  PlatformDoctorsBloc bloc() => PlatformDoctorsBloc(
        getDoctors: mockGetDoctors,
        verify: mockVerify,
        suspend: mockSuspend,
      );

  void stubGetSuccess([List<PlatformDoctor>? doctors]) {
    when(() => mockGetDoctors(
          status: any(named: 'status'),
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
        )).thenAnswer((_) async => Right((
          doctors: doctors ?? [_doctor('d-1'), _doctor('d-2')],
          total: doctors?.length ?? 2,
        )));
  }

  void stubGetFailure(String msg) {
    when(() => mockGetDoctors(
          status: any(named: 'status'),
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
        )).thenAnswer((_) async => Left(ServerFailure(msg)));
  }

  group('PlatformDoctorsStarted', () {
    blocTest<PlatformDoctorsBloc, PlatformDoctorsState>(
      'emits Loading then Loaded on success',
      build: () {
        stubGetSuccess();
        return bloc();
      },
      act: (b) => b.add(const PlatformDoctorsStarted()),
      expect: () => [isA<PlatformDoctorsLoading>(), isA<PlatformDoctorsLoaded>()],
    );

    blocTest<PlatformDoctorsBloc, PlatformDoctorsState>(
      'Loaded state has correct doctor count and total',
      build: () {
        stubGetSuccess([_doctor('d-1'), _doctor('d-2'), _doctor('d-3')]);
        return bloc();
      },
      act: (b) => b.add(const PlatformDoctorsStarted()),
      expect: () => [
        isA<PlatformDoctorsLoading>(),
        predicate<PlatformDoctorsState>((s) =>
            s is PlatformDoctorsLoaded && s.total == 3 && s.doctors.length == 3),
      ],
    );

    blocTest<PlatformDoctorsBloc, PlatformDoctorsState>(
      'emits Error on failure',
      build: () {
        stubGetFailure('Server error');
        return bloc();
      },
      act: (b) => b.add(const PlatformDoctorsStarted()),
      expect: () => [
        isA<PlatformDoctorsLoading>(),
        predicate<PlatformDoctorsState>(
            (s) => s is PlatformDoctorsError && s.message == 'Server error'),
      ],
    );
  });

  group('PlatformDoctorsFiltered', () {
    blocTest<PlatformDoctorsBloc, PlatformDoctorsState>(
      'filters pending doctors and resets to page 1',
      build: () {
        stubGetSuccess([_doctor('d-1', verified: false)]);
        return bloc();
      },
      act: (b) => b.add(const PlatformDoctorsFiltered(statusFilter: 'pending')),
      expect: () => [isA<PlatformDoctorsLoading>(), isA<PlatformDoctorsLoaded>()],
      verify: (_) {
        verify(() => mockGetDoctors(
              status: 'pending',
              page: 1,
              pageSize: any(named: 'pageSize'),
            )).called(1);
      },
    );
  });

  group('DoctorVerifyLicenseRequested — license verification flow', () {
    blocTest<PlatformDoctorsBloc, PlatformDoctorsState>(
      'emits ActionSuccess then reloads list on verify success',
      build: () {
        stubGetSuccess();
        when(() => mockVerify(any(), notes: any(named: 'notes')))
            .thenAnswer((_) async => const Right(null));
        return bloc();
      },
      act: (b) => b.add(const DoctorVerifyLicenseRequested('d-1', notes: 'All docs verified')),
      expect: () => [
        predicate<PlatformDoctorsState>(
            (s) => s is PlatformDoctorsActionSuccess && s.message.contains('verified')),
        isA<PlatformDoctorsLoading>(),
        isA<PlatformDoctorsLoaded>(),
      ],
    );

    blocTest<PlatformDoctorsBloc, PlatformDoctorsState>(
      'emits ActionError when verify fails',
      build: () {
        when(() => mockVerify(any(), notes: any(named: 'notes')))
            .thenAnswer((_) async => Left(ServerFailure('Verify failed')));
        return bloc();
      },
      act: (b) => b.add(const DoctorVerifyLicenseRequested('d-1')),
      expect: () => [
        predicate<PlatformDoctorsState>(
            (s) => s is PlatformDoctorsActionError && s.message == 'Verify failed'),
      ],
    );

    blocTest<PlatformDoctorsBloc, PlatformDoctorsState>(
      'verify without notes still calls use case',
      build: () {
        stubGetSuccess();
        when(() => mockVerify(any(), notes: any(named: 'notes')))
            .thenAnswer((_) async => const Right(null));
        return bloc();
      },
      act: (b) => b.add(const DoctorVerifyLicenseRequested('d-99')),
      verify: (_) {
        verify(() => mockVerify('d-99', notes: null)).called(1);
      },
    );
  });

  group('DoctorSuspendRequested', () {
    blocTest<PlatformDoctorsBloc, PlatformDoctorsState>(
      'emits ActionSuccess and re-fetches list on suspend',
      build: () {
        stubGetSuccess();
        when(() => mockSuspend(any(), reason: any(named: 'reason')))
            .thenAnswer((_) async => const Right(null));
        return bloc();
      },
      act: (b) => b.add(const DoctorSuspendRequested('d-1', 'Policy violation')),
      expect: () => [
        isA<PlatformDoctorsActionSuccess>(),
        isA<PlatformDoctorsLoading>(),
        isA<PlatformDoctorsLoaded>(),
      ],
    );

    blocTest<PlatformDoctorsBloc, PlatformDoctorsState>(
      'emits ActionError when suspend fails',
      build: () {
        when(() => mockSuspend(any(), reason: any(named: 'reason')))
            .thenAnswer((_) async => Left(ForbiddenFailure('Not allowed')));
        return bloc();
      },
      act: (b) => b.add(const DoctorSuspendRequested('d-1', 'reason')),
      expect: () => [
        predicate<PlatformDoctorsState>(
            (s) => s is PlatformDoctorsActionError && s.message == 'Not allowed'),
      ],
    );
  });
}
