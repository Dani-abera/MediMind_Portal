import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/network/user_context.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/data_table/app_data_table.dart';
import '../../../../core/widgets/drawers/side_drawer.dart';
import '../../../../core/widgets/shell/page_header.dart';
import '../domain/entities/audit_entry.dart';
import '../presentation/bloc/audit_log/audit_log_bloc.dart';

class AuditLogPage extends StatelessWidget {
  const AuditLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuditLogBloc>()
        ..add(AuditLogStarted(UserContext().centerId ?? '')),
      child: const _AuditLogView(),
    );
  }
}

class _AuditLogView extends StatefulWidget {
  const _AuditLogView();
  @override
  State<_AuditLogView> createState() => _AuditLogViewState();
}

class _AuditLogViewState extends State<_AuditLogView> {
  AuditLogFilters _filters = const AuditLogFilters();
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuditLogBloc, AuditLogState>(
      listener: (ctx, state) {
        if (state is AuditLogExportDone) {
          ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Audit log exported')));
        }
        if (state is AuditLogError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.danger),
          );
        }
      },
      child: Column(
        children: [
          PageHeader(
            title: 'Audit Log',
            subtitle: 'Append-only activity trail — read only',
            actions: [
              BlocBuilder<AuditLogBloc, AuditLogState>(
                builder: (ctx, state) => IconButton(
                  icon: state is AuditLogExporting
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.download_outlined, size: 18),
                  tooltip: 'Export CSV',
                  onPressed: () => ctx.read<AuditLogBloc>().add(const AuditLogExportRequested()),
                  visualDensity: VisualDensity.compact,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, size: 18),
                onPressed: () => context.read<AuditLogBloc>().add(const AuditLogRefreshed()),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          _FilterBar(
            filters: _filters,
            searchCtrl: _searchCtrl,
            onChanged: (f) {
              setState(() => _filters = f);
              context.read<AuditLogBloc>().add(AuditLogFiltered(f));
            },
          ),
          Expanded(
            child: BlocBuilder<AuditLogBloc, AuditLogState>(
              builder: (ctx, state) {
                final entries = state is AuditLogLoaded ? state.entries : <AuditEntry>[];
                final total = state is AuditLogLoaded ? state.total : 0;
                final page = state is AuditLogLoaded ? state.page : 1;
                const pageSize = 50;
                final isLoading = state is AuditLogLoading;

                return AppDataTable<AuditEntry>(
                  rows: entries,
                  isLoading: isLoading,
                  selectable: false,
                  emptyMessage: 'No audit entries found',
                  pagination: PaginationConfig(
                    page: page,
                    pageSize: pageSize,
                    total: total,
                    onPageChanged: (p) => ctx.read<AuditLogBloc>().add(AuditLogPageChanged(p)),
                    onPageSizeChanged: (_) {},
                  ),
                  onRowTap: (e) => SideDrawer.show(context, title: 'Audit Entry Detail', body: _MetadataDrawer(entry: e)),
                  columns: [
                    DataTableColumn(
                      label: 'Timestamp',
                      width: 140,
                      builder: (e) => Tooltip(
                        message: e.timestamp.toIso8601String(),
                        child: Text(DateFormat('MMM d HH:mm:ss').format(e.timestamp),
                            style: AppTypography.caption.copyWith(color: AppColors.neutral500)),
                      ),
                    ),
                    DataTableColumn(
                      label: 'User',
                      width: 160,
                      builder: (e) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(e.userName, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                          _RoleBadge(role: e.userRole),
                        ],
                      ),
                    ),
                    DataTableColumn(
                      label: 'Action',
                      width: 200,
                      builder: (e) => _ActionChip(action: e.action),
                    ),
                    DataTableColumn(
                      label: 'Entity',
                      width: 160,
                      builder: (e) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(e.entityType, style: AppTypography.bodySmall),
                          Text(
                            e.entityId.length > 12 ? '...${e.entityId.substring(e.entityId.length - 8)}' : e.entityId,
                            style: AppTypography.caption.copyWith(color: AppColors.neutral400),
                          ),
                        ],
                      ),
                    ),
                    DataTableColumn(
                      label: 'IP Address',
                      width: 120,
                      builder: (e) => Text(e.ipAddress, style: AppTypography.caption.copyWith(color: AppColors.neutral500)),
                    ),
                    DataTableColumn(
                      label: 'User Agent',
                      builder: (e) => e.userAgent != null
                          ? Tooltip(
                              message: e.userAgent!,
                              child: Text(
                                e.userAgent!.length > 30 ? '${e.userAgent!.substring(0, 30)}…' : e.userAgent!,
                                style: AppTypography.caption.copyWith(color: AppColors.neutral400),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final AuditLogFilters filters;
  final TextEditingController searchCtrl;
  final ValueChanged<AuditLogFilters> onChanged;

  const _FilterBar({required this.filters, required this.searchCtrl, required this.onChanged});

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
          SizedBox(
            width: 260,
            height: 36,
            child: TextField(
              controller: searchCtrl,
              style: AppTypography.bodySmall,
              decoration: InputDecoration(
                hintText: 'Search metadata…',
                hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.neutral400),
                prefixIcon: const Icon(Icons.search, size: 16, color: AppColors.neutral400),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                border: OutlineInputBorder(borderRadius: AppRadius.radiusMd, borderSide: const BorderSide(color: AppColors.neutral200)),
                enabledBorder: OutlineInputBorder(borderRadius: AppRadius.radiusMd, borderSide: const BorderSide(color: AppColors.neutral200)),
              ),
              onChanged: (q) => onChanged(filters.copyWith(searchQuery: q.isEmpty ? null : q)),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Date range
          _DateButton(
            label: filters.from != null ? DateFormat('MMM d').format(filters.from!) : 'From',
            onTap: () async {
              final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime.now());
              if (d != null) onChanged(filters.copyWith(from: d));
            },
          ),
          const SizedBox(width: 4),
          _DateButton(
            label: filters.to != null ? DateFormat('MMM d').format(filters.to!) : 'To',
            onTap: () async {
              final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime.now());
              if (d != null) onChanged(filters.copyWith(to: d));
            },
          ),
          const SizedBox(width: AppSpacing.sm),
          if (filters.from != null || filters.to != null || filters.searchQuery != null)
            TextButton(
              onPressed: () {
                searchCtrl.clear();
                onChanged(const AuditLogFilters());
              },
              child: const Text('Clear', style: TextStyle(fontSize: 12)),
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
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          side: const BorderSide(color: AppColors.neutral200),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
        ),
        onPressed: onTap,
        child: Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.neutral600)),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    final color = switch (role.toLowerCase()) {
      'admin'        => AppColors.primary,
      'receptionist' => AppColors.info,
      'doctor'       => AppColors.success,
      _              => AppColors.neutral400,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: AppRadius.radiusFull),
      child: Text(role, style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final AuditAction action;
  const _ActionChip({required this.action});

  @override
  Widget build(BuildContext context) {
    final color = switch (action) {
      AuditAction.appointmentApproved   || AuditAction.doctorAdded    || AuditAction.adminAdded    => AppColors.success,
      AuditAction.appointmentRejected   || AuditAction.doctorRemoved  || AuditAction.adminDeactivated => AppColors.danger,
      AuditAction.appointmentCancelled  || AuditAction.queueMarkNoShow => AppColors.warning,
      _ => AppColors.neutral500,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(color: color.withAlpha(15), borderRadius: AppRadius.radiusSm),
      child: Text(action.label,
          style: AppTypography.caption.copyWith(
            color: color, fontWeight: FontWeight.w600, fontSize: 10, letterSpacing: 0.3)),
    );
  }
}

class _MetadataDrawer extends StatelessWidget {
  final AuditEntry entry;
  const _MetadataDrawer({required this.entry});

  @override
  Widget build(BuildContext context) {
    const encoder = JsonEncoder.withIndent('  ');
    final prettyJson = encoder.convert(entry.metadata);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _field('Action', entry.action.label),
        _field('Timestamp', entry.timestamp.toIso8601String()),
        _field('User', '${entry.userName} (${entry.userRole})'),
        _field('Entity', '${entry.entityType} / ${entry.entityId}'),
        _field('IP Address', entry.ipAddress),
        if (entry.userAgent != null) _field('User Agent', entry.userAgent!),
        const Divider(height: AppSpacing.xl),
        Text('Metadata', style: AppTypography.h3),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.all(AppSpacing.base),
          decoration: BoxDecoration(
            color: AppColors.neutral900,
            borderRadius: AppRadius.radiusMd,
          ),
          child: Text(
            prettyJson,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: Color(0xFF80CBC4),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _field(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 110, child: Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.neutral500))),
        Expanded(child: Text(value, style: AppTypography.bodySmall)),
      ],
    ),
  );
}
