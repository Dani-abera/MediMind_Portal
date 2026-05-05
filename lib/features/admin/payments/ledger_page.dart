import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/network/user_context.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/data_table/app_data_table.dart';
import '../../../../core/widgets/drawers/side_drawer.dart';
import '../../../../core/widgets/shell/page_header.dart';
import '../../../../core/widgets/status_badges/status_badge.dart';
import '../domain/entities/audit_entry.dart';
import '../domain/entities/payment.dart';
import '../presentation/bloc/payments/payments_ledger_bloc.dart';

class PaymentsLedgerPage extends StatelessWidget {
  const PaymentsLedgerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PaymentsLedgerBloc>()
        ..add(PaymentsLedgerStarted(UserContext().centerId ?? '')),
      child: const _LedgerView(),
    );
  }
}

class _LedgerView extends StatefulWidget {
  const _LedgerView();
  @override
  State<_LedgerView> createState() => _LedgerViewState();
}

class _LedgerViewState extends State<_LedgerView> {
  PaymentFilters _filters = const PaymentFilters();

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentsLedgerBloc, PaymentsLedgerState>(
      listener: (ctx, state) {
        if (state is PaymentsActionSuccess) {
          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(state.message)));
        }
        if (state is PaymentsLedgerError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.danger),
          );
        }
      },
      child: Column(
        children: [
          PageHeader(
            title: 'Payments Ledger',
            subtitle: 'All payment transactions',
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, size: 18),
                onPressed: () => context.read<PaymentsLedgerBloc>().add(const PaymentsLedgerRefreshed()),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          _FilterBar(
            filters: _filters,
            onChanged: (f) {
              setState(() => _filters = f);
              context.read<PaymentsLedgerBloc>().add(PaymentsLedgerFiltered(f));
            },
          ),
          Expanded(
            child: BlocBuilder<PaymentsLedgerBloc, PaymentsLedgerState>(
              builder: (ctx, state) {
                final payments = state is PaymentsLedgerLoaded ? state.payments : <Payment>[];
                final isLoading = state is PaymentsLedgerLoading;
                final page = state is PaymentsLedgerLoaded ? state.page : 1;
                final pageSize = state is PaymentsLedgerLoaded ? state.pageSize : 20;

                return AppDataTable<Payment>(
                  rows: payments,
                  isLoading: isLoading,
                  selectable: false,
                  emptyMessage: 'No payment records',
                  pagination: PaginationConfig(
                    page: page,
                    pageSize: pageSize,
                    total: payments.length + (payments.length == pageSize ? 1 : 0),
                    onPageChanged: (p) => ctx.read<PaymentsLedgerBloc>().add(PaymentsLedgerPageChanged(p)),
                    onPageSizeChanged: (_) {},
                  ),
                  onRowTap: (p) => SideDrawer.show(context, title: 'Payment Detail', body: _PaymentDetailDrawer(payment: p)),
                  columns: [
                    DataTableColumn(
                      label: 'Date',
                      width: 110,
                      builder: (p) => Text(DateFormat('MMM d, yyyy').format(p.date), style: AppTypography.caption.copyWith(color: AppColors.neutral500)),
                    ),
                    DataTableColumn(
                      label: 'Ref',
                      width: 120,
                      builder: (p) => Text(p.ref.length > 12 ? '...${p.ref.substring(p.ref.length - 8)}' : p.ref,
                          style: AppTypography.caption.copyWith(color: AppColors.neutral500)),
                    ),
                    DataTableColumn(
                      label: 'Patient',
                      builder: (p) => Text(p.patientName, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                    ),
                    DataTableColumn(
                      label: 'Doctor',
                      builder: (p) => Text(p.doctorName, style: AppTypography.bodySmall),
                    ),
                    DataTableColumn(
                      label: 'Amount',
                      width: 110,
                      builder: (p) => Text('ETB ${NumberFormat('#,###.0').format(p.amount)}',
                          style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                    ),
                    DataTableColumn(
                      label: 'Method',
                      width: 110,
                      builder: (p) => Text(p.method.label, style: AppTypography.bodySmall),
                    ),
                    DataTableColumn(
                      label: 'Status',
                      width: 100,
                      builder: (p) => _paymentStatusBadge(p.status),
                    ),
                    DataTableColumn(
                      label: '',
                      width: 60,
                      builder: (p) => p.status == AdminPaymentStatus.failed
                          ? TextButton(
                              onPressed: () => ctx.read<PaymentsLedgerBloc>().add(PaymentResolveRequested(p.id)),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                visualDensity: VisualDensity.compact,
                              ),
                              child: const Text('Resolve', style: TextStyle(fontSize: 11)),
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

  Widget _paymentStatusBadge(AdminPaymentStatus s) {
    final (label, status) = switch (s) {
      AdminPaymentStatus.completed => ('Completed', BadgeStatus.completed),
      AdminPaymentStatus.pending   => ('Pending',   BadgeStatus.pending),
      AdminPaymentStatus.failed    => ('Failed',    BadgeStatus.cancelled),
      AdminPaymentStatus.refunded  => ('Refunded',  BadgeStatus.noShow),
      _                            => ('Unknown',   BadgeStatus.pending),
    };
    return StatusBadge(label: label, status: status);
  }
}

class _FilterBar extends StatelessWidget {
  final PaymentFilters filters;
  final ValueChanged<PaymentFilters> onChanged;
  const _FilterBar({required this.filters, required this.onChanged});

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
          // Status filter
          SizedBox(
            height: 36,
            child: DropdownButton<AdminPaymentStatus?>(
              value: filters.status,
              hint: const Text('All statuses', style: TextStyle(fontSize: 13)),
              style: AppTypography.bodySmall,
              underline: const SizedBox.shrink(),
              items: [
                const DropdownMenuItem(value: null, child: Text('All statuses')),
                ...AdminPaymentStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.label))),
              ],
              onChanged: (s) => onChanged(filters.copyWith(status: s)),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Method filter
          SizedBox(
            height: 36,
            child: DropdownButton<String?>(
              value: filters.method,
              hint: const Text('All methods', style: TextStyle(fontSize: 13)),
              style: AppTypography.bodySmall,
              underline: const SizedBox.shrink(),
              items: const [
                DropdownMenuItem(value: null, child: Text('All methods')),
                DropdownMenuItem(value: 'mobile_money', child: Text('Mobile Money')),
                DropdownMenuItem(value: 'card', child: Text('Card')),
                DropdownMenuItem(value: 'cash', child: Text('Cash')),
              ],
              onChanged: (m) => onChanged(filters.copyWith(method: m)),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentDetailDrawer extends StatelessWidget {
  final Payment payment;
  const _PaymentDetailDrawer({required this.payment});

  @override
  Widget build(BuildContext context) {
    final etb = NumberFormat('#,###.00');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
          _row('Reference', payment.ref),
          _row('Date', DateFormat('MMM d, yyyy HH:mm').format(payment.date)),
          _row('Patient', payment.patientName),
          _row('Doctor', payment.doctorName),
          _row('Amount', 'ETB ${etb.format(payment.amount)}'),
          _row('Method', payment.method.label),
          _row('Status', payment.status.label),
          if (payment.appointmentId != null) _row('Appointment ID', payment.appointmentId!),
          if (payment.notes != null) _row('Notes', payment.notes!),
          const SizedBox(height: AppSpacing.xl),
          if (payment.status == AdminPaymentStatus.failed)
            ElevatedButton.icon(
              onPressed: () {
                context.read<PaymentsLedgerBloc>().add(PaymentResolveRequested(payment.id));
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.check, size: 16),
              label: const Text('Mark as Resolved'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
            ),
      ],
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 130, child: Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.neutral500))),
        Expanded(child: Text(value, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600))),
      ],
    ),
  );
}
