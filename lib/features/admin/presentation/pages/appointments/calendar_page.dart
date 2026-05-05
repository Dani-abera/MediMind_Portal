import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart' hide Appointment;
import '../../../../../core/di/service_locator.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/shell/page_header.dart';
import '../../../domain/entities/admin_appointment.dart';
import '../../bloc/all_appointments/all_appointments_bloc.dart';
import '../../widgets/admin_appointment_detail_drawer.dart';

class AdminCalendarPage extends StatelessWidget {
  const AdminCalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AllAppointmentsBloc>()..add(const AllApptsStarted()),
      child: const _CalendarView(),
    );
  }
}

class _CalendarView extends StatefulWidget {
  const _CalendarView();

  @override
  State<_CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<_CalendarView> {
  CalendarView _view = CalendarView.timelineDay;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PageHeader(
          title: 'Appointments Calendar',
          subtitle: 'Resource view by doctor',
          actions: [
            SegmentedButton<CalendarView>(
              segments: const [
                ButtonSegment(value: CalendarView.day, label: Text('Day')),
                ButtonSegment(value: CalendarView.week, label: Text('Week')),
                ButtonSegment(value: CalendarView.timelineDay, label: Text('Timeline')),
              ],
              selected: {_view},
              onSelectionChanged: (v) => setState(() => _view = v.first),
            ),
            const SizedBox(width: AppSpacing.sm),
            IconButton(
              icon: const Icon(Icons.refresh, size: 18),
              tooltip: 'Refresh',
              onPressed: () => context.read<AllAppointmentsBloc>().add(const AllApptsFiltered()),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        Expanded(
          child: BlocBuilder<AllAppointmentsBloc, AllAppointmentsState>(
            builder: (ctx, state) {
              if (state is AllApptsLoading || state is AllApptsInitial) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is AllApptsError) {
                return Center(child: Text(state.message, style: AppTypography.body));
              }
              if (state is AllApptsLoaded) {
                return _AdminCalendar(appointments: state.appointments, view: _view);
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}

class _AdminCalendar extends StatelessWidget {
  final List<AdminAppointment> appointments;
  final CalendarView view;
  const _AdminCalendar({required this.appointments, required this.view});

  @override
  Widget build(BuildContext context) {
    final dataSource = _AdminAppointmentDataSource(appointments);

    return SfCalendar(
      view: view,
      dataSource: dataSource,
      resourceViewSettings: const ResourceViewSettings(
        visibleResourceCount: 4,
      ),
      timeSlotViewSettings: const TimeSlotViewSettings(
        startHour: 7,
        endHour: 20,
        timeInterval: Duration(minutes: 30),
        timeIntervalHeight: 64,
      ),
      appointmentBuilder: (ctx, details) {
        final appt = details.appointments.first as AdminAppointment;
        return _AppointmentTile(appt: appt, view: view);
      },
      onTap: (details) {
        if (details.appointments?.isNotEmpty == true) {
          final appt = details.appointments!.first as AdminAppointment;
          AdminAppointmentDetailDrawer.show(context, appointmentId: appt.id);
        }
      },
    );
  }
}

class _AppointmentTile extends StatelessWidget {
  final AdminAppointment appt;
  final CalendarView view;
  const _AppointmentTile({required this.appt, required this.view});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(appt.status);
    return Container(
      margin: const EdgeInsets.all(2),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(200),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            appt.patientName,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
          if (view != CalendarView.month)
            Text(
              appt.reason,
              style: const TextStyle(color: Colors.white70, fontSize: 10),
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  Color _statusColor(AppointmentStatus s) => switch (s) {
        AppointmentStatus.pending => AppColors.warning,
        AppointmentStatus.confirmed => AppColors.info,
        AppointmentStatus.inProgress => AppColors.primary,
        AppointmentStatus.completed => AppColors.success,
        AppointmentStatus.cancelled => AppColors.danger,
        AppointmentStatus.noShow => AppColors.neutral400,
      };
}

class _AdminAppointmentDataSource extends CalendarDataSource {
  final List<AdminAppointment> _appts;

  _AdminAppointmentDataSource(this._appts) {
    appointments = _appts;

    resources = _appts.fold<Map<String, CalendarResource>>({}, (map, a) {
      map.putIfAbsent(
        a.doctorId,
        () => CalendarResource(
          displayName: a.doctorName,
          id: a.doctorId,
          color: _doctorColor(a.doctorId),
        ),
      );
      return map;
    }).values.toList();
  }

  @override
  DateTime getStartTime(int index) => _appts[index].dateTime;

  @override
  DateTime getEndTime(int index) =>
      _appts[index].dateTime.add(Duration(minutes: _appts[index].durationMinutes));

  @override
  String getSubject(int index) => _appts[index].patientName;

  @override
  Color getColor(int index) => _statusColor(_appts[index].status);

  @override
  List<Object>? getResourceIds(int index) => [_appts[index].doctorId];

  Color _statusColor(AppointmentStatus s) => switch (s) {
        AppointmentStatus.pending => AppColors.warning,
        AppointmentStatus.confirmed => AppColors.info,
        AppointmentStatus.inProgress => AppColors.primary,
        AppointmentStatus.completed => AppColors.success,
        AppointmentStatus.cancelled => AppColors.danger,
        AppointmentStatus.noShow => AppColors.neutral400,
      };

  Color _doctorColor(String id) {
    const colors = [
      AppColors.primary, AppColors.info, AppColors.accent,
      AppColors.warning, AppColors.success,
    ];
    return colors[id.hashCode.abs() % colors.length];
  }
}
