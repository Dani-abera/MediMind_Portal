import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/di/service_locator.dart';
import '../../../../../core/network/user_context.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/shell/page_header.dart';
import '../../../../../core/widgets/status_badges/status_badge.dart';
import '../../../domain/entities/admin_appointment.dart';
import '../../../domain/entities/patient_at_center.dart';
import '../../bloc/patient_detail/patient_center_detail_bloc.dart';
import '../../widgets/admin_appointment_detail_drawer.dart';

class AdminPatientDetailPage extends StatelessWidget {
  final String patientId;
  const AdminPatientDetailPage({super.key, required this.patientId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PatientCenterDetailBloc>()
        ..add(PatientCenterDetailStarted(
          centerId: UserContext().centerId ?? '',
          patientId: patientId,
        )),
      child: const _PatientDetailView(),
    );
  }
}

class _PatientDetailView extends StatelessWidget {
  const _PatientDetailView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PageHeader(
          title: 'Patient Detail',
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, size: 18),
            onPressed: () => Navigator.of(context).pop(),
            visualDensity: VisualDensity.compact,
          ),
        ),
        Expanded(
          child: BlocBuilder<PatientCenterDetailBloc, PatientCenterDetailState>(
            builder: (ctx, state) {
              if (state is PatientCenterDetailLoading || state is PatientCenterDetailInitial) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is PatientCenterDetailError) {
                return Center(child: Text(state.message, style: AppTypography.body));
              }
              if (state is PatientCenterDetailLoaded) {
                return _DetailBody(detail: state.detail);
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}

class _DetailBody extends StatelessWidget {
  final PatientCenterDetail detail;
  const _DetailBody({required this.detail});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProfileCard(patient: detail.patient),
          const SizedBox(height: AppSpacing.xl),
          _AppointmentsSection(appointments: detail.appointments),
          const SizedBox(height: AppSpacing.xl),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _PaymentsSection(payments: detail.payments)),
              const SizedBox(width: AppSpacing.xl),
              Expanded(child: _PrescriptionsSection(prescriptions: detail.prescriptions)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final PatientAtCenter patient;
  const _ProfileCard({required this.patient});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppRadius.radiusBase,
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.primaryLight.withAlpha(80),
            child: Text(
              patient.fullName.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join(),
              style: AppTypography.h2.copyWith(color: AppColors.primary),
            ),
          ),
          const SizedBox(width: AppSpacing.xl),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(patient.fullName, style: AppTypography.h1),
                const SizedBox(height: 6),
                Wrap(
                  spacing: AppSpacing.xl,
                  runSpacing: 4,
                  children: [
                    if (patient.age != null)
                      _Chip(icon: Icons.cake_outlined, label: 'Age ${patient.age}'),
                    if (patient.gender != null)
                      _Chip(icon: Icons.person_outline, label: patient.gender!.label),
                    if (patient.phone != null)
                      _Chip(icon: Icons.phone_outlined, label: patient.phone!),
                    if (patient.email != null)
                      _Chip(icon: Icons.email_outlined, label: patient.email!),
                  ],
                ),
                const SizedBox(height: AppSpacing.base),
                Row(
                  children: [
                    _StatBadge(label: 'Total Visits', value: '${patient.totalAppointments}'),
                    const SizedBox(width: AppSpacing.base),
                    _StatBadge(
                      label: 'Total Spent',
                      value: patient.totalSpentEtb > 0
                          ? 'ETB ${patient.totalSpentEtb.toStringAsFixed(0)}'
                          : '—',
                    ),
                    if (patient.firstVisit != null) ...[
                      const SizedBox(width: AppSpacing.base),
                      _StatBadge(
                        label: 'First Visit',
                        value: DateFormat('MMM d, yyyy').format(patient.firstVisit!),
                      ),
                    ],
                    if (patient.lastVisit != null) ...[
                      const SizedBox(width: AppSpacing.base),
                      _StatBadge(
                        label: 'Last Visit',
                        value: DateFormat('MMM d, yyyy').format(patient.lastVisit!),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.neutral400),
        const SizedBox(width: 4),
        Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.neutral600)),
      ],
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  const _StatBadge({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: AppRadius.radiusBase,
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
              style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)),
          Text(label, style: AppTypography.caption.copyWith(color: AppColors.neutral500, fontSize: 10)),
        ],
      ),
    );
  }
}

class _AppointmentsSection extends StatelessWidget {
  final List<AdminAppointment> appointments;
  const _AppointmentsSection({required this.appointments});

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Appointments (${appointments.length})',
      child: appointments.isEmpty
          ? Text('No appointments', style: AppTypography.bodySmall.copyWith(color: AppColors.neutral400))
          : Column(
              children: appointments.take(10).map((a) => _AppointmentRow(appt: a)).toList(),
            ),
    );
  }
}

class _AppointmentRow extends StatelessWidget {
  final AdminAppointment appt;
  const _AppointmentRow({required this.appt});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => AdminAppointmentDetailDrawer.show(context, appointmentId: appt.id),
      borderRadius: AppRadius.radiusBase,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(appt.doctorName, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                  Text(appt.reason, style: AppTypography.caption.copyWith(color: AppColors.neutral500)),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              DateFormat('MMM d, yyyy').format(appt.dateTime),
              style: AppTypography.caption.copyWith(color: AppColors.neutral500),
            ),
            const SizedBox(width: AppSpacing.sm),
            _statusBadge(appt.status),
          ],
        ),
      ),
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
}

class _PaymentsSection extends StatelessWidget {
  final List<PaymentRecord> payments;
  const _PaymentsSection({required this.payments});

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Payments (${payments.length})',
      child: payments.isEmpty
          ? Text('No payments', style: AppTypography.bodySmall.copyWith(color: AppColors.neutral400))
          : Column(
              children: payments.take(5).map((p) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(DateFormat('MMM d, yyyy').format(p.date),
                          style: AppTypography.bodySmall),
                    ),
                    Text('ETB ${p.amount.toStringAsFixed(0)}',
                        style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: p.status.toLowerCase() == 'paid'
                            ? AppColors.success.withAlpha(20)
                            : AppColors.warning.withAlpha(20),
                        borderRadius: AppRadius.radiusFull,
                      ),
                      child: Text(
                        p.status,
                        style: AppTypography.caption.copyWith(
                          fontSize: 10,
                          color: p.status.toLowerCase() == 'paid' ? AppColors.success : AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
    );
  }
}

class _PrescriptionsSection extends StatelessWidget {
  final List<PrescriptionRecord> prescriptions;
  const _PrescriptionsSection({required this.prescriptions});

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Prescriptions (${prescriptions.length})',
      child: prescriptions.isEmpty
          ? Text('No prescriptions', style: AppTypography.bodySmall.copyWith(color: AppColors.neutral400))
          : Column(
              children: prescriptions.take(5).map((p) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.doctorName, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                          Text('${p.medicationCount} medication${p.medicationCount != 1 ? 's' : ''}',
                              style: AppTypography.caption.copyWith(color: AppColors.neutral500)),
                        ],
                      ),
                    ),
                    Text(DateFormat('MMM d, yyyy').format(p.date),
                        style: AppTypography.caption.copyWith(color: AppColors.neutral500)),
                  ],
                ),
              )).toList(),
            ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppRadius.radiusBase,
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.h3),
          const SizedBox(height: AppSpacing.sm),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }
}
