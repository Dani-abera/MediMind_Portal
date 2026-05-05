import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../../core/di/service_locator.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/buttons/app_button.dart';
import '../../../../../core/widgets/data_table/app_data_table.dart';
import '../../../../../core/widgets/dialogs/confirm_dialog.dart';
import '../../../../../core/widgets/shell/page_header.dart';
import '../../../../../core/widgets/status_badges/status_badge.dart';
import '../../../domain/entities/admin_appointment.dart';
import '../../bloc/pending_appointments/pending_appointments_bloc.dart';
import '../../widgets/admin_appointment_detail_drawer.dart';

class PendingAppointmentsPage extends StatelessWidget {
  const PendingAppointmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PendingAppointmentsBloc>()..add(const PendingApptsStarted()),
      child: const _PendingView(),
    );
  }
}

class _PendingView extends StatefulWidget {
  const _PendingView();

  @override
  State<_PendingView> createState() => _PendingViewState();
}

class _PendingViewState extends State<_PendingView> {
  List<AdminAppointment> _selected = [];

  @override
  Widget build(BuildContext context) {
    return BlocListener<PendingAppointmentsBloc, PendingAppointmentsState>(
      listener: (ctx, state) {
        if (state is PendingApptsError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.danger),
          );
        } else if (state is PendingApptsActionSuccess) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.success),
          );
          setState(() => _selected = []);
        }
      },
      child: Column(
        children: [
          _buildHeader(context),
          if (_selected.isNotEmpty) _buildBulkBar(context),
          Expanded(child: _buildTable(context)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final bloc = context.read<PendingAppointmentsBloc>();
    return PageHeader(
      title: 'Pending Appointments',
      subtitle: 'Review and approve incoming requests',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, size: 18),
          tooltip: 'Refresh',
          onPressed: () => bloc.add(const PendingApptsRefreshed()),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }

  Widget _buildBulkBar(BuildContext context) {
    final bloc = context.read<PendingAppointmentsBloc>();
    return Container(
      color: AppColors.primaryLight.withAlpha(40),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
      child: Row(
        children: [
          Text(
            '${_selected.length} selected',
            style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.base),
          AppButton.primary(
            label: 'Approve All',
            icon: FontAwesomeIcons.circleCheck,
            onPressed: () {
              bloc.add(PendingSelectionChanged(_selected.map((a) => a.id).toList()));
              bloc.add(const PendingBulkApproved());
            },
          ),
          const SizedBox(width: AppSpacing.sm),
          AppButton.danger(
            label: 'Reject All',
            icon: FontAwesomeIcons.circleXmark,
            onPressed: () async {
              final ok = await ConfirmDialog.show(
                context,
                title: 'Reject ${_selected.length} Appointments',
                message: 'Are you sure? This action cannot be undone.',
                confirmLabel: 'Reject All',
                isDangerous: true,
              );
              if (ok && context.mounted) {
                bloc.add(PendingSelectionChanged(_selected.map((a) => a.id).toList()));
                bloc.add(const PendingBulkRejected());
              }
            },
          ),
          const SizedBox(width: AppSpacing.sm),
          AppButton.text(
            label: 'Clear',
            onPressed: () => setState(() => _selected = []),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(BuildContext context) {
    return BlocBuilder<PendingAppointmentsBloc, PendingAppointmentsState>(
      builder: (ctx, state) {
        final appointments = state is PendingApptsLoaded ? state.appointments : <AdminAppointment>[];
        final isLoading = state is PendingApptsLoading || state is PendingApptsInitial || state is PendingApptsActionInProgress;

        return AppDataTable<AdminAppointment>(
          rows: appointments,
          isLoading: isLoading,
          emptyMessage: 'No pending appointments',
          selectable: true,
          onSelectionChanged: (rows) => setState(() => _selected = rows),
          onRowTap: (appt) => AdminAppointmentDetailDrawer.show(context, appointmentId: appt.id),
          columns: [
            DataTableColumn(
              label: 'Patient',
              builder: (a) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(a.patientName,
                      style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis),
                  if (a.patientAge != null)
                    Text('Age ${a.patientAge}',
                        style: AppTypography.caption.copyWith(color: AppColors.neutral500)),
                ],
              ),
            ),
            DataTableColumn(
              label: 'Doctor',
              builder: (a) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(a.doctorName,
                      style: AppTypography.bodySmall,
                      overflow: TextOverflow.ellipsis),
                  if (a.doctorSpecialization != null)
                    Text(a.doctorSpecialization!,
                        style: AppTypography.caption.copyWith(color: AppColors.neutral400),
                        overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            DataTableColumn(
              label: 'Date & Time',
              width: 140,
              builder: (a) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(DateFormat('MMM d, yyyy').format(a.dateTime),
                      style: AppTypography.bodySmall),
                  Text(DateFormat('h:mm a').format(a.dateTime),
                      style: AppTypography.caption.copyWith(color: AppColors.neutral500)),
                ],
              ),
            ),
            DataTableColumn(
              label: 'Reason',
              builder: (a) => Text(a.reason,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.neutral600),
                  overflow: TextOverflow.ellipsis),
            ),
            DataTableColumn(
              label: 'Booked',
              width: 100,
              builder: (a) => Text(
                DateFormat('MMM d').format(a.bookedAt),
                style: AppTypography.caption.copyWith(color: AppColors.neutral500),
              ),
            ),
            DataTableColumn(
              label: 'Payment',
              width: 90,
              builder: (a) => _paymentBadge(a.paymentStatus),
            ),
          ],
          rowActionsBuilder: (a) => _RowActions(appointment: a),
        );
      },
    );
  }

  Widget _paymentBadge(PaymentStatus s) {
    return switch (s) {
      PaymentStatus.paid => const StatusBadge(label: 'Paid', status: BadgeStatus.completed),
      PaymentStatus.pending => const StatusBadge(label: 'Pending', status: BadgeStatus.pending),
      PaymentStatus.failed => const StatusBadge(label: 'Failed', status: BadgeStatus.cancelled),
      PaymentStatus.none => const StatusBadge(label: 'None', status: BadgeStatus.expired),
    };
  }
}

class _RowActions extends StatelessWidget {
  final AdminAppointment appointment;
  const _RowActions({required this.appointment});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PendingAppointmentsBloc>();
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 16, color: AppColors.neutral400),
      itemBuilder: (_) => [
        const PopupMenuItem(value: 'approve', child: Text('Approve')),
        const PopupMenuItem(value: 'reject', child: Text('Reject')),
        const PopupMenuItem(value: 'view', child: Text('View Details')),
      ],
      onSelected: (v) async {
        switch (v) {
          case 'approve':
            bloc.add(PendingApptApproved(appointment.id));
          case 'reject':
            final ok = await ConfirmDialog.show(
              context,
              title: 'Reject Appointment',
              message: 'Reject appointment for ${appointment.patientName}?',
              confirmLabel: 'Reject',
              isDangerous: true,
            );
            if (ok && context.mounted) {
              bloc.add(PendingApptRejected(appointment.id));
            }
          case 'view':
            AdminAppointmentDetailDrawer.show(context, appointmentId: appointment.id);
        }
      },
    );
  }
}
