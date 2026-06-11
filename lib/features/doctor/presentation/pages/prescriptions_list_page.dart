import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medimind_portal/core/utils/fa_compat.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/data_table/app_data_table.dart';
import '../../../../core/widgets/feedback/app_loading.dart';
import '../../../../core/widgets/shell/page_header.dart';
import '../../../../core/widgets/status_badges/status_badge.dart';
import '../../domain/entities/prescription.dart';
import '../bloc/prescription_list/prescription_list_bloc.dart';
import '../widgets/prescription_detail_drawer.dart';

class PrescriptionsListPage extends StatelessWidget {
  const PrescriptionsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<PrescriptionListBloc>()..add(const PrescriptionListStarted()),
      child: const _PrescriptionsListView(),
    );
  }
}

class _PrescriptionsListView extends StatefulWidget {
  const _PrescriptionsListView();

  @override
  State<_PrescriptionsListView> createState() => _PrescriptionsListViewState();
}

class _PrescriptionsListViewState extends State<_PrescriptionsListView> {
  String? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PageHeader(
          title: 'Prescriptions',
          actions: [
            FilledButton.icon(
              icon: const Icon(FontAwesomeIcons.plus, size: 13),
              label: const Text('New Prescription'),
              onPressed: () =>
                  context.push(RouteNames.doctorPrescriptionsNew),
            ),
          ],
        ),
        _buildFilterRow(context),
        const Divider(height: 1),
        Expanded(
          child: BlocBuilder<PrescriptionListBloc, PrescriptionListState>(
            builder: (ctx, state) {
              if (state is PrescriptionListLoading ||
                  state is PrescriptionListInitial) {
                return const Center(child: AppLoadingSpinner());
              }
              if (state is PrescriptionListError) {
                return AppErrorState(
                  message: state.message,
                  onRetry: () => ctx
                      .read<PrescriptionListBloc>()
                      .add(const PrescriptionListStarted()),
                );
              }
              if (state is PrescriptionListLoaded) {
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
    const statuses = ['All', 'active', 'dispensed', 'expired', 'revoked'];
    return Padding(
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
            items: statuses
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) {
              setState(() => _selectedStatus = v);
              ctx.read<PrescriptionListBloc>().add(
                    PrescriptionListFiltered(
                        status: v == 'All' ? null : v),
                  );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTable(BuildContext ctx, PrescriptionListLoaded state) {
    final columns = <DataTableColumn<Prescription>>[
      DataTableColumn(
        label: 'Date',
        width: 100,
        builder: (p) => Text(
          DateFormat('MMM d, y').format(p.issuedAt),
          style: AppTypography.bodySmall,
        ),
      ),
      DataTableColumn(
        label: 'Patient',
        builder: (p) => Text(p.patientName, style: AppTypography.bodyMedium),
      ),
      DataTableColumn(
        label: 'Diagnosis',
        builder: (p) => Text(
          p.diagnosis,
          style: AppTypography.bodySmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      DataTableColumn(
        label: 'Medications',
        width: 100,
        builder: (p) => Text(
          '${p.medications.length} item(s)',
          style: AppTypography.bodySmall,
        ),
      ),
      DataTableColumn(
        label: 'Status',
        width: 100,
        builder: (p) => StatusBadge(
          label: p.status.label,
          status: _mapStatus(p.status),
        ),
      ),
    ];

    return AppDataTable<Prescription>(
      rows: state.prescriptions,
      columns: columns,
      emptyMessage: 'No prescriptions found',
      onRowTap: (p) =>
          PrescriptionDetailDrawer.show(context, p.id),
      pagination: PaginationConfig(
        page: state.page,
        pageSize: 20,
        total: state.prescriptions.length + (state.hasMore ? 1 : 0),
        onPageChanged: (_) => ctx
            .read<PrescriptionListBloc>()
            .add(const PrescriptionListNextPage()),
        onPageSizeChanged: (_) {},
      ),
    );
  }

  BadgeStatus _mapStatus(PrescriptionStatus s) => switch (s) {
        PrescriptionStatus.active => BadgeStatus.active,
        PrescriptionStatus.dispensed => BadgeStatus.completed,
        PrescriptionStatus.expired => BadgeStatus.expired,
        PrescriptionStatus.revoked => BadgeStatus.cancelled,
      };
}
