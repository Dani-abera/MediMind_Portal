import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medimind_portal/core/utils/fa_compat.dart';
import 'package:intl/intl.dart';
import '../../../../../core/di/service_locator.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/widgets/buttons/app_button.dart';
import '../../../../../core/widgets/data_table/app_data_table.dart';
import '../../../../../core/widgets/shell/page_header.dart';
import '../../../../../core/widgets/status_badges/status_badge.dart';
import '../../../domain/entities/admin_appointment.dart';
import '../../bloc/all_appointments/all_appointments_bloc.dart';
import '../../widgets/admin_appointment_detail_drawer.dart';

class AllAppointmentsPage extends StatelessWidget {
  const AllAppointmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AllAppointmentsBloc>()..add(const AllApptsStarted()),
      child: const _AllAppointmentsView(),
    );
  }
}

class _AllAppointmentsView extends StatefulWidget {
  const _AllAppointmentsView();

  @override
  State<_AllAppointmentsView> createState() => _AllAppointmentsViewState();
}

class _AllAppointmentsViewState extends State<_AllAppointmentsView> {
  final _searchCtrl = TextEditingController();
  String? _statusFilter;
  DateTime? _fromDate;
  DateTime? _toDate;
  bool _todayOnly = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _applyFilters(BuildContext context) {
    context.read<AllAppointmentsBloc>().add(AllApptsFiltered(
          status: _statusFilter,
          from: _fromDate,
          to: _toDate,
          search: _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim(),
          todayOnly: _todayOnly,
        ));
  }

  void _clearFilters(BuildContext context) {
    _searchCtrl.clear();
    setState(() {
      _statusFilter = null;
      _fromDate = null;
      _toDate = null;
      _todayOnly = false;
    });
    context.read<AllAppointmentsBloc>().add(const AllApptsFiltered());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AllAppointmentsBloc, AllAppointmentsState>(
      listener: (ctx, state) {
        if (state is AllApptsError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.danger),
          );
        }
      },
      child: Column(
        children: [
          PageHeader(
            title: 'All Appointments',
            subtitle: 'Search and filter across all records',
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, size: 18),
                tooltip: 'Refresh',
                onPressed: () => _applyFilters(context),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          _FilterBar(
            searchCtrl: _searchCtrl,
            statusFilter: _statusFilter,
            fromDate: _fromDate,
            toDate: _toDate,
            todayOnly: _todayOnly,
            onStatusChanged: (v) { setState(() => _statusFilter = v); _applyFilters(context); },
            onFromDateChanged: (v) { setState(() => _fromDate = v); _applyFilters(context); },
            onToDateChanged: (v) { setState(() => _toDate = v); _applyFilters(context); },
            onTodayToggled: (v) { setState(() { _todayOnly = v; if (v) { _fromDate = null; _toDate = null; } }); _applyFilters(context); },
            onSearch: () => _applyFilters(context),
            onClear: () => _clearFilters(context),
          ),
          Expanded(child: _AppointmentsTable(onFilterPage: _applyFilters)),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final TextEditingController searchCtrl;
  final String? statusFilter;
  final DateTime? fromDate;
  final DateTime? toDate;
  final bool todayOnly;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<DateTime?> onFromDateChanged;
  final ValueChanged<DateTime?> onToDateChanged;
  final ValueChanged<bool> onTodayToggled;
  final VoidCallback onSearch;
  final VoidCallback onClear;

  const _FilterBar({
    required this.searchCtrl,
    required this.statusFilter,
    required this.fromDate,
    required this.toDate,
    required this.todayOnly,
    required this.onStatusChanged,
    required this.onFromDateChanged,
    required this.onToDateChanged,
    required this.onTodayToggled,
    required this.onSearch,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        border: Border(bottom: BorderSide(color: AppColors.neutral200)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 220,
            height: 36,
            child: TextField(
              controller: searchCtrl,
              style: AppTypography.bodySmall,
              decoration: InputDecoration(
                hintText: 'Search patient or doctor…',
                hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.neutral400),
                prefixIcon: const Icon(Icons.search, size: 16, color: AppColors.neutral400),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: AppRadius.radiusMd,
                  borderSide: BorderSide(color: AppColors.neutral200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppRadius.radiusMd,
                  borderSide: BorderSide(color: AppColors.neutral200),
                ),
              ),
              onSubmitted: (_) => onSearch(),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            height: 36,
            child: DropdownButtonHideUnderline(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.neutral200),
                  borderRadius: AppRadius.radiusMd,
                ),
                child: DropdownButton<String?>(
                  value: statusFilter,
                  hint: Text('Status', style: AppTypography.bodySmall.copyWith(color: AppColors.neutral500)),
                  isDense: true,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Statuses')),
                    ...AppointmentStatus.values.map((s) => DropdownMenuItem(
                          value: s.name,
                          child: Text(s.label),
                        )),
                  ],
                  onChanged: onStatusChanged,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _DateButton(
            label: fromDate != null ? DateFormat('MMM d').format(fromDate!) : 'From',
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: fromDate ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              onFromDateChanged(d);
            },
          ),
          const SizedBox(width: 6),
          const Text('—', style: TextStyle(color: AppColors.neutral400)),
          const SizedBox(width: 6),
          _DateButton(
            label: toDate != null ? DateFormat('MMM d').format(toDate!) : 'To',
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: toDate ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              onToDateChanged(d);
            },
          ),
          const SizedBox(width: AppSpacing.sm),
          FilterChip(
            label: const Text('Today', style: TextStyle(fontSize: 12)),
            selected: todayOnly,
            onSelected: onTodayToggled,
            visualDensity: VisualDensity.compact,
          ),
          const Spacer(),
          if (statusFilter != null || fromDate != null || toDate != null ||
              searchCtrl.text.isNotEmpty || todayOnly)
            AppButton.text(
              label: 'Clear Filters',
              icon: FontAwesomeIcons.xmark,
              onPressed: onClear,
            ),
        ],
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _DateButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: OutlinedButton.icon(
        icon: const Icon(Icons.calendar_today, size: 13),
        label: Text(label, style: AppTypography.bodySmall),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          side: BorderSide(color: AppColors.neutral200),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
        ),
        onPressed: onTap,
      ),
    );
  }
}

class _AppointmentsTable extends StatelessWidget {
  final void Function(BuildContext) onFilterPage;
  const _AppointmentsTable({required this.onFilterPage});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AllAppointmentsBloc, AllAppointmentsState>(
      builder: (ctx, state) {
        final appointments = state is AllApptsLoaded ? state.appointments : <AdminAppointment>[];
        final isLoading = state is AllApptsLoading || state is AllApptsInitial || state is AllApptsActionInProgress;
        final page = state is AllApptsLoaded ? state.page : 1;
        final pageSize = state is AllApptsLoaded ? state.pageSize : 20;
        final total = state is AllApptsLoaded ? state.total : 0;

        return AppDataTable<AdminAppointment>(
          rows: appointments,
          isLoading: isLoading,
          emptyMessage: 'No appointments found',
          selectable: false,
          onRowDoubleTap: (appt) => AdminAppointmentDetailDrawer.show(context, appointmentId: appt.id),
          pagination: PaginationConfig(
            page: page,
            pageSize: pageSize,
            total: total,
            onPageChanged: (p) => ctx.read<AllAppointmentsBloc>().add(AllApptsPageChanged(p)),
            onPageSizeChanged: (_) {},
          ),
          columns: [
            DataTableColumn(
              label: 'Patient',
              builder: (a) => Text(a.patientName,
                  style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis),
            ),
            DataTableColumn(
              label: 'Doctor',
              builder: (a) => Text(a.doctorName,
                  style: AppTypography.bodySmall, overflow: TextOverflow.ellipsis),
            ),
            DataTableColumn(
              label: 'Date & Time',
              width: 140,
              builder: (a) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(DateFormat('MMM d, yyyy').format(a.dateTime), style: AppTypography.bodySmall),
                  Text(DateFormat('h:mm a').format(a.dateTime),
                      style: AppTypography.caption.copyWith(color: AppColors.neutral500)),
                ],
              ),
            ),
            DataTableColumn(
              label: 'Type',
              width: 80,
              builder: (a) => Text(
                a.type == AppointmentType.video ? 'Video' : 'In-Person',
                style: AppTypography.caption.copyWith(color: AppColors.neutral600),
              ),
            ),
            DataTableColumn(
              label: 'Status',
              width: 110,
              builder: (a) => _statusBadge(a.status),
            ),
            DataTableColumn(
              label: 'Payment',
              width: 90,
              builder: (a) => _paymentBadge(a.paymentStatus),
            ),
          ],
        );
      },
    );
  }

  Widget _statusBadge(AppointmentStatus s) => switch (s) {
    AppointmentStatus.pending => const StatusBadge(label: 'Pending', status: BadgeStatus.pending),
    AppointmentStatus.confirmed => const StatusBadge(label: 'Confirmed', status: BadgeStatus.confirmed),
    AppointmentStatus.inProgress => const StatusBadge(label: 'In Progress', status: BadgeStatus.inProgress),
    AppointmentStatus.completed => const StatusBadge(label: 'Completed', status: BadgeStatus.completed),
    AppointmentStatus.cancelled => const StatusBadge(label: 'Cancelled', status: BadgeStatus.cancelled),
    AppointmentStatus.noShow => const StatusBadge(label: 'No Show', status: BadgeStatus.noShow),
  };

  Widget _paymentBadge(PaymentStatus s) => switch (s) {
    PaymentStatus.paid => const StatusBadge(label: 'Paid', status: BadgeStatus.completed),
    PaymentStatus.pending => const StatusBadge(label: 'Pending', status: BadgeStatus.pending),
    PaymentStatus.failed => const StatusBadge(label: 'Failed', status: BadgeStatus.cancelled),
    PaymentStatus.none => const StatusBadge(label: 'None', status: BadgeStatus.expired),
  };
}
