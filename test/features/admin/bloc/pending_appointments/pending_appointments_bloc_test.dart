import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:medimind_portal/core/error/failures.dart';
import 'package:medimind_portal/features/admin/domain/entities/admin_appointment.dart';
import 'package:medimind_portal/features/admin/domain/usecases/get_pending_appointments_usecase.dart';
import 'package:medimind_portal/features/admin/domain/usecases/approve_appointment_usecase.dart';
import 'package:medimind_portal/features/admin/domain/usecases/reject_appointment_usecase.dart';
import 'package:medimind_portal/features/admin/domain/usecases/bulk_approve_usecase.dart';
import 'package:medimind_portal/features/admin/presentation/bloc/pending_appointments/pending_appointments_bloc.dart';

class MockGetPendingAppointmentsUseCase extends Mock
    implements GetPendingAppointmentsUseCase {}
class MockApproveAppointmentUseCase extends Mock implements ApproveAppointmentUseCase {}
class MockRejectAppointmentUseCase extends Mock implements RejectAppointmentUseCase {}
class MockBulkApproveUseCase extends Mock implements BulkApproveUseCase {}

AdminAppointment _makeAppt(String id) => AdminAppointment(
      id: id,
      patientId: 'p-$id',
      patientName: 'Patient $id',
      doctorId: 'doc1',
      doctorName: 'Dr. Smith',
      centerId: 'center1',
      dateTime: DateTime(2026, 5, 10, 10, 0),
      type: AppointmentType.inPerson,
      status: AppointmentStatus.pending,
      reason: 'Checkup',
      bookedAt: DateTime(2026, 5, 9),
    );

PendingAppointmentsBloc _makeBloc({
  required GetPendingAppointmentsUseCase getPending,
  required ApproveAppointmentUseCase approve,
  required RejectAppointmentUseCase reject,
  required BulkApproveUseCase bulkApprove,
}) =>
    PendingAppointmentsBloc(
      getPending: getPending,
      approve: approve,
      reject: reject,
      bulkApprove: bulkApprove,
    );

void main() {
  late MockGetPendingAppointmentsUseCase mockGetPending;
  late MockApproveAppointmentUseCase mockApprove;
  late MockRejectAppointmentUseCase mockReject;
  late MockBulkApproveUseCase mockBulkApprove;

  final appt1 = _makeAppt('appt-1');
  final appt2 = _makeAppt('appt-2');
  final appt3 = _makeAppt('appt-3');
  final allPending = [appt1, appt2, appt3];

  setUp(() {
    mockGetPending = MockGetPendingAppointmentsUseCase();
    mockApprove = MockApproveAppointmentUseCase();
    mockReject = MockRejectAppointmentUseCase();
    mockBulkApprove = MockBulkApproveUseCase();
  });

  PendingAppointmentsBloc bloc() => _makeBloc(
        getPending: mockGetPending,
        approve: mockApprove,
        reject: mockReject,
        bulkApprove: mockBulkApprove,
      );

  group('PendingApptsStarted', () {
    blocTest<PendingAppointmentsBloc, PendingAppointmentsState>(
      'emits Loading then Loaded with appointments',
      build: () {
        when(() => mockGetPending()).thenAnswer((_) async => Right(allPending));
        return bloc();
      },
      act: (b) => b.add(const PendingApptsStarted()),
      expect: () => [
        isA<PendingApptsLoading>(),
        isA<PendingApptsLoaded>(),
      ],
      verify: (b) {
        final loaded = b.state as PendingApptsLoaded;
        expect(loaded.appointments.length, 3);
      },
    );

    blocTest<PendingAppointmentsBloc, PendingAppointmentsState>(
      'emits Error on network failure',
      build: () {
        when(() => mockGetPending())
            .thenAnswer((_) async => const Left(NetworkFailure()));
        return bloc();
      },
      act: (b) => b.add(const PendingApptsStarted()),
      expect: () => [
        isA<PendingApptsLoading>(),
        isA<PendingApptsError>(),
      ],
    );
  });

  group('PendingApptApproved', () {
    blocTest<PendingAppointmentsBloc, PendingAppointmentsState>(
      'approves single appointment and refreshes list',
      build: () {
        when(() => mockApprove('appt-1'))
            .thenAnswer((_) async => const Right(null));
        when(() => mockGetPending())
            .thenAnswer((_) async => Right([appt2, appt3]));
        return bloc();
      },
      act: (b) => b.add(PendingApptApproved('appt-1')),
      expect: () => [
        isA<PendingApptsActionInProgress>(),
        isA<PendingApptsActionSuccess>(),
        isA<PendingApptsLoaded>(),
      ],
      verify: (b) {
        final loaded = b.state as PendingApptsLoaded;
        expect(loaded.appointments.length, 2);
      },
    );
  });

  group('PendingBulkApproved', () {
    blocTest<PendingAppointmentsBloc, PendingAppointmentsState>(
      'bulk-approves selected appointments with a single API call',
      build: () {
        when(() => mockBulkApprove(['appt-1', 'appt-2']))
            .thenAnswer((_) async => const Right(null));
        when(() => mockGetPending())
            .thenAnswer((_) async => Right([appt3]));
        return bloc();
      },
      seed: () => PendingApptsLoaded(
        appointments: allPending,
        selectedIds: {'appt-1', 'appt-2'},
      ),
      act: (b) => b.add(const PendingBulkApproved()),
      expect: () => [
        isA<PendingApptsActionInProgress>(),
        isA<PendingApptsActionSuccess>(),
        isA<PendingApptsLoaded>(),
      ],
      verify: (_) {
        verify(() => mockBulkApprove(['appt-1', 'appt-2'])).called(1);
        verifyNever(() => mockApprove(any()));
      },
    );

    blocTest<PendingAppointmentsBloc, PendingAppointmentsState>(
      'does nothing when no appointments selected',
      build: () => bloc(),
      seed: () => PendingApptsLoaded(
        appointments: allPending,
        selectedIds: const {},
      ),
      act: (b) => b.add(const PendingBulkApproved()),
      expect: () => [],
      verify: (_) => verifyNever(() => mockBulkApprove(any())),
    );

    blocTest<PendingAppointmentsBloc, PendingAppointmentsState>(
      'emits Error when bulk approve API fails',
      build: () {
        when(() => mockBulkApprove(any()))
            .thenAnswer((_) async => const Left(ServerFailure('Server error')));
        return bloc();
      },
      seed: () => PendingApptsLoaded(
        appointments: allPending,
        selectedIds: {'appt-1', 'appt-2'},
      ),
      act: (b) => b.add(const PendingBulkApproved()),
      expect: () => [
        isA<PendingApptsActionInProgress>(),
        isA<PendingApptsError>(),
      ],
    );
  });

  group('PendingSelectionChanged', () {
    blocTest<PendingAppointmentsBloc, PendingAppointmentsState>(
      'updates selected IDs without fetching',
      build: () => bloc(),
      seed: () => PendingApptsLoaded(
        appointments: allPending,
        selectedIds: const {},
      ),
      act: (b) => b.add(PendingSelectionChanged(['appt-1', 'appt-3'])),
      expect: () => [
        isA<PendingApptsLoaded>(),
      ],
      verify: (b) {
        final loaded = b.state as PendingApptsLoaded;
        expect(loaded.selectedIds, {'appt-1', 'appt-3'});
      },
    );
  });
}
