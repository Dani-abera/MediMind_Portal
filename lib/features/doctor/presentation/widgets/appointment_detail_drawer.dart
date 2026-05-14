import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/drawers/side_drawer.dart';
import '../../../../core/widgets/feedback/app_loading.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/entities/appointment_note.dart';
import '../bloc/appointment_detail/appointment_detail_bloc.dart';
import '../bloc/consultation/consultation_bloc.dart';

class AppointmentDetailDrawer extends StatelessWidget {
  final String appointmentId;
  const AppointmentDetailDrawer({super.key, required this.appointmentId});

  static Future<void> show(BuildContext context, String appointmentId) {
    return SideDrawer.show(
      context,
      title: 'Appointment Details',
      width: 520,
      body: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => sl<AppointmentDetailBloc>()
              ..add(AppointmentDetailStarted(appointmentId)),
          ),
          BlocProvider(create: (_) => sl<ConsultationBloc>()),
        ],
        child: AppointmentDetailDrawer(appointmentId: appointmentId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppointmentDetailBloc, AppointmentDetailState>(
      builder: (ctx, state) {
        if (state is AppointmentDetailLoading ||
            state is AppointmentDetailInitial) {
          return const Center(child: AppLoadingSpinner());
        }
        if (state is AppointmentDetailError) {
          return AppErrorState(message: state.message);
        }
        if (state is AppointmentDetailLoaded) {
          return _AppointmentDetailContent(
            appointment: state.appointment,
            notes: state.notes,
          );
        }
        if (state is AppointmentDetailActionSuccess) {
          return _AppointmentDetailContent(
            appointment: state.appointment,
            notes: const [],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _AppointmentDetailContent extends StatefulWidget {
  final Appointment appointment;
  final List<AppointmentNote> notes;
  const _AppointmentDetailContent({
    required this.appointment,
    required this.notes,
  });

  @override
  State<_AppointmentDetailContent> createState() =>
      _AppointmentDetailContentState();
}

class _AppointmentDetailContentState
    extends State<_AppointmentDetailContent> {
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appt = widget.appointment;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(
          'Patient',
          child: _buildPatientInfo(appt),
        ),
        _buildSection(
          'Appointment',
          child: _buildAppointmentInfo(appt),
        ),
        _buildSection(
          'Symptoms',
          child: appt.symptoms.isEmpty
              ? Text('None recorded',
                  style:
                      AppTypography.bodySmall.copyWith(color: AppColors.neutral400))
              : Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: appt.symptoms
                      .map((s) => Chip(
                            label: Text(s, style: const TextStyle(fontSize: 12)),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ))
                      .toList(),
                ),
        ),
        _buildSection(
          'Notes (${widget.notes.length})',
          child: _buildNotesSection(context),
        ),
        _buildSection(
          'Actions',
          child: _buildActions(context, appt),
        ),
      ],
    );
  }

  Widget _buildSection(String title, {required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.h3),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildPatientInfo(Appointment appt) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primaryLight,
            child: Text(
              appt.patientName.isNotEmpty ? appt.patientName[0] : '?',
              style: const TextStyle(
                  color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appt.patientName, style: AppTypography.h3),
                if (appt.patientAge != null)
                  Text('${appt.patientAge} years old',
                      style: AppTypography.bodySmall
                          .copyWith(color: AppColors.neutral500)),
                if (appt.patientPhone != null)
                  Text(appt.patientPhone!,
                      style: AppTypography.bodySmall
                          .copyWith(color: AppColors.neutral500)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: appt.type == AppointmentType.video
                  ? AppColors.info.withAlpha(20)
                  : AppColors.neutral200,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              appt.type == AppointmentType.video ? 'Video' : 'In-Person',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: appt.type == AppointmentType.video
                    ? AppColors.info
                    : AppColors.neutral600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentInfo(Appointment appt) {
    return Column(
      children: [
        _infoRow(
            'Date & Time', DateFormat('MMMM d, y — HH:mm').format(appt.dateTime)),
        _infoRow('Center', appt.centerName),
        _infoRow('Reason', appt.reason),
        _infoRow('Status', appt.status.label),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.neutral500)),
          ),
          Expanded(
              child: Text(value,
                  style: AppTypography.body)),
        ],
      ),
    );
  }

  Widget _buildNotesSection(BuildContext ctx) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.notes.isEmpty)
          Text('No notes yet.',
              style:
                  AppTypography.bodySmall.copyWith(color: AppColors.neutral400))
        else
          ...widget.notes.map((note) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.neutral50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.neutral200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(note.content, style: AppTypography.body),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM d, y HH:mm').format(note.createdAt),
                      style: AppTypography.caption
                          .copyWith(color: AppColors.neutral400),
                    ),
                  ],
                ),
              )),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _noteController,
                decoration: const InputDecoration(
                  hintText: 'Add a note...',
                  isDense: true,
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
                maxLines: 2,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.paperPlane, size: 15),
              color: AppColors.primary,
              onPressed: () {
                final content = _noteController.text.trim();
                if (content.isEmpty) return;
                ctx
                    .read<AppointmentDetailBloc>()
                    .add(AppointmentNoteAdded(content));
                _noteController.clear();
              },
            ),
          ],
        ),
      ],
    );
  }

  void _initiateAndNavigate(BuildContext ctx, String appointmentId) {
    ctx.read<ConsultationBloc>().add(ConsultationInitiated(appointmentId));
    ctx.read<ConsultationBloc>().stream.firstWhere(
      (s) => s is ConsultationInitiateSuccess || s is ConsultationError,
    ).then((s) {
      if (!mounted) return;
      if (s is ConsultationInitiateSuccess) {
        Navigator.of(context).pop();
        context.go('/doctor/video-call/${s.consultation.id}');
      } else if (s is ConsultationError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(s.message),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    });
  }

  Widget _buildActions(BuildContext ctx, Appointment appt) {
    final canComplete = appt.status == AppointmentStatus.confirmed ||
        appt.status == AppointmentStatus.inProgress;
    final canCancel = appt.status == AppointmentStatus.pending ||
        appt.status == AppointmentStatus.confirmed;

    return Row(
      children: [
        if (canComplete)
          FilledButton.icon(
            icon: const FaIcon(FontAwesomeIcons.circleCheck, size: 14),
            label: const Text('Mark Complete'),
            onPressed: () =>
                ctx.read<AppointmentDetailBloc>().add(const AppointmentCompleted()),
          ),
        if (canComplete && canCancel) const SizedBox(width: 8),
        if (canCancel)
          OutlinedButton.icon(
            icon: const FaIcon(FontAwesomeIcons.ban, size: 14,
                color: AppColors.danger),
            label: const Text('Cancel',
                style: TextStyle(color: AppColors.danger)),
            onPressed: () =>
                ctx.read<AppointmentDetailBloc>().add(const AppointmentCancelled()),
          ),
        if (appt.type == AppointmentType.video &&
            (appt.status == AppointmentStatus.confirmed ||
                appt.status == AppointmentStatus.inProgress) &&
            appt.videoConsultationId == null) ...[
          const SizedBox(width: 8),
          FilledButton.icon(
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.info),
            icon: const FaIcon(FontAwesomeIcons.video, size: 14),
            label: const Text('Start Video Call'),
            onPressed: () => _initiateAndNavigate(ctx, appt.id),
          ),
        ],
        if (appt.type == AppointmentType.video &&
            appt.videoConsultationId != null) ...[
          const Spacer(),
          FilledButton.icon(
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.info),
            icon: const FaIcon(FontAwesomeIcons.video, size: 14),
            label: const Text('Join Video Call'),
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/doctor/video-call/${appt.videoConsultationId}');
            },
          ),
        ],
      ],
    );
  }
}
