import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/data_table/app_data_table.dart';
import '../../../../core/widgets/feedback/app_loading.dart';
import '../../../../core/widgets/shell/page_header.dart';
import '../../domain/entities/patient_summary.dart';
import '../bloc/patient_list/patient_list_bloc.dart';

class PatientsListPage extends StatelessWidget {
  const PatientsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<PatientListBloc>()..add(const PatientListStarted()),
      child: const _PatientsListView(),
    );
  }
}

class _PatientsListView extends StatefulWidget {
  const _PatientsListView();

  @override
  State<_PatientsListView> createState() => _PatientsListViewState();
}

class _PatientsListViewState extends State<_PatientsListView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(BuildContext ctx, String query) {
    final bloc = ctx.read<PatientListBloc>();
    Future.delayed(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      if (_searchController.text == query) {
        bloc.add(PatientListSearched(query));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeader(title: 'My Patients'),
        _buildSearchBar(context),
        const Divider(height: 1),
        Expanded(
          child: BlocBuilder<PatientListBloc, PatientListState>(
            builder: (ctx, state) {
              if (state is PatientListLoading || state is PatientListInitial) {
                return const Center(child: AppLoadingSpinner());
              }
              if (state is PatientListError) {
                return AppErrorState(
                  message: state.message,
                  onRetry: () => ctx
                      .read<PatientListBloc>()
                      .add(const PatientListStarted()),
                );
              }
              if (state is PatientListLoaded) {
                return _buildTable(ctx, state);
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext ctx) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl, vertical: AppSpacing.base),
      child: SizedBox(
        width: 340,
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search patients...',
            prefixIcon: const Icon(Icons.search, size: 18),
            isDense: true,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.neutral300)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          onChanged: (q) => _onSearchChanged(ctx, q),
        ),
      ),
    );
  }

  Widget _buildTable(BuildContext ctx, PatientListLoaded state) {
    final columns = <DataTableColumn<PatientSummary>>[
      DataTableColumn(
        label: 'Name',
        builder: (p) => Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.primaryLight,
              child: Text(
                p.fullName.isNotEmpty ? p.fullName[0] : '?',
                style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12),
              ),
            ),
            const SizedBox(width: 8),
            Text(p.fullName, style: AppTypography.bodyMedium),
          ],
        ),
      ),
      DataTableColumn(
        label: 'Age / Gender',
        width: 110,
        builder: (p) => Text(
          '${p.age != null ? "${p.age}y" : "—"} / ${p.gender.label}',
          style: AppTypography.bodySmall,
        ),
      ),
      DataTableColumn(
        label: 'Phone',
        width: 130,
        builder: (p) => Text(p.phone, style: AppTypography.bodySmall),
      ),
      DataTableColumn(
        label: 'Last Visit',
        width: 110,
        builder: (p) => Text(
          p.lastVisit != null
              ? DateFormat('MMM d, y').format(p.lastVisit!)
              : 'Never',
          style: AppTypography.bodySmall
              .copyWith(color: AppColors.neutral500),
        ),
      ),
      DataTableColumn(
        label: 'Visits',
        width: 60,
        builder: (p) => Text('${p.totalVisits}',
            style: AppTypography.bodySmall),
      ),
      DataTableColumn(
        label: 'Risk',
        width: 80,
        builder: (p) => p.latestRiskScore != null
            ? _riskChip(p.latestRiskScore!)
            : Text('—',
                style:
                    AppTypography.bodySmall.copyWith(color: AppColors.neutral400)),
      ),
    ];

    return AppDataTable<PatientSummary>(
      rows: state.patients,
      columns: columns,
      emptyMessage: state.query.isNotEmpty
          ? 'No patients match "${state.query}"'
          : 'No patients found',
      onRowTap: (p) => context.push('/doctor/patients/${p.id}'),
      pagination: PaginationConfig(
        page: state.page,
        pageSize: 20,
        total: state.patients.length + (state.hasMore ? 1 : 0),
        onPageChanged: (_) =>
            ctx.read<PatientListBloc>().add(const PatientListNextPage()),
        onPageSizeChanged: (_) {},
      ),
    );
  }

  Widget _riskChip(double score) {
    final color = score >= 0.7
        ? AppColors.danger
        : score >= 0.4
            ? AppColors.warning
            : AppColors.success;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        '${(score * 100).toStringAsFixed(0)}%',
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}
