import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/di/service_locator.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/data_table/app_data_table.dart';
import '../../../../../core/widgets/dialogs/confirm_dialog.dart';
import '../../../../../core/widgets/shell/page_header.dart';
import '../../../domain/entities/platform_doctor.dart';
import '../../bloc/doctors/platform_doctors_bloc.dart';

class PlatformDoctorsPage extends StatelessWidget {
  const PlatformDoctorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PlatformDoctorsBloc>()..add(const PlatformDoctorsStarted()),
      child: const _DoctorsView(),
    );
  }
}

class _DoctorsView extends StatelessWidget {
  const _DoctorsView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlatformDoctorsBloc, PlatformDoctorsState>(
      listener: (ctx, state) {
        if (state is PlatformDoctorsActionSuccess) {
          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(state.message)));
        }
        if (state is PlatformDoctorsActionError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.danger),
          );
        }
      },
      child: Column(
        children: [
          PageHeader(
            title: 'Doctors',
            subtitle: 'Platform-wide doctor management',
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, size: 18),
                onPressed: () => context.read<PlatformDoctorsBloc>().add(const PlatformDoctorsRefreshed()),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          Expanded(
            child: BlocBuilder<PlatformDoctorsBloc, PlatformDoctorsState>(
              builder: (ctx, state) {
                final doctors = state is PlatformDoctorsLoaded ? state.doctors : <PlatformDoctor>[];
                final total = state is PlatformDoctorsLoaded ? state.total : 0;
                final page = state is PlatformDoctorsLoaded ? state.page : 1;
                const pageSize = 20;
                final isLoading = state is PlatformDoctorsLoading;

                return AppDataTable<PlatformDoctor>(
                  rows: doctors,
                  isLoading: isLoading,
                  selectable: false,
                  emptyMessage: 'No doctors found',
                  pagination: PaginationConfig(
                    page: page,
                    pageSize: pageSize,
                    total: total,
                    onPageChanged: (p) => ctx.read<PlatformDoctorsBloc>().add(PlatformDoctorsPageChanged(p)),
                    onPageSizeChanged: (_) {},
                  ),
                  rowActionsBuilder: (doctor) => _DoctorActions(doctor: doctor),
                  columns: [
                    DataTableColumn(
                      label: 'Name',
                      builder: (d) => Text(d.fullName, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                    ),
                    DataTableColumn(
                      label: 'Specialization',
                      builder: (d) => Text(d.specialization, style: AppTypography.bodySmall),
                    ),
                    DataTableColumn(
                      label: 'License',
                      width: 120,
                      builder: (d) => Text(d.licenseNumber, style: AppTypography.caption.copyWith(color: AppColors.neutral500)),
                    ),
                    DataTableColumn(
                      label: 'Verified',
                      width: 90,
                      builder: (d) => Row(
                        children: [
                          Icon(
                            d.licenseVerified ? Icons.verified : Icons.pending_outlined,
                            size: 16,
                            color: d.licenseVerified ? AppColors.success : AppColors.warning,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            d.licenseVerified ? 'Yes' : 'No',
                            style: AppTypography.caption.copyWith(
                              color: d.licenseVerified ? AppColors.success : AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DataTableColumn(
                      label: 'Centers',
                      width: 70,
                      builder: (d) => Text('${d.affiliatedCentersCount}', style: AppTypography.bodySmall),
                    ),
                    DataTableColumn(
                      label: 'Status',
                      width: 90,
                      builder: (d) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: (d.status == 'active' ? AppColors.success : AppColors.danger).withAlpha(20),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          d.status,
                          style: TextStyle(
                            fontSize: 11,
                            color: d.status == 'active' ? AppColors.success : AppColors.danger,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    DataTableColumn(
                      label: 'Created',
                      width: 100,
                      builder: (d) => Text(
                        DateFormat('MMM d, y').format(d.createdAt),
                        style: AppTypography.caption.copyWith(color: AppColors.neutral500),
                      ),
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

class _DoctorActions extends StatelessWidget {
  final PlatformDoctor doctor;
  const _DoctorActions({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 18),
      itemBuilder: (_) => [
        if (!doctor.licenseVerified)
          const PopupMenuItem(value: 'verify', child: Text('Verify License')),
        if (doctor.status == 'active')
          const PopupMenuItem(value: 'suspend', child: Text('Suspend')),
      ],
      onSelected: (action) async {
        switch (action) {
          case 'verify':
            final confirmed = await ConfirmDialog.show(
              context,
              title: 'Verify License',
              message: 'Verify license for Dr. ${doctor.fullName}?',
              confirmLabel: 'Verify',
            );
            if (confirmed && context.mounted) {
              context.read<PlatformDoctorsBloc>().add(DoctorVerifyLicenseRequested(doctor.id));
            }
          case 'suspend':
            final confirmed = await ConfirmDialog.show(
              context,
              title: 'Suspend Doctor',
              message: 'Suspend Dr. ${doctor.fullName}?',
              confirmLabel: 'Suspend',
              isDangerous: true,
            );
            if (confirmed && context.mounted) {
              context.read<PlatformDoctorsBloc>().add(DoctorSuspendRequested(doctor.id, 'Suspended by admin'));
            }
        }
      },
    );
  }
}
