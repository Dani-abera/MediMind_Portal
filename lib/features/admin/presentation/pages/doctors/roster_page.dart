import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../../core/di/service_locator.dart';
import '../../../../../core/network/user_context.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/buttons/app_button.dart';
import '../../../../../core/widgets/data_table/app_data_table.dart';
import '../../../../../core/widgets/dialogs/confirm_dialog.dart';
import '../../../../../core/widgets/shell/page_header.dart';
import '../../../../../core/widgets/status_badges/status_badge.dart';
import '../../../domain/entities/doctor_at_center.dart';
import '../../bloc/doctors_roster/doctors_roster_bloc.dart';
import '../../widgets/add_doctor_dialog.dart';
import '../../widgets/configure_schedule_modal.dart';

class DoctorsRosterPage extends StatelessWidget {
  const DoctorsRosterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DoctorsRosterBloc>()
        ..add(DoctorsRosterStarted(UserContext().centerId ?? '')),
      child: const _DoctorsRosterView(),
    );
  }
}

class _DoctorsRosterView extends StatelessWidget {
  const _DoctorsRosterView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<DoctorsRosterBloc, DoctorsRosterState>(
      listener: (ctx, state) {
        if (state is DoctorsRosterError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.danger),
          );
        } else if (state is DoctorsRosterActionSuccess) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.success),
          );
        } else if (state is DoctorScheduleLoaded) {
          final bloc = ctx.read<DoctorsRosterBloc>();
          ConfigureScheduleModal.show(ctx, config: state.config, onSave: (config) {
            bloc.add(DoctorScheduleConfigured(config));
          });
        }
      },
      child: Column(
        children: [
          PageHeader(
            title: 'Doctors',
            subtitle: 'Manage doctors affiliated with this center',
            actions: [
              AppButton.primary(
                label: 'Add Doctor',
                icon: FontAwesomeIcons.userPlus,
                onPressed: () => AddDoctorDialog.show(context),
              ),
              const SizedBox(width: AppSpacing.sm),
              IconButton(
                icon: const Icon(Icons.refresh, size: 18),
                tooltip: 'Refresh',
                onPressed: () => context.read<DoctorsRosterBloc>().add(const DoctorsRosterRefreshed()),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          Expanded(child: _DoctorsTable()),
        ],
      ),
    );
  }
}

class _DoctorsTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DoctorsRosterBloc, DoctorsRosterState>(
      builder: (ctx, state) {
        final doctors = state is DoctorsRosterLoaded ? state.doctors : <DoctorAtCenter>[];
        final isLoading = state is DoctorsRosterLoading || state is DoctorsRosterInitial || state is DoctorsRosterActionInProgress;

        return AppDataTable<DoctorAtCenter>(
          rows: doctors,
          isLoading: isLoading,
          emptyMessage: 'No doctors in this center',
          selectable: false,
          columns: [
            DataTableColumn(
              label: 'Doctor',
              builder: (d) => Row(
                children: [
                  _avatar(d),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(d.fullName,
                            style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis),
                        if (d.specialization != null)
                          Text(d.specialization!,
                              style: AppTypography.caption.copyWith(color: AppColors.neutral500),
                              overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            DataTableColumn(
              label: 'License',
              width: 130,
              builder: (d) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(d.licenseNumber,
                      style: AppTypography.bodySmall.copyWith(fontFamily: 'RobotoMono')),
                  const SizedBox(width: 4),
                  if (d.licenseVerified)
                    const Icon(Icons.verified, size: 14, color: AppColors.success),
                ],
              ),
            ),
            DataTableColumn(
              label: 'Status',
              width: 90,
              builder: (d) => d.status == DoctorStatus.active
                  ? const StatusBadge(label: 'Active', status: BadgeStatus.active)
                  : const StatusBadge(label: 'Inactive', status: BadgeStatus.suspended),
            ),
            DataTableColumn(
              label: "Today's Appts",
              width: 110,
              builder: (d) => Text(
                '${d.todayAppointments}',
                style: AppTypography.bodySmall.copyWith(color: AppColors.neutral600),
              ),
            ),
            DataTableColumn(
              label: 'Fee (ETB)',
              width: 90,
              builder: (d) => Text(
                d.consultationFeeEtb > 0 ? d.consultationFeeEtb.toStringAsFixed(0) : '—',
                style: AppTypography.bodySmall,
              ),
            ),
            DataTableColumn(
              label: 'Joined',
              width: 100,
              builder: (d) => Text(
                DateFormat('MMM d, yyyy').format(d.joinedAt),
                style: AppTypography.caption.copyWith(color: AppColors.neutral500),
              ),
            ),
          ],
          rowActionsBuilder: (d) => _DoctorRowActions(doctor: d),
        );
      },
    );
  }

  Widget _avatar(DoctorAtCenter d) {
    if (d.avatarUrl != null) {
      return CircleAvatar(backgroundImage: NetworkImage(d.avatarUrl!), radius: 16);
    }
    final initials = d.fullName.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join();
    return CircleAvatar(
      radius: 16,
      backgroundColor: AppColors.primaryLight.withAlpha(80),
      child: Text(initials, style: AppTypography.caption.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)),
    );
  }
}

class _DoctorRowActions extends StatelessWidget {
  final DoctorAtCenter doctor;
  const _DoctorRowActions({required this.doctor});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<DoctorsRosterBloc>();
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 16, color: AppColors.neutral400),
      itemBuilder: (_) => [
        const PopupMenuItem(value: 'schedule', child: Text('Configure Schedule')),
        const PopupMenuItem(value: 'remove', child: Text('Remove from Center')),
      ],
      onSelected: (v) async {
        switch (v) {
          case 'schedule':
            bloc.add(DoctorScheduleRequested(doctor.doctorId));
          case 'remove':
            final ok = await ConfirmDialog.show(
              context,
              title: 'Remove Doctor',
              message: 'Remove ${doctor.fullName} from this center?',
              confirmLabel: 'Remove',
              isDangerous: true,
            );
            if (ok && context.mounted) {
              bloc.add(DoctorRemovedFromCenter(doctor.doctorId));
            }
        }
      },
    );
  }
}
