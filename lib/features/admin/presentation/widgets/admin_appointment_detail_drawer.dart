import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/dialogs/confirm_dialog.dart';
import '../../../../core/widgets/drawers/side_drawer.dart';
import '../../../../core/widgets/status_badges/status_badge.dart';
import '../../domain/entities/admin_appointment.dart';
import '../bloc/appointment_detail/admin_appointment_detail_bloc.dart';

class AdminAppointmentDetailDrawer {
  static void show(BuildContext context, {required String appointmentId}) {
    SideDrawer.show(
      context,
      title: 'Appointment Detail',
      width: AppSpacing.drawerWidthLg,
      body: BlocProvider(
        create: (_) => sl<AdminAppointmentDetailBloc>()
          ..add(AdminApptDetailStarted(appointmentId)),
        child: const _DrawerBody(),
      ),
    );
  }
}

class _DrawerBody extends StatelessWidget {
  const _DrawerBody();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminAppointmentDetailBloc, AdminApptDetailState>(
      listener: (ctx, state) {
        if (state is AdminApptDetailError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.danger),
          );
        } else if (state is AdminApptDetailActionSuccess) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(content: Text('Action completed'), backgroundColor: AppColors.success),
          );
          Navigator.of(ctx).pop();
        }
      },
      builder: (ctx, state) {
        if (state is AdminApptDetailLoading || state is AdminApptDetailInitial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AdminApptDetailError) {
          return Center(child: Text(state.message, style: AppTypography.body));
        }
        if (state is AdminApptDetailLoaded || state is AdminApptDetailActionInProgress) {
          final appt = state is AdminApptDetailLoaded
              ? (state as AdminApptDetailLoaded).appointment
              : (state as AdminApptDetailActionInProgress).appointment;
          final isBusy = state is AdminApptDetailActionInProgress;
          return _ApptDetailContent(appointment: appt, isBusy: isBusy);
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _ApptDetailContent extends StatelessWidget {
  final AdminAppointment appointment;
  final bool isBusy;
  const _ApptDetailContent({required this.appointment, required this.isBusy});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(context),
        const SizedBox(height: AppSpacing.xl),
        _sectionTitle('Patient & Appointment'),
        const SizedBox(height: AppSpacing.sm),
        _patientInfo(),
        const SizedBox(height: AppSpacing.xl),
        _sectionTitle('Payment'),
        const SizedBox(height: AppSpacing.sm),
        _paymentInfo(),
        const SizedBox(height: AppSpacing.xl),
        _sectionTitle('Status History'),
        const SizedBox(height: AppSpacing.sm),
        _statusTimeline(),
        const SizedBox(height: AppSpacing.xl),
        if (_showActions()) ...[
          _sectionTitle('Actions'),
          const SizedBox(height: AppSpacing.sm),
          _actions(context),
        ],
      ],
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(appointment.patientName,
                  style: AppTypography.h1),
              const SizedBox(height: 4),
              Text(
                '${appointment.doctorName}${appointment.doctorSpecialization != null ? ' · ${appointment.doctorSpecialization}' : ''}',
                style: AppTypography.bodySmall.copyWith(color: AppColors.neutral500),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _statusBadge(appointment.status),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('MMM d, yyyy · h:mm a').format(appointment.dateTime),
                    style: AppTypography.caption.copyWith(color: AppColors.neutral500),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _patientInfo() {
    return _InfoGrid(entries: [
      _InfoEntry('Patient', appointment.patientName),
      if (appointment.patientAge != null) _InfoEntry('Age', '${appointment.patientAge}'),
      if (appointment.patientPhone != null) _InfoEntry('Phone', appointment.patientPhone!),
      _InfoEntry('Doctor', appointment.doctorName),
      _InfoEntry('Date', DateFormat('EEEE, MMM d, yyyy').format(appointment.dateTime)),
      _InfoEntry('Time', DateFormat('h:mm a').format(appointment.dateTime)),
      _InfoEntry('Duration', '${appointment.durationMinutes} minutes'),
      _InfoEntry('Type', appointment.type == AppointmentType.video ? 'Video Call' : 'In-Person'),
      _InfoEntry('Reason', appointment.reason),
      if (appointment.queueNumber != null) _InfoEntry('Queue #', '${appointment.queueNumber}'),
      _InfoEntry('Booked By', appointment.bookedBy == BookingSource.admin ? 'Admin' : 'Patient'),
      _InfoEntry('Booked At', DateFormat('MMM d, yyyy h:mm a').format(appointment.bookedAt)),
    ]);
  }

  Widget _paymentInfo() {
    return _InfoGrid(entries: [
      _InfoEntry('Status', appointment.paymentStatus.label),
      if (appointment.paymentAmount != null)
        _InfoEntry('Amount', 'ETB ${appointment.paymentAmount!.toStringAsFixed(2)}'),
      if (appointment.paymentTransactionId != null)
        _InfoEntry('Transaction ID', appointment.paymentTransactionId!),
    ]);
  }

  Widget _statusTimeline() {
    if (appointment.statusHistory.isEmpty) {
      return Text('No status history', style: AppTypography.bodySmall.copyWith(color: AppColors.neutral400));
    }
    return Column(
      children: appointment.statusHistory.map((change) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                      color: _timelineColor(change.status),
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (change != appointment.statusHistory.last)
                    Container(width: 1, height: 28, color: AppColors.neutral200),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _statusBadge(change.status),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('MMM d, h:mm a').format(change.timestamp),
                          style: AppTypography.caption.copyWith(color: AppColors.neutral400),
                        ),
                      ],
                    ),
                    Text('by ${change.changedBy}',
                        style: AppTypography.caption.copyWith(color: AppColors.neutral500)),
                    if (change.reason != null)
                      Text(change.reason!,
                          style: AppTypography.caption.copyWith(color: AppColors.neutral600)),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  bool _showActions() =>
      appointment.status == AppointmentStatus.pending ||
      appointment.status == AppointmentStatus.confirmed;

  Widget _actions(BuildContext context) {
    final bloc = context.read<AdminAppointmentDetailBloc>();
    return Row(
      children: [
        if (appointment.status == AppointmentStatus.pending) ...[
          AppButton.primary(
            label: 'Approve',
            icon: FontAwesomeIcons.circleCheck,
            isLoading: isBusy,
            onPressed: () => bloc.add(const AdminApptApproved()),
          ),
          const SizedBox(width: AppSpacing.sm),
          AppButton.danger(
            label: 'Reject',
            isLoading: isBusy,
            onPressed: () async {
              final reason = await _showRejectReasonDialog(context);
              if (reason != null && context.mounted) {
                bloc.add(AdminApptRejected(reason: reason));
              }
            },
          ),
        ],
        if (appointment.status == AppointmentStatus.confirmed)
          AppButton.danger(
            label: 'Cancel',
            isLoading: isBusy,
            onPressed: () async {
              final ok = await ConfirmDialog.show(
                context,
                title: 'Cancel Appointment',
                message: 'Cancel this confirmed appointment?',
                confirmLabel: 'Cancel',
                isDangerous: true,
              );
              if (ok && context.mounted) bloc.add(const AdminApptCancelled());
            },
          ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: AppTypography.h3.copyWith(color: AppColors.neutral700));
  }

  Widget _statusBadge(AppointmentStatus s) => switch (s) {
    AppointmentStatus.pending => const StatusBadge(label: 'Pending', status: BadgeStatus.pending),
    AppointmentStatus.confirmed => const StatusBadge(label: 'Confirmed', status: BadgeStatus.confirmed),
    AppointmentStatus.inProgress => const StatusBadge(label: 'In Progress', status: BadgeStatus.inProgress),
    AppointmentStatus.completed => const StatusBadge(label: 'Completed', status: BadgeStatus.completed),
    AppointmentStatus.cancelled => const StatusBadge(label: 'Cancelled', status: BadgeStatus.cancelled),
    AppointmentStatus.noShow => const StatusBadge(label: 'No Show', status: BadgeStatus.noShow),
  };

  Color _timelineColor(AppointmentStatus s) => switch (s) {
    AppointmentStatus.confirmed => AppColors.info,
    AppointmentStatus.completed => AppColors.success,
    AppointmentStatus.cancelled => AppColors.danger,
    AppointmentStatus.noShow => AppColors.neutral400,
    _ => AppColors.warning,
  };
}

class _InfoEntry {
  final String label;
  final String value;
  const _InfoEntry(this.label, this.value);
}

class _InfoGrid extends StatelessWidget {
  final List<_InfoEntry> entries;
  const _InfoGrid({required this.entries});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: AppRadius.radiusBase,
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        children: entries.map((e) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 110,
                child: Text(e.label,
                    style: AppTypography.caption.copyWith(color: AppColors.neutral500)),
              ),
              Expanded(
                child: Text(e.value, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }
}

Future<String?> _showRejectReasonDialog(BuildContext context) {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: const Text('Reject Appointment'),
        content: SizedBox(
          width: 400,
          child: TextField(
            controller: controller,
            maxLines: 3,
            autofocus: true,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Reason for rejection',
              hintText: 'Enter a reason the patient will see',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: controller.text.trim().isEmpty
                ? null
                : () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('Reject', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ),
  );
}
