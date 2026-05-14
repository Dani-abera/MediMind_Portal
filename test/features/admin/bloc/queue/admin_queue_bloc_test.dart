import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:medimind_portal/core/error/failures.dart';
import 'package:medimind_portal/core/network/realtime_service.dart';
import 'package:medimind_portal/core/network/realtime_event.dart';
import 'package:medimind_portal/features/admin/domain/entities/queue_item.dart';
import 'package:medimind_portal/features/admin/domain/usecases/get_admin_queue_usecase.dart';
import 'package:medimind_portal/features/admin/domain/usecases/call_next_usecase.dart';
import 'package:medimind_portal/features/admin/domain/usecases/mark_arrived_usecase.dart';
import 'package:medimind_portal/features/admin/domain/usecases/mark_complete_usecase.dart';
import 'package:medimind_portal/features/admin/domain/usecases/mark_no_show_usecase.dart';
import 'package:medimind_portal/features/admin/domain/usecases/skip_queue_usecase.dart';
import 'package:medimind_portal/features/admin/domain/usecases/insert_emergency_usecase.dart';
import 'package:medimind_portal/features/admin/presentation/bloc/queue/admin_queue_bloc.dart';

class MockGetAdminQueueUseCase extends Mock implements GetAdminQueueUseCase {}
class MockCallNextUseCase extends Mock implements CallNextUseCase {}
class MockMarkArrivedUseCase extends Mock implements MarkArrivedUseCase {}
class MockMarkCompleteUseCase extends Mock implements MarkCompleteUseCase {}
class MockMarkNoShowUseCase extends Mock implements MarkNoShowUseCase {}
class MockSkipQueueUseCase extends Mock implements SkipQueueUseCase {}
class MockInsertEmergencyUseCase extends Mock implements InsertEmergencyUseCase {}
class MockRealtimeService extends Mock implements RealtimeService {
  @override
  Stream<RealtimeEvent> get events => const Stream.empty();
  @override
  bool get isConnected => false;
  @override
  Future<void> joinCenterGroup(String centerId) async {}
}

QueueItem _makeItem({
  required String id,
  required int queueNumber,
  QueueStatus status = QueueStatus.waiting,
}) =>
    QueueItem(
      id: id,
      queueNumber: queueNumber,
      patientId: 'patient-$id',
      patientName: 'Patient $id',
      appointmentId: 'appt-$id',
      doctorId: 'doc1',
      doctorName: 'Dr. Smith',
      status: status,
      reason: 'Checkup',
    );

AdminQueueBloc _makeBloc({
  required GetAdminQueueUseCase getQueue,
  required CallNextUseCase callNext,
  required MarkArrivedUseCase markArrived,
  required MarkCompleteUseCase markComplete,
  required MarkNoShowUseCase markNoShow,
  required SkipQueueUseCase skip,
  required InsertEmergencyUseCase insertEmergency,
  RealtimeService? realtime,
}) =>
    AdminQueueBloc(
      getQueue: getQueue,
      callNext: callNext,
      markArrived: markArrived,
      markComplete: markComplete,
      markNoShow: markNoShow,
      skip: skip,
      insertEmergency: insertEmergency,
      realtime: realtime ?? MockRealtimeService(),
    );

void main() {
  late MockGetAdminQueueUseCase mockGetQueue;
  late MockCallNextUseCase mockCallNext;
  late MockMarkArrivedUseCase mockMarkArrived;
  late MockMarkCompleteUseCase mockMarkComplete;
  late MockMarkNoShowUseCase mockMarkNoShow;
  late MockSkipQueueUseCase mockSkip;
  late MockInsertEmergencyUseCase mockInsertEmergency;

  setUp(() {
    mockGetQueue = MockGetAdminQueueUseCase();
    mockCallNext = MockCallNextUseCase();
    mockMarkArrived = MockMarkArrivedUseCase();
    mockMarkComplete = MockMarkCompleteUseCase();
    mockMarkNoShow = MockMarkNoShowUseCase();
    mockSkip = MockSkipQueueUseCase();
    mockInsertEmergency = MockInsertEmergencyUseCase();
  });

  AdminQueueBloc bloc() => _makeBloc(
        getQueue: mockGetQueue,
        callNext: mockCallNext,
        markArrived: mockMarkArrived,
        markComplete: mockMarkComplete,
        markNoShow: mockMarkNoShow,
        skip: mockSkip,
        insertEmergency: mockInsertEmergency,
      );

  const centerId = 'center-1';
  final waitingItem = _makeItem(id: '1', queueNumber: 1);
  final inProgressItem = _makeItem(id: '2', queueNumber: 2, status: QueueStatus.inProgress);
  final doneItem = _makeItem(id: '2', queueNumber: 2, status: QueueStatus.done);

  group('AdminQueueOpened', () {
    blocTest<AdminQueueBloc, AdminQueueState>(
      'emits Loading then Loaded on success',
      build: () {
        when(() => mockGetQueue(centerId))
            .thenAnswer((_) async => Right([waitingItem]));
        return bloc();
      },
      act: (b) => b.add(const AdminQueueOpened(centerId)),
      expect: () => [
        isA<AdminQueueLoading>(),
        isA<AdminQueueLoaded>(),
      ],
    );

    blocTest<AdminQueueBloc, AdminQueueState>(
      'emits Error on failure',
      build: () {
        when(() => mockGetQueue(centerId))
            .thenAnswer((_) async => const Left(NetworkFailure()));
        return bloc();
      },
      act: (b) => b.add(const AdminQueueOpened(centerId)),
      expect: () => [
        isA<AdminQueueLoading>(),
        isA<AdminQueueError>(),
      ],
    );

    blocTest<AdminQueueBloc, AdminQueueState>(
      'loaded state sorts items and computes stats correctly',
      build: () {
        when(() => mockGetQueue(centerId)).thenAnswer((_) async => Right([
              _makeItem(id: '3', queueNumber: 3, status: QueueStatus.done),
              waitingItem,
              inProgressItem,
            ]));
        return bloc();
      },
      act: (b) => b.add(const AdminQueueOpened(centerId)),
      verify: (b) {
        final state = b.state as AdminQueueLoaded;
        expect(state.items.map((i) => i.queueNumber).toList(), [1, 2, 3]);
        expect(state.nowServing?.id, '2');
        expect(state.stats.totalServed, 1);
      },
    );
  });

  group('AdminQueueNextCalled', () {
    // Sends Opened first to initialise _centerId, then triggers NextCalled
    blocTest<AdminQueueBloc, AdminQueueState>(
      'calls next and refreshes queue',
      build: () {
        when(() => mockGetQueue(centerId))
            .thenAnswer((_) async => Right([waitingItem]));
        when(() => mockCallNext())
            .thenAnswer((_) async => Right(inProgressItem));
        return bloc();
      },
      act: (b) async {
        b.add(const AdminQueueOpened(centerId));
        await Future<void>.delayed(Duration.zero);
        b.add(const AdminQueueNextCalled());
      },
      expect: () => [
        isA<AdminQueueLoading>(),
        isA<AdminQueueLoaded>(),
        isA<AdminQueueActionInProgress>(),
        isA<AdminQueueLoaded>(),
      ],
      verify: (_) => verify(() => mockCallNext()).called(1),
    );

    blocTest<AdminQueueBloc, AdminQueueState>(
      'emits ActionError when callNext fails',
      build: () {
        when(() => mockGetQueue(centerId))
            .thenAnswer((_) async => Right([waitingItem]));
        when(() => mockCallNext())
            .thenAnswer((_) async => const Left(ServerFailure('Queue empty')));
        return bloc();
      },
      act: (b) async {
        b.add(const AdminQueueOpened(centerId));
        await Future<void>.delayed(Duration.zero);
        b.add(const AdminQueueNextCalled());
      },
      expect: () => [
        isA<AdminQueueLoading>(),
        isA<AdminQueueLoaded>(),
        isA<AdminQueueActionInProgress>(),
        isA<AdminQueueActionError>(),
      ],
    );
  });

  group('AdminQueueMarkComplete', () {
    blocTest<AdminQueueBloc, AdminQueueState>(
      'marks complete and refreshes',
      build: () {
        when(() => mockGetQueue(centerId))
            .thenAnswer((_) async => Right([waitingItem]));
        when(() => mockMarkComplete('2'))
            .thenAnswer((_) async => const Right(null));
        return bloc();
      },
      act: (b) async {
        b.add(const AdminQueueOpened(centerId));
        await Future<void>.delayed(Duration.zero);
        // Update stub for the post-complete refresh
        when(() => mockGetQueue(centerId))
            .thenAnswer((_) async => Right([doneItem]));
        b.add(const AdminQueueMarkComplete('2'));
      },
      expect: () => [
        isA<AdminQueueLoading>(),
        isA<AdminQueueLoaded>(),
        isA<AdminQueueActionInProgress>(),
        isA<AdminQueueLoaded>(),
      ],
      verify: (_) => verify(() => mockMarkComplete('2')).called(1),
    );
  });

  group('AdminQueueSignalRUpdate', () {
    blocTest<AdminQueueBloc, AdminQueueState>(
      'triggers refresh when in loaded state',
      build: () {
        when(() => mockGetQueue(centerId))
            .thenAnswer((_) async => Right([waitingItem]));
        return bloc();
      },
      act: (b) async {
        b.add(const AdminQueueOpened(centerId));
        await Future<void>.delayed(Duration.zero);
        b.add(const AdminQueueSignalRUpdate({'type': 'queue_update'}));
      },
      expect: () => [
        isA<AdminQueueLoading>(),
        isA<AdminQueueLoaded>(),
        isA<AdminQueueLoaded>(),
      ],
    );

    blocTest<AdminQueueBloc, AdminQueueState>(
      'does nothing when not in loaded state',
      build: () => bloc(),
      act: (b) => b.add(const AdminQueueSignalRUpdate({'type': 'queue_update'})),
      expect: () => [],
    );
  });

  group('EmergencyInserted', () {
    blocTest<AdminQueueBloc, AdminQueueState>(
      'inserts emergency, refreshes, and emits success message',
      build: () {
        final emergency = _makeItem(id: 'e1', queueNumber: 1);
        when(() => mockGetQueue(centerId))
            .thenAnswer((_) async => Right([waitingItem]));
        when(() => mockInsertEmergency('appt-e1'))
            .thenAnswer((_) async => Right(emergency));
        return bloc();
      },
      act: (b) async {
        b.add(const AdminQueueOpened(centerId));
        await Future<void>.delayed(Duration.zero);
        // Update stub for post-insert refresh
        final emergency = _makeItem(id: 'e1', queueNumber: 1);
        when(() => mockGetQueue(centerId))
            .thenAnswer((_) async => Right([emergency, waitingItem]));
        b.add(const AdminQueueEmergencyInserted('appt-e1'));
      },
      expect: () => [
        isA<AdminQueueLoading>(),
        isA<AdminQueueLoaded>(),
        isA<AdminQueueActionInProgress>(),
        isA<AdminQueueLoaded>(),
        isA<AdminQueueActionSuccess>(),
      ],
      verify: (b) {
        final successState = b.state as AdminQueueActionSuccess;
        expect(successState.message, contains('Emergency'));
      },
    );
  });
}
