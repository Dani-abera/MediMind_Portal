import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/network/user_context.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/cards/kpi_card.dart';
import '../../../../core/widgets/charts/bar_chart_card.dart';
import '../../../../core/widgets/charts/line_chart_card.dart';
import '../../../../core/widgets/data_table/app_data_table.dart';
import '../../../../core/widgets/shell/page_header.dart';
import '../domain/entities/analytics_data.dart';
import '../domain/entities/doctor_at_center.dart';
import '../presentation/bloc/doctors_roster/doctors_roster_bloc.dart';
import '../presentation/bloc/per_doctor/per_doctor_bloc.dart';

class PerDoctorAnalyticsPage extends StatelessWidget {
  const PerDoctorAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<DoctorsRosterBloc>()
            ..add(DoctorsRosterStarted(UserContext().centerId ?? '')),
        ),
        BlocProvider(create: (_) => sl<PerDoctorBloc>()),
      ],
      child: const _PerDoctorView(),
    );
  }
}

class _PerDoctorView extends StatefulWidget {
  const _PerDoctorView();
  @override
  State<_PerDoctorView> createState() => _PerDoctorViewState();
}

class _PerDoctorViewState extends State<_PerDoctorView> {
  String? _selectedDoctorId;
  DateRangePreset _preset = DateRangePreset.last30;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PageHeader(
          title: 'Per-Doctor Analytics',
          subtitle: 'Individual doctor performance',
        ),
        // Doctor selector
        BlocBuilder<DoctorsRosterBloc, DoctorsRosterState>(
          builder: (ctx, rosterState) {
            final doctors = rosterState is DoctorsRosterLoaded ? rosterState.doctors : <DoctorAtCenter>[];
            return _DoctorSelectorBar(
              doctors: doctors,
              selectedId: _selectedDoctorId,
              preset: _preset,
              onDoctorChanged: (id) {
                setState(() => _selectedDoctorId = id);
                if (id != null) {
                  context.read<PerDoctorBloc>().add(PerDoctorStarted(
                    centerId: UserContext().centerId ?? '',
                    doctorId: id,
                  ));
                }
              },
              onPresetChanged: (p) {
                setState(() => _preset = p);
                if (_selectedDoctorId != null) {
                  context.read<PerDoctorBloc>().add(PerDoctorDateRangeChanged(p));
                }
              },
            );
          },
        ),
        Expanded(
          child: BlocBuilder<PerDoctorBloc, PerDoctorState>(
            builder: (ctx, state) {
              if (_selectedDoctorId == null) {
                return Center(
                  child: Text('Select a doctor to view analytics',
                      style: AppTypography.body.copyWith(color: AppColors.neutral400)),
                );
              }
              if (state is PerDoctorLoading) return const Center(child: CircularProgressIndicator());
              if (state is PerDoctorError) {
                return Center(child: Text(state.message, style: AppTypography.body.copyWith(color: AppColors.danger)));
              }
              if (state is PerDoctorLoaded) {
                return _DoctorDetail(data: state.detail, range: state.range);
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}

class _DoctorSelectorBar extends StatelessWidget {
  final List<DoctorAtCenter> doctors;
  final String? selectedId;
  final DateRangePreset preset;
  final ValueChanged<String?> onDoctorChanged;
  final ValueChanged<DateRangePreset> onPresetChanged;

  const _DoctorSelectorBar({
    required this.doctors,
    required this.selectedId,
    required this.preset,
    required this.onDoctorChanged,
    required this.onPresetChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
      decoration: const BoxDecoration(
        color: AppColors.neutral50,
        border: Border(bottom: BorderSide(color: AppColors.neutral200)),
      ),
      child: Row(
        children: [
          Text('Doctor:', style: AppTypography.bodySmall.copyWith(color: AppColors.neutral500)),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 260,
            height: 36,
            child: DropdownButtonFormField<String>(
              // ignore: deprecated_member_use
              value: selectedId,
              style: AppTypography.bodySmall,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                border: OutlineInputBorder(borderRadius: AppRadius.radiusMd, borderSide: const BorderSide(color: AppColors.neutral200)),
                enabledBorder: OutlineInputBorder(borderRadius: AppRadius.radiusMd, borderSide: const BorderSide(color: AppColors.neutral200)),
              ),
              hint: const Text('Select doctor'),
              items: doctors.map((d) => DropdownMenuItem(value: d.doctorId, child: Text(d.fullName))).toList(),
              onChanged: onDoctorChanged,
            ),
          ),
          const Spacer(),
          DropdownButton<DateRangePreset>(
            value: preset,
            style: AppTypography.bodySmall,
            underline: const SizedBox.shrink(),
            items: const [
              DropdownMenuItem(value: DateRangePreset.last7, child: Text('Last 7 days')),
              DropdownMenuItem(value: DateRangePreset.last30, child: Text('Last 30 days')),
              DropdownMenuItem(value: DateRangePreset.last90, child: Text('Last 90 days')),
            ],
            onChanged: (v) { if (v != null) onPresetChanged(v); },
          ),
        ],
      ),
    );
  }
}

class _DoctorDetail extends StatelessWidget {
  final DoctorAnalyticsDetail data;
  final DateRangeSelection range;
  const _DoctorDetail({required this.data, required this.range});

  @override
  Widget build(BuildContext context) {
    final etb = NumberFormat('#,###.0');
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI row
          Wrap(
            spacing: AppSpacing.base,
            runSpacing: AppSpacing.base,
            children: [
              SizedBox(width: 200, child: KPICard(icon: Icons.calendar_today, title: 'Total Appointments', value: '${data.totalAppointments}')),
              SizedBox(width: 200, child: KPICard(icon: Icons.check_circle_outline, title: 'Completion Rate', value: '${data.completionRate.toStringAsFixed(1)}%')),
              SizedBox(width: 200, child: KPICard(icon: Icons.star_outline, title: 'Avg Rating', value: data.avgRating.toStringAsFixed(1))),
              SizedBox(width: 200, child: KPICard(icon: Icons.payments_outlined, title: 'Total Revenue', value: 'ETB ${etb.format(data.totalRevenueEtb)}')),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          // Volume trend
          LineChartCard(
            title: 'Appointment Volume',
            subtitle: range.label,
            series: [
              ChartSeries(
                name: 'Appointments',
                data: data.volumeTrend.map((p) => MapEntry(p.date, p.value)).toList(),
                color: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          // Day + Hour patterns
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: BarChartCard(
                  title: 'Day of Week Pattern',
                  horizontal: false,
                  data: List.generate(days.length, (i) => BarEntry(
                    label: days[i],
                    value: i < data.dayOfWeekPattern.length ? data.dayOfWeekPattern[i] : 0,
                  )),
                ),
              ),
              const SizedBox(width: AppSpacing.base),
              Expanded(
                child: BarChartCard(
                  title: 'Hour of Day Pattern',
                  horizontal: false,
                  data: List.generate(data.hourOfDayPattern.length, (i) => BarEntry(
                    label: '$i:00',
                    value: data.hourOfDayPattern[i],
                  )).where((e) => int.parse(e.label.split(':')[0]) >= 6 && int.parse(e.label.split(':')[0]) <= 22).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          // Top patients
          if (data.topPatients.isNotEmpty) ...[
            Text('Top Patients', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.sm),
            _TopPatientsTable(patients: data.topPatients),
            const SizedBox(height: AppSpacing.xl),
          ],
          // Recent reviews
          if (data.recentReviews.isNotEmpty) ...[
            Text('Recent Reviews', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.sm),
            ...data.recentReviews.take(10).map((r) => _ReviewCard(review: r)),
          ],
        ],
      ),
    );
  }
}

class _TopPatientsTable extends StatelessWidget {
  final List<TopPatientRow> patients;
  const _TopPatientsTable({required this.patients});

  @override
  Widget build(BuildContext context) {
    final etb = NumberFormat('#,###.0');
    return AppDataTable<TopPatientRow>(
      rows: patients,
      selectable: false,
      emptyMessage: 'No patient data',
      columns: [
        DataTableColumn(label: 'Patient', builder: (p) => Text(p.patientName, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600))),
        DataTableColumn(label: 'Visits', width: 80, builder: (p) => Text('${p.visitCount}', style: AppTypography.bodySmall)),
        DataTableColumn(label: 'Total Spent', width: 120, builder: (p) => Text('ETB ${etb.format(p.totalSpentEtb)}', style: AppTypography.bodySmall)),
        DataTableColumn(label: 'Last Visit', width: 120, builder: (p) => Text(DateFormat('MMM d, yyyy').format(p.lastVisit), style: AppTypography.caption.copyWith(color: AppColors.neutral500))),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final DoctorReview review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: AppRadius.radiusMd,
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: List.generate(5, (i) => Icon(
              i < review.rating.round() ? Icons.star : Icons.star_border,
              size: 14,
              color: AppColors.warning,
            )),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(review.patientName, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Text(DateFormat('MMM d, yyyy').format(review.date), style: AppTypography.caption.copyWith(color: AppColors.neutral400)),
                ]),
                if (review.comment != null)
                  Text(review.comment!, style: AppTypography.bodySmall.copyWith(color: AppColors.neutral600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
