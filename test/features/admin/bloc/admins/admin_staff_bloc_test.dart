import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:medimind_portal/core/error/failures.dart';
import 'package:medimind_portal/features/admin/domain/entities/admin_staff.dart';
import 'package:medimind_portal/features/admin/domain/usecases/get_admins_usecase.dart';
import 'package:medimind_portal/features/admin/domain/usecases/add_admin_usecase.dart';
import 'package:medimind_portal/features/admin/domain/usecases/deactivate_admin_usecase.dart';
import 'package:medimind_portal/features/admin/presentation/bloc/admins/admin_staff_bloc.dart';

class MockGetAdminsUseCase extends Mock implements GetAdminsUseCase {}
class MockAddAdminUseCase extends Mock implements AddAdminUseCase {}
class MockDeactivateAdminUseCase extends Mock implements DeactivateAdminUseCase {}

AdminStaff _makeStaff({
  required String id,
  AdminStatus status = AdminStatus.active,
  AdminRole role = AdminRole.admin,
}) =>
    AdminStaff(
      id: id,
      fullName: 'Admin $id',
      email: '$id@example.com',
      role: role,
      status: status,
      centerId: 'center1',
    );

AdminStaffBloc _makeBloc({
  required GetAdminsUseCase getAdmins,
  required AddAdminUseCase addAdmin,
  required DeactivateAdminUseCase deactivate,
}) =>
    AdminStaffBloc(
      getAdmins: getAdmins,
      addAdmin: addAdmin,
      deactivate: deactivate,
    );

void main() {
  late MockGetAdminsUseCase mockGetAdmins;
  late MockAddAdminUseCase mockAddAdmin;
  late MockDeactivateAdminUseCase mockDeactivate;

  const centerId = 'center1';
  final admin1 = _makeStaff(id: 'admin-1');
  final admin2 = _makeStaff(id: 'admin-2', role: AdminRole.receptionist);

  setUp(() {
    mockGetAdmins = MockGetAdminsUseCase();
    mockAddAdmin = MockAddAdminUseCase();
    mockDeactivate = MockDeactivateAdminUseCase();
  });

  AdminStaffBloc bloc() => _makeBloc(
        getAdmins: mockGetAdmins,
        addAdmin: mockAddAdmin,
        deactivate: mockDeactivate,
      );

  group('AdminStaffStarted', () {
    blocTest<AdminStaffBloc, AdminStaffState>(
      'emits Loading then Loaded with staff list',
      build: () {
        when(() => mockGetAdmins(centerId))
            .thenAnswer((_) async => Right([admin1, admin2]));
        return bloc();
      },
      act: (b) => b.add(const AdminStaffStarted(centerId)),
      expect: () => [
        isA<AdminStaffLoading>(),
        isA<AdminStaffLoaded>(),
      ],
      verify: (b) {
        final loaded = b.state as AdminStaffLoaded;
        expect(loaded.staff.length, 2);
      },
    );

    blocTest<AdminStaffBloc, AdminStaffState>(
      'emits Error on failure',
      build: () {
        when(() => mockGetAdmins(centerId))
            .thenAnswer((_) async => const Left(NetworkFailure()));
        return bloc();
      },
      act: (b) => b.add(const AdminStaffStarted(centerId)),
      expect: () => [
        isA<AdminStaffLoading>(),
        isA<AdminStaffError>(),
      ],
    );
  });

  group('AdminDeactivatedFromStaff — cannot-remove-self constraint', () {
    // Self-check uses state.currentUserId; seed: sets it without needing _centerId
    // because the bloc returns early before any API call.
    blocTest<AdminStaffBloc, AdminStaffState>(
      'prevents deactivating own account without calling API',
      build: () => bloc(),
      seed: () => AdminStaffLoaded(staff: [admin1, admin2], currentUserId: 'admin-1'),
      act: (b) => b.add(const AdminDeactivatedFromStaff('admin-1')),
      expect: () => [isA<AdminStaffError>()],
      verify: (b) {
        verifyNever(() => mockDeactivate(any(), any()));
        final err = b.state as AdminStaffError;
        expect(err.message, contains('Cannot deactivate'));
      },
    );

    blocTest<AdminStaffBloc, AdminStaffState>(
      'deactivates another admin successfully',
      build: () {
        when(() => mockGetAdmins(centerId))
            .thenAnswer((_) async => Right([admin1, admin2]));
        when(() => mockDeactivate(centerId, 'admin-2'))
            .thenAnswer((_) async => const Right(null));
        return bloc();
      },
      act: (b) async {
        b.add(const AdminStaffStarted(centerId));
        await Future<void>.delayed(Duration.zero);
        b.add(const AdminDeactivatedFromStaff('admin-2'));
      },
      expect: () => [
        isA<AdminStaffLoading>(),
        isA<AdminStaffLoaded>(),
        isA<AdminStaffActionInProgress>(),
        isA<AdminStaffActionSuccess>(),
        isA<AdminStaffLoaded>(),
      ],
      verify: (_) => verify(() => mockDeactivate(centerId, 'admin-2')).called(1),
    );

    blocTest<AdminStaffBloc, AdminStaffState>(
      'emits Error when deactivation API fails',
      build: () {
        when(() => mockGetAdmins(centerId))
            .thenAnswer((_) async => Right([admin1, admin2]));
        when(() => mockDeactivate(centerId, 'admin-2'))
            .thenAnswer((_) async => const Left(ForbiddenFailure('No permission')));
        return bloc();
      },
      act: (b) async {
        b.add(const AdminStaffStarted(centerId));
        await Future<void>.delayed(Duration.zero);
        b.add(const AdminDeactivatedFromStaff('admin-2'));
      },
      expect: () => [
        isA<AdminStaffLoading>(),
        isA<AdminStaffLoaded>(),
        isA<AdminStaffActionInProgress>(),
        isA<AdminStaffError>(),
      ],
    );
  });

  group('AdminAddedToStaff', () {
    blocTest<AdminStaffBloc, AdminStaffState>(
      'adds admin and emits success',
      build: () {
        when(() => mockGetAdmins(centerId))
            .thenAnswer((_) async => Right([admin1, admin2]));
        when(() => mockAddAdmin(
              centerId: centerId,
              name: 'New Admin',
              email: 'new@example.com',
              phone: '+251911000000',
              role: AdminRole.receptionist,
            )).thenAnswer((_) async => const Right(null));
        return bloc();
      },
      act: (b) async {
        b.add(const AdminStaffStarted(centerId));
        await Future<void>.delayed(Duration.zero);
        b.add(const AdminAddedToStaff(
          name: 'New Admin',
          email: 'new@example.com',
          phone: '+251911000000',
          role: AdminRole.receptionist,
        ));
      },
      expect: () => [
        isA<AdminStaffLoading>(),
        isA<AdminStaffLoaded>(),
        isA<AdminStaffActionInProgress>(),
        isA<AdminStaffActionSuccess>(),
        isA<AdminStaffLoaded>(),
      ],
    );
  });
}
