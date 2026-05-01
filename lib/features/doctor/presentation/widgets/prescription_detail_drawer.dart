import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/drawers/side_drawer.dart';
import '../../../../core/widgets/feedback/app_loading.dart';
import '../../../../core/widgets/status_badges/status_badge.dart';
import '../../domain/entities/medication.dart';
import '../../domain/entities/prescription.dart';
import '../bloc/prescription_detail/prescription_detail_bloc.dart';

class PrescriptionDetailDrawer extends StatelessWidget {
  final String prescriptionId;
  const PrescriptionDetailDrawer({super.key, required this.prescriptionId});

  static Future<void> show(BuildContext context, String prescriptionId) {
    return SideDrawer.show(
      context,
      title: 'Prescription Details',
      width: 520,
      body: BlocProvider(
        create: (_) => sl<PrescriptionDetailBloc>()
          ..add(PrescriptionDetailStarted(prescriptionId)),
        child: PrescriptionDetailDrawer(prescriptionId: prescriptionId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrescriptionDetailBloc, PrescriptionDetailState>(
      builder: (ctx, state) {
        if (state is PrescriptionDetailLoading ||
            state is PrescriptionDetailInitial) {
          return const Center(child: AppLoadingSpinner());
        }
        if (state is PrescriptionDetailError) {
          return AppErrorState(message: state.message);
        }

        final prescription = state is PrescriptionDetailLoaded
            ? state.prescription
            : state is PrescriptionDetailActionSuccess
                ? state.prescription
                : null;
        final pdfUrl = state is PrescriptionDetailLoaded ? state.pdfUrl : null;

        if (prescription == null) return const SizedBox.shrink();

        return _PrescriptionContent(
          prescription: prescription,
          pdfUrl: pdfUrl,
        );
      },
    );
  }
}

class _PrescriptionContent extends StatelessWidget {
  final Prescription prescription;
  final String? pdfUrl;

  const _PrescriptionContent({
    required this.prescription,
    this.pdfUrl,
  });

  @override
  Widget build(BuildContext context) {
    final rx = prescription;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context, rx),
        const SizedBox(height: AppSpacing.xl),
        Text('Medications', style: AppTypography.h3),
        const SizedBox(height: 12),
        ...rx.medications.map((m) => _MedicationTile(medication: m)),
        if (rx.labTests.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xl),
          Text('Lab Tests', style: AppTypography.h3),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: rx.labTests
                .map((t) => Chip(
                      label: Text(t, style: const TextStyle(fontSize: 12)),
                      backgroundColor: AppColors.info.withAlpha(10),
                    ))
                .toList(),
          ),
        ],
        if (rx.followUpInstructions != null) ...[
          const SizedBox(height: AppSpacing.xl),
          Text('Follow-up Instructions', style: AppTypography.h3),
          const SizedBox(height: 8),
          Text(rx.followUpInstructions!, style: AppTypography.body),
        ],
        const SizedBox(height: AppSpacing.xl),
        _buildActions(context, rx),
        if (pdfUrl != null) ...[
          const SizedBox(height: AppSpacing.xl),
          Text('PDF Preview', style: AppTypography.h3),
          const SizedBox(height: 12),
          SizedBox(
            height: 400,
            child: SfPdfViewer.network(pdfUrl!),
          ),
        ],
      ],
    );
  }

  Widget _buildHeader(BuildContext context, Prescription rx) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(rx.patientName, style: AppTypography.h3),
                    Text(rx.diagnosis,
                        style: AppTypography.bodySmall
                            .copyWith(color: AppColors.neutral600)),
                  ],
                ),
              ),
              StatusBadge(
                label: rx.status.label,
                status: _mapStatus(rx.status),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              FaIcon(FontAwesomeIcons.calendar,
                  size: 12, color: AppColors.neutral400),
              const SizedBox(width: 6),
              Text(
                'Issued ${DateFormat('MMM d, y').format(rx.issuedAt)}',
                style: AppTypography.caption
                    .copyWith(color: AppColors.neutral500),
              ),
              const SizedBox(width: 16),
              FaIcon(FontAwesomeIcons.clockRotateLeft,
                  size: 12, color: AppColors.neutral400),
              const SizedBox(width: 6),
              Text(
                'Expires ${DateFormat('MMM d, y').format(rx.expiresAt)}',
                style: AppTypography.caption
                    .copyWith(color: AppColors.neutral500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext ctx, Prescription rx) {
    return Row(
      children: [
        if (rx.status == PrescriptionStatus.active) ...[
          OutlinedButton.icon(
            icon: const FaIcon(FontAwesomeIcons.ban,
                size: 13, color: AppColors.danger),
            label: const Text('Revoke',
                style: TextStyle(color: AppColors.danger)),
            onPressed: () => _showRevokeDialog(ctx),
          ),
        ],
      ],
    );
  }

  void _showRevokeDialog(BuildContext ctx) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Revoke Prescription'),
        content: TextField(
          controller: reasonCtrl,
          decoration: const InputDecoration(
            labelText: 'Reason for revocation',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final reason = reasonCtrl.text.trim();
              if (reason.isEmpty) return;
              ctx
                  .read<PrescriptionDetailBloc>()
                  .add(PrescriptionRevoked(reason));
              Navigator.of(dialogCtx).pop();
            },
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.danger),
            child: const Text('Revoke'),
          ),
        ],
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

class _MedicationTile extends StatelessWidget {
  final Medication medication;
  const _MedicationTile({required this.medication});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.neutral200),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          const FaIcon(FontAwesomeIcons.pills,
              size: 14, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(medication.name, style: AppTypography.bodyMedium),
                Text(
                  '${medication.dosage} · ${medication.frequencyLabel} · ${medication.duration}',
                  style: AppTypography.caption
                      .copyWith(color: AppColors.neutral500),
                ),
                if (medication.instructions != null)
                  Text(medication.instructions!,
                      style: AppTypography.caption
                          .copyWith(color: AppColors.neutral400)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
