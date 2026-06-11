import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medimind_portal/core/utils/fa_compat.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/data_table/app_data_table.dart';
import '../../../../core/widgets/feedback/app_loading.dart';
import '../../../../core/widgets/shell/page_header.dart';
import '../../../../core/widgets/status_badges/status_badge.dart';
import '../../domain/entities/appointment.dart';
import '../bloc/appointment_list/appointment_list_bloc.dart';
import '../widgets/appointment_detail_drawer.dart';

class AppointmentsListPage extends StatelessWidget {
  const AppointmentsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<AppointmentListBloc>()..add(const AppointmentListStarted()),
      child: const _AppointmentsListView(),
    );
  }
}

class _AppointmentsListView extends StatefulWidget {
  const _AppointmentsListView();

  @override
  State<_AppointmentsListView> createState() => _AppointmentsListViewState();
}

class _AppointmentsListViewState extends State<_AppointmentsListView> {
  String? _selectedStatus;
  DateTime? _fromDate;
  DateTime? _toDate;

  final _statusOptions = const [
    'All',
    'pending',
    'confirmed',
    'inProgress',
    'completed',
    'cancelled',
  ];

  void _applyFilter(BuildContext ctx) {
    ctx.read<AppointmentListBloc>().add(AppointmentListFiltered(
          status: _selectedStatus == 'All' ? null : _selectedStatus,
          from: _fromDate,
          to: _toDate,
        ));
  }

  Future<void> _pickDate(BuildContext ctx, bool isFrom) async {
    final bloc = ctx.read<AppointmentListBloc>();
    final picked = await showDatePicker(
      context: ctx,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked == null) return;
    DateTime? from = _fromDate;
    DateTime? to = _toDate;
    setState(() {
      if (isFrom) {
        _fromDate = picked;
        from = picked;
      } else {
        _toDate = picked;
        to = picked;
      }
    });
    if (mounted) {
      bloc.add(AppointmentListFiltered(
        status: _selectedStatus == 'All' ? null : _selectedStatus,
        from: from,
        to: to,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Appointments',
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, size: 18),
              tooltip: 'Refresh',
              onPressed: () => context
                  .read<AppointmentListBloc>()
                  .add(const AppointmentListStarted()),
            ),
          ],
        ),
        _buildFilterRow(context),
        const Divider(height: 1),
        Expanded(
          child: BlocBuilder<AppointmentListBloc, AppointmentListState>(
            builder: (ctx, state) {
              if (state is AppointmentListLoading ||
                  state is AppointmentListInitial) {
                return const Center(child: AppLoadingSpinner());
              }
              if (state is AppointmentListError) {
                return AppErrorState(
                  message: state.message,
                  onRetry: () => ctx
                      .read<AppointmentListBloc>()
                      .add(const AppointmentListStarted()),
                );
              }
              if (state is AppointmentListLoaded) {
                return _buildTable(ctx, state);
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterRow(BuildContext ctx) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
      child: Row(
        children: [
          const Text('Status:', style: TextStyle(fontSize: 13)),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: _selectedStatus ?? 'All',
            isDense: true,
            underline: const SizedBox.shrink(),
            items: _statusOptions
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) {
              setState(() => _selectedStatus = v);
              _applyFilter(ctx);
            },
          ),
          const SizedBox(width: 16),
          TextButton.icon(
            icon: const Icon(FontAwesomeIcons.calendar, size: 13),
            label: Text(
              _fromDate != null
                  ? DateFormat('MMM d').format(_fromDate!)
                  : 'From',
              style: const TextStyle(fontSize: 13),
            ),
            onPressed: () => _pickDate(ctx, true),
          ),
          const Text('–', style: TextStyle(color: AppColors.neutral400)),
          TextButton.icon(
            icon: const Icon(FontAwesomeIcons.calendar, size: 13),
            label: Text(
              _toDate != null ? DateFormat('MMM d').format(_toDate!) : 'To',
              style: const TextStyle(fontSize: 13),
            ),
            onPressed: () => _pickDate(ctx, false),
          ),
          if (_fromDate != null || _toDate != null)
            TextButton(
              onPressed: () {
                setState(() {
                  _fromDate = null;
                  _toDate = null;
                });
                _applyFilter(ctx);
              },
              child: const Text('Clear'),
            ),
        ],
      ),
    );
  }

  Widget _buildTable(BuildContext ctx, AppointmentListLoaded state) {
    final columns = <DataTableColumn<Appointment>>[
      DataTableColumn(
        label: 'Time',
        width: 80,
        builder: (a) => Text(
          DateFormat('HH:mm').format(a.dateTime),
          style: AppTypography.body,
        ),
      ),
      DataTableColumn(
        label: 'Date',
        width: 100,
        builder: (a) => Text(
          DateFormat('MMM d').format(a.dateTime),
          style: AppTypography.bodySmall,
        ),
      ),
      DataTableColumn(
        label: 'Patient',
        builder: (a) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(a.patientName, style: AppTypography.bodyMedium),
            if (a.patientAge != null)
              Text('${a.patientAge} y/o',
                  style: AppTypography.caption
                      .copyWith(color: AppColors.neutral500)),
          ],
        ),
      ),
      DataTableColumn(
        label: 'Type',
        width: 100,
        builder: (a) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: a.type == AppointmentType.video
                ? AppColors.info.withAlpha(20)
                : AppColors.neutral100,
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            a.type == AppointmentType.video ? 'Video' : 'In-Person',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: a.type == AppointmentType.video
                  ? AppColors.info
                  : AppColors.neutral600,
            ),
          ),
        ),
      ),
      DataTableColumn(
        label: 'Reason',
        builder: (a) => Text(
          a.reason,
          style: AppTypography.bodySmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      DataTableColumn(
        label: 'Status',
        width: 110,
        builder: (a) => StatusBadge(
          label: a.status.label,
          status: _mapStatus(a.status),
        ),
      ),
    ];

    return AppDataTable<Appointment>(
      rows: state.appointments,
      columns: columns,
      isLoading: false,
      emptyMessage: 'No appointments found',
      onRowTap: (appt) => AppointmentDetailDrawer.show(context, appt.id),
      pagination: PaginationConfig(
        page: state.page,
        pageSize: 20,
        total: state.appointments.length + (state.hasMore ? 1 : 0),
        onPageChanged: (_) =>
            ctx.read<AppointmentListBloc>().add(const AppointmentListNextPage()),
        onPageSizeChanged: (_) {},
      ),
    );
  }

  BadgeStatus _mapStatus(AppointmentStatus s) => switch (s) {
        AppointmentStatus.pending => BadgeStatus.pending,
        AppointmentStatus.confirmed => BadgeStatus.confirmed,
        AppointmentStatus.inProgress => BadgeStatus.inProgress,
        AppointmentStatus.completed => BadgeStatus.completed,
        AppointmentStatus.cancelled => BadgeStatus.cancelled,
        AppointmentStatus.noShow => BadgeStatus.noShow,
      };
}
