import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/di/service_locator.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/data_table/app_data_table.dart';
import '../../../../../core/widgets/shell/page_header.dart';
import '../../../domain/entities/platform_audit_entry.dart';
import '../../bloc/platform_audit/platform_audit_bloc.dart';

class GlobalAuditLogPage extends StatelessWidget {
  const GlobalAuditLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PlatformAuditBloc>()..add(const PlatformAuditStarted()),
      child: const _AuditLogView(),
    );
  }
}

class _AuditLogView extends StatelessWidget {
  const _AuditLogView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlatformAuditBloc, PlatformAuditState>(
      listener: (ctx, state) {
        if (state is PlatformAuditExportDone) {
          ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Audit log exported')));
        }
        if (state is PlatformAuditError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.danger),
          );
        }
      },
      child: Column(
        children: [
          PageHeader(
            title: 'Global Audit Log',
            subtitle: 'Platform-wide activity trail — read only',
            actions: [
              BlocBuilder<PlatformAuditBloc, PlatformAuditState>(
                builder: (ctx, state) => IconButton(
                  icon: state is PlatformAuditExporting
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.download_outlined, size: 18),
                  tooltip: 'Export',
                  onPressed: () => ctx.read<PlatformAuditBloc>().add(const PlatformAuditExportRequested()),
                  visualDensity: VisualDensity.compact,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, size: 18),
                onPressed: () => context.read<PlatformAuditBloc>().add(const PlatformAuditRefreshed()),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          Expanded(
            child: BlocBuilder<PlatformAuditBloc, PlatformAuditState>(
              builder: (ctx, state) {
                final entries = state is PlatformAuditLoaded ? state.entries : <PlatformAuditEntry>[];
                final total = state is PlatformAuditLoaded ? state.total : 0;
                final page = state is PlatformAuditLoaded ? state.page : 1;
                const pageSize = 50;
                final isLoading = state is PlatformAuditLoading;

                return AppDataTable<PlatformAuditEntry>(
                  rows: entries,
                  isLoading: isLoading,
                  selectable: false,
                  density: TableDensity.spacious,
                  emptyMessage: 'No audit entries found',
                  pagination: PaginationConfig(
                    page: page,
                    pageSize: pageSize,
                    total: total,
                    onPageChanged: (p) => ctx.read<PlatformAuditBloc>().add(PlatformAuditPageChanged(p)),
                    onPageSizeChanged: (_) {},
                  ),
                  columns: [
                    DataTableColumn(
                      label: 'Timestamp',
                      width: 140,
                      builder: (e) => Text(
                        DateFormat('MMM d HH:mm:ss').format(e.timestamp),
                        style: AppTypography.caption.copyWith(color: AppColors.neutral500),
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
                          Text(e.userRole, style: AppTypography.caption.copyWith(color: AppColors.neutral400)),
                        ],
                      ),
                    ),
                    DataTableColumn(
                      label: 'Center',
                      width: 140,
                      builder: (e) => Text(e.centerName ?? '—', style: AppTypography.bodySmall),
                    ),
                    DataTableColumn(
                      label: 'Action',
                      builder: (e) => Text(e.action, style: AppTypography.bodySmall),
                    ),
                    DataTableColumn(
                      label: 'Entity',
                      width: 130,
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
                      label: 'IP',
                      width: 120,
                      builder: (e) => Text(e.ipAddress ?? '—', style: AppTypography.caption.copyWith(color: AppColors.neutral500)),
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
