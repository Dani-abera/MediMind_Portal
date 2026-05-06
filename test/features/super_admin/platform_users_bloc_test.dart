import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:medimind_portal/core/error/failures.dart';
import 'package:medimind_portal/features/super_admin/domain/entities/platform_user.dart';
import 'package:medimind_portal/features/super_admin/domain/usecases/get_platform_users_usecase.dart';
import 'package:medimind_portal/features/super_admin/domain/usecases/suspend_user_usecase.dart';
import 'package:medimind_portal/features/super_admin/domain/usecases/reactivate_user_usecase.dart';
import 'package:medimind_portal/features/super_admin/domain/usecases/force_logout_user_usecase.dart';
import 'package:medimind_portal/features/super_admin/domain/usecases/delete_user_usecase.dart';
import 'package:medimind_portal/features/super_admin/presentation/bloc/users/platform_users_bloc.dart';

class MockGetPlatformUsersUseCase extends Mock implements GetPlatformUsersUseCase {}
class MockSuspendUserUseCase extends Mock implements SuspendUserUseCase {}
class MockReactivateUserUseCase extends Mock implements ReactivateUserUseCase {}
class MockForceLogoutUserUseCase extends Mock implements ForceLogoutUserUseCase {}
class MockDeleteUserUseCase extends Mock implements DeleteUserUseCase {}

PlatformUser _user(String id, {String type = 'patient', String status = 'active'}) =>
    PlatformUser(
      id: id,
      fullName: 'User $id',
      email: '$id@test.com',
      userType: type,
      status: status,
      createdAt: DateTime(2025, 1, 1),
    );

void main() {
  late MockGetPlatformUsersUseCase mockGetUsers;
  late MockSuspendUserUseCase mockSuspend;
  late MockReactivateUserUseCase mockReactivate;
  late MockForceLogoutUserUseCase mockForceLogout;
  late MockDeleteUserUseCase mockDelete;

  setUp(() {
    mockGetUsers = MockGetPlatformUsersUseCase();
    mockSuspend = MockSuspendUserUseCase();
    mockReactivate = MockReactivateUserUseCase();
    mockForceLogout = MockForceLogoutUserUseCase();
    mockDelete = MockDeleteUserUseCase();
  });

  PlatformUsersBloc bloc() => PlatformUsersBloc(
        getUsers: mockGetUsers,
        suspend: mockSuspend,
        reactivate: mockReactivate,
        forceLogout: mockForceLogout,
        delete: mockDelete,
      );

  void stubGetSuccess([List<PlatformUser>? users]) {
    when(() => mockGetUsers(
          userType: any(named: 'userType'),
          status: any(named: 'status'),
          from: any(named: 'from'),
          to: any(named: 'to'),
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
        )).thenAnswer((_) async => Right((
          users: users ?? [_user('u-1'), _user('u-2')],
          total: users?.length ?? 2,
        )));
  }

  void stubGetFailure(String msg) {
    when(() => mockGetUsers(
          userType: any(named: 'userType'),
          status: any(named: 'status'),
          from: any(named: 'from'),
          to: any(named: 'to'),
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
        )).thenAnswer((_) async => Left(ServerFailure(msg)));
  }

  group('PlatformUsersStarted', () {
    blocTest<PlatformUsersBloc, PlatformUsersState>(
      'emits Loading then Loaded on success',
      build: () {
        stubGetSuccess();
        return bloc();
      },
      act: (b) => b.add(const PlatformUsersStarted()),
      expect: () => [isA<PlatformUsersLoading>(), isA<PlatformUsersLoaded>()],
    );

    blocTest<PlatformUsersBloc, PlatformUsersState>(
      'Loaded has correct users and total',
      build: () {
        stubGetSuccess([_user('u-1'), _user('u-2'), _user('u-3')]);
        return bloc();
      },
      act: (b) => b.add(const PlatformUsersStarted()),
      expect: () => [
        isA<PlatformUsersLoading>(),
        predicate<PlatformUsersState>((s) =>
            s is PlatformUsersLoaded && s.total == 3 && s.users.length == 3),
      ],
    );

    blocTest<PlatformUsersBloc, PlatformUsersState>(
      'emits Error on failure',
      build: () {
        stubGetFailure('Failed to load');
        return bloc();
      },
      act: (b) => b.add(const PlatformUsersStarted()),
      expect: () => [
        isA<PlatformUsersLoading>(),
        predicate<PlatformUsersState>(
            (s) => s is PlatformUsersError && s.message == 'Failed to load'),
      ],
    );
  });

  group('PlatformUsersFiltered', () {
    blocTest<PlatformUsersBloc, PlatformUsersState>(
      'filters by userType doctor and passes correct params',
      build: () {
        stubGetSuccess([_user('u-1', type: 'doctor')]);
        return bloc();
      },
      act: (b) => b.add(const PlatformUsersFiltered(userTypeFilter: 'doctor')),
      expect: () => [isA<PlatformUsersLoading>(), isA<PlatformUsersLoaded>()],
      verify: (_) {
        verify(() => mockGetUsers(
              userType: 'doctor',
              status: null,
              from: any(named: 'from'),
              to: any(named: 'to'),
              page: 1,
              pageSize: any(named: 'pageSize'),
            )).called(1);
      },
    );

    blocTest<PlatformUsersBloc, PlatformUsersState>(
      'filters by status suspended',
      build: () {
        stubGetSuccess([_user('u-1', status: 'suspended')]);
        return bloc();
      },
      act: (b) => b.add(const PlatformUsersFiltered(statusFilter: 'suspended')),
      verify: (_) {
        verify(() => mockGetUsers(
              userType: null,
              status: 'suspended',
              from: any(named: 'from'),
              to: any(named: 'to'),
              page: 1,
              pageSize: any(named: 'pageSize'),
            )).called(1);
      },
    );
  });

  group('UserSuspendRequested — suspend flow', () {
    blocTest<PlatformUsersBloc, PlatformUsersState>(
      'emits ActionSuccess then re-fetches list on suspend',
      build: () {
        stubGetSuccess();
        when(() => mockSuspend(any(), reason: any(named: 'reason'), suspendUntil: any(named: 'suspendUntil')))
            .thenAnswer((_) async => const Right(null));
        return bloc();
      },
      act: (b) => b.add(const UserSuspendRequested('u-1', 'Abuse')),
      expect: () => [
        predicate<PlatformUsersState>(
            (s) => s is PlatformUsersActionSuccess && s.message.isNotEmpty),
        isA<PlatformUsersLoading>(),
        isA<PlatformUsersLoaded>(),
      ],
    );

    blocTest<PlatformUsersBloc, PlatformUsersState>(
      'emits ActionError when suspend fails',
      build: () {
        when(() => mockSuspend(any(), reason: any(named: 'reason'), suspendUntil: any(named: 'suspendUntil')))
            .thenAnswer((_) async => Left(ServerFailure('Suspend failed')));
        return bloc();
      },
      act: (b) => b.add(const UserSuspendRequested('u-1', 'reason')),
      expect: () => [
        predicate<PlatformUsersState>(
            (s) => s is PlatformUsersActionError && s.message == 'Suspend failed'),
      ],
    );
  });

  group('UserForceLogoutRequested — force logout flow', () {
    blocTest<PlatformUsersBloc, PlatformUsersState>(
      'emits ActionSuccess only (no re-fetch — token revocation is fire-and-forget)',
      build: () {
        when(() => mockForceLogout(any()))
            .thenAnswer((_) async => const Right(null));
        return bloc();
      },
      act: (b) => b.add(const UserForceLogoutRequested('u-1')),
      expect: () => [
        predicate<PlatformUsersState>(
            (s) => s is PlatformUsersActionSuccess && s.message.contains('force logged out')),
      ],
      verify: (_) {
        verify(() => mockForceLogout('u-1')).called(1);
      },
    );

    blocTest<PlatformUsersBloc, PlatformUsersState>(
      'emits ActionError when force logout fails',
      build: () {
        when(() => mockForceLogout(any()))
            .thenAnswer((_) async => Left(ServerFailure('Logout failed')));
        return bloc();
      },
      act: (b) => b.add(const UserForceLogoutRequested('u-1')),
      expect: () => [
        predicate<PlatformUsersState>(
            (s) => s is PlatformUsersActionError && s.message == 'Logout failed'),
      ],
    );
  });

  group('UserReactivateRequested', () {
    blocTest<PlatformUsersBloc, PlatformUsersState>(
      'emits ActionSuccess and re-fetches after reactivate',
      build: () {
        stubGetSuccess();
        when(() => mockReactivate(any()))
            .thenAnswer((_) async => const Right(null));
        return bloc();
      },
      act: (b) => b.add(const UserReactivateRequested('u-1')),
      expect: () => [
        isA<PlatformUsersActionSuccess>(),
        isA<PlatformUsersLoading>(),
        isA<PlatformUsersLoaded>(),
      ],
    );
  });

  group('UserDeleteRequested', () {
    blocTest<PlatformUsersBloc, PlatformUsersState>(
      'emits ActionSuccess and re-fetches after soft delete',
      build: () {
        stubGetSuccess();
        when(() => mockDelete(any()))
            .thenAnswer((_) async => const Right(null));
        return bloc();
      },
      act: (b) => b.add(const UserDeleteRequested('u-1')),
      expect: () => [
        isA<PlatformUsersActionSuccess>(),
        isA<PlatformUsersLoading>(),
        isA<PlatformUsersLoaded>(),
      ],
      verify: (_) {
        verify(() => mockDelete('u-1')).called(1);
      },
    );
  });
}
