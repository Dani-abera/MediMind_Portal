import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/appointment_repository.dart';
import '../repositories/prescription_repository.dart';
import '../entities/appointment.dart';
import '../entities/prescription.dart';

class DashboardData {
  final Map<String, dynamic> todaySummary;
  final List<Appointment> todayAppointments;
  final List<Prescription> recentPrescriptions;

  const DashboardData({
    required this.todaySummary,
    required this.todayAppointments,
    required this.recentPrescriptions,
  });
}

class GetDashboardDataUseCase {
  final AppointmentRepository _appointments;
  final PrescriptionRepository _prescriptions;

  GetDashboardDataUseCase({
    required AppointmentRepository appointments,
    required PrescriptionRepository prescriptions,
  })  : _appointments = appointments,
        _prescriptions = prescriptions;

  Future<Either<Failure, DashboardData>> call() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final results = await Future.wait([
      _appointments.getAppointments(from: startOfDay, to: endOfDay, pageSize: 50),
      _prescriptions.getPrescriptions(pageSize: 10),
    ]);

    final apptResult = results[0] as Either<Failure, List<Appointment>>;
    final rxResult = results[1] as Either<Failure, List<Prescription>>;

    if (apptResult.isLeft()) return Left(apptResult.fold((f) => f, (_) => const UnknownFailure()));
    if (rxResult.isLeft()) return Left(rxResult.fold((f) => f, (_) => const UnknownFailure()));

    final appointments = apptResult.getOrElse(() => []);
    final prescriptions = rxResult.getOrElse(() => []);

    final completed = appointments.where((a) => a.status == AppointmentStatus.completed).length;
    final inProgress = appointments.where((a) => a.status == AppointmentStatus.inProgress).length;

    return Right(DashboardData(
      todaySummary: {
        'total': appointments.length,
        'completed': completed,
        'inProgress': inProgress,
        'pending': appointments.where((a) => a.status == AppointmentStatus.pending || a.status == AppointmentStatus.confirmed).length,
      },
      todayAppointments: appointments,
      recentPrescriptions: prescriptions,
    ));
  }
}
