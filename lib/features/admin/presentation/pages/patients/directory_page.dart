import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../../core/di/service_locator.dart';
import '../../../../../core/network/user_context.dart';
import '../../../../../core/routing/route_names.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/data_table/app_data_table.dart';
import '../../../../../core/widgets/shell/page_header.dart';
import '../../../domain/entities/patient_at_center.dart';
import '../../bloc/patient_directory/patient_directory_bloc.dart';

class PatientDirectoryPage extends StatelessWidget {
  const PatientDirectoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PatientDirectoryBloc>()
        ..add(PatientDirStarted(UserContext().centerId ?? '')),
      child: const _PatientDirectoryView(),
    );
  }
}

class _PatientDirectoryView extends StatefulWidget {
  const _PatientDirectoryView();

  @override
  State<_PatientDirectoryView> createState() => _PatientDirectoryViewState();
}

class _PatientDirectoryViewState extends State<_PatientDirectoryView> {
  final _searchCtrl = TextEditingController();
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PatientDirectoryBloc, PatientDirState>(
      listener: (ctx, state) {
        if (state is PatientDirError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.danger),
          );
        }
      },
      child: Column(
        children: [
          PageHeader(
            title: 'Patient Directory',
            subtitle: 'All patients registered at this center',
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, size: 18),
                onPressed: () => context.read<PatientDirectoryBloc>()
                    .add(const PatientDirRefreshed()),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          _FilterRow(
            searchCtrl: _searchCtrl,
            fromDate: _fromDate,
            toDate: _toDate,
            onSearchChanged: (q) => context.read<PatientDirectoryBloc>().add(PatientDirSearched(q)),
            onFromChanged: (d) {
              setState(() => _fromDate = d);
              context.read<PatientDirectoryBloc>().add(PatientDirFiltered(from: d, to: _toDate));
            },
            onToChanged: (d) {
              setState(() => _toDate = d);
              context.read<PatientDirectoryBloc>().add(PatientDirFiltered(from: _fromDate, to: d));
            },
          ),
          Expanded(child: _PatientTable()),
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  final TextEditingController searchCtrl;
  final DateTime? fromDate;
  final DateTime? toDate;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<DateTime?> onFromChanged;
  final ValueChanged<DateTime?> onToChanged;

  const _FilterRow({
    required this.searchCtrl,
    required this.fromDate,
    required this.toDate,
    required this.onSearchChanged,
    required this.onFromChanged,
    required this.onToChanged,
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
            width: 260,
            height: 36,
            child: TextField(
              controller: searchCtrl,
              style: AppTypography.bodySmall,
              decoration: InputDecoration(
                hintText: 'Search by name or phone…',
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
              onChanged: onSearchChanged,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _DateBtn(
            label: fromDate != null ? DateFormat('MMM d').format(fromDate!) : 'First Visit From',
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: fromDate ?? DateTime.now(),
                firstDate: DateTime(2015),
                lastDate: DateTime.now(),
              );
              onFromChanged(d);
            },
          ),
          const SizedBox(width: 6),
          _DateBtn(
            label: toDate != null ? DateFormat('MMM d').format(toDate!) : 'To',
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: toDate ?? DateTime.now(),
                firstDate: DateTime(2015),
                lastDate: DateTime.now(),
              );
              onToChanged(d);
            },
          ),
        ],
      ),
    );
  }
}

class _DateBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _DateBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          side: BorderSide(color: AppColors.neutral200),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
        ),
        onPressed: onTap,
        child: Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.neutral600)),
      ),
    );
  }
}

class _PatientTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatientDirectoryBloc, PatientDirState>(
      builder: (ctx, state) {
        final patients = state is PatientDirLoaded ? state.patients : <PatientAtCenter>[];
        final isLoading = state is PatientDirLoading || state is PatientDirInitial;
        final page = state is PatientDirLoaded ? state.page : 1;
        final pageSize = state is PatientDirLoaded ? state.pageSize : 20;
        final total = state is PatientDirLoaded ? state.total : 0;

        return AppDataTable<PatientAtCenter>(
          rows: patients,
          isLoading: isLoading,
          emptyMessage: 'No patients found',
          selectable: false,
          onRowTap: (p) => context.push(
            RouteNames.adminPatientDetail.replaceFirst(':id', p.patientId),
          ),
          pagination: PaginationConfig(
            page: page,
            pageSize: pageSize,
            total: total,
            onPageChanged: (p) => ctx.read<PatientDirectoryBloc>().add(PatientDirPageChanged(p)),
            onPageSizeChanged: (_) {},
          ),
          columns: [
            DataTableColumn(
              label: 'Patient',
              builder: (p) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(p.fullName,
                      style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis),
                  if (p.phone != null)
                    Text(p.phone!,
                        style: AppTypography.caption.copyWith(color: AppColors.neutral500)),
                ],
              ),
            ),
            DataTableColumn(
              label: 'Age',
              width: 60,
              builder: (p) => Text(
                p.age != null ? '${p.age}' : '—',
                style: AppTypography.bodySmall,
              ),
            ),
            DataTableColumn(
              label: 'Gender',
              width: 80,
              builder: (p) => Text(
                p.gender?.label ?? '—',
                style: AppTypography.bodySmall.copyWith(color: AppColors.neutral600),
              ),
            ),
            DataTableColumn(
              label: 'Total Visits',
              width: 90,
              builder: (p) => Text(
                '${p.totalAppointments}',
                style: AppTypography.bodySmall,
              ),
            ),
            DataTableColumn(
              label: 'Total Spent',
              width: 110,
              builder: (p) => Text(
                p.totalSpentEtb > 0 ? 'ETB ${p.totalSpentEtb.toStringAsFixed(0)}' : '—',
                style: AppTypography.bodySmall,
              ),
            ),
            DataTableColumn(
              label: 'Last Visit',
              width: 110,
              builder: (p) => Text(
                p.lastVisit != null ? DateFormat('MMM d, yyyy').format(p.lastVisit!) : '—',
                style: AppTypography.caption.copyWith(color: AppColors.neutral500),
              ),
            ),
          ],
        );
      },
    );
  }
}
