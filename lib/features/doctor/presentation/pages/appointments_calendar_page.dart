import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart' hide Appointment;
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/feedback/app_loading.dart';
import '../../../../core/widgets/shell/page_header.dart';
import '../../domain/entities/appointment.dart';
import '../bloc/appointment_list/appointment_list_bloc.dart';
import '../widgets/appointment_detail_drawer.dart';

class AppointmentsCalendarPage extends StatelessWidget {
  const AppointmentsCalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<AppointmentListBloc>()..add(const AppointmentListStarted()),
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
  CalendarView _calendarView = CalendarView.week;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PageHeader(
          title: 'Appointments — Calendar',
          actions: [
            SegmentedButton<CalendarView>(
              segments: const [
                ButtonSegment(
                    value: CalendarView.month, label: Text('Month')),
                ButtonSegment(
                    value: CalendarView.week, label: Text('Week')),
                ButtonSegment(value: CalendarView.day, label: Text('Day')),
              ],
              selected: {_calendarView},
              onSelectionChanged: (v) =>
                  setState(() => _calendarView = v.first),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.refresh, size: 18),
              onPressed: () => context
                  .read<AppointmentListBloc>()
                  .add(const AppointmentListStarted()),
            ),
          ],
        ),
        Expanded(
          child: BlocBuilder<AppointmentListBloc, AppointmentListState>(
            builder: (ctx, state) {
              if (state is AppointmentListLoading ||
                  state is AppointmentListInitial) {
                return const Center(child: AppLoadingSpinner());
              }
              if (state is AppointmentListError) {
                return AppErrorState(message: state.message);
              }
              final appointments = state is AppointmentListLoaded
                  ? state.appointments
                  : <Appointment>[];
              return SfCalendar(
                view: _calendarView,
                firstDayOfWeek: 1,
                showNavigationArrow: true,
                showDatePickerButton: true,
                headerHeight: 48,
                headerStyle: const CalendarHeaderStyle(
                  textAlign: TextAlign.center,
                ),
                todayHighlightColor: AppColors.primary,
                selectionDecoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary, width: 2),
                  borderRadius: BorderRadius.circular(4),
                ),
                dataSource: _AppointmentDataSource(appointments),
                onTap: (details) {
                  if (details.appointments != null &&
                      details.appointments!.isNotEmpty) {
                    final appt =
                        details.appointments!.first as Appointment;
                    AppointmentDetailDrawer.show(context, appt.id);
                  }
                },
                appointmentTextStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AppointmentDataSource extends CalendarDataSource {
  final List<Appointment> _appointments;

  _AppointmentDataSource(this._appointments) {
    appointments = _appointments;
  }

  @override
  DateTime getStartTime(int index) => _appointments[index].dateTime;

  @override
  DateTime getEndTime(int index) =>
      _appointments[index].dateTime.add(const Duration(minutes: 30));

  @override
  String getSubject(int index) => _appointments[index].patientName;

  @override
  Color getColor(int index) {
    return switch (_appointments[index].status) {
      AppointmentStatus.confirmed => AppColors.info,
      AppointmentStatus.completed => AppColors.success,
      AppointmentStatus.cancelled => AppColors.danger,
      AppointmentStatus.inProgress => AppColors.warning,
      _ => AppColors.primary,
    };
  }
}
