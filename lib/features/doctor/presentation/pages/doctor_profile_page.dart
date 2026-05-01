import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/feedback/app_loading.dart';
import '../../../../core/widgets/shell/page_header.dart';
import '../../domain/entities/doctor_profile.dart';
import '../bloc/profile/profile_bloc.dart';

class DoctorProfilePage extends StatelessWidget {
  const DoctorProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProfileBloc>()..add(const ProfileStarted()),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PageHeader(
          title: 'My Profile',
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, size: 18),
              onPressed: () =>
                  context.read<ProfileBloc>().add(const ProfileRefreshed()),
            ),
          ],
        ),
        Expanded(
          child: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (ctx, state) {
              if (state is ProfileLoading || state is ProfileInitial) {
                return const Center(child: AppLoadingSpinner());
              }
              if (state is ProfileError) {
                return AppErrorState(
                  message: state.message,
                  onRetry: () =>
                      ctx.read<ProfileBloc>().add(const ProfileRefreshed()),
                );
              }
              if (state is ProfileLoaded) {
                return _ProfileContent(profile: state.profile);
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final DoctorProfile profile;
  const _ProfileContent({required this.profile});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 280, child: _buildLeftPanel(context)),
          const SizedBox(width: 24),
          Expanded(child: _buildRightPanel(context)),
        ],
      ),
    );
  }

  Widget _buildLeftPanel(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.neutral200),
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.primaryLight,
                backgroundImage: profile.avatarUrl != null
                    ? NetworkImage(profile.avatarUrl!)
                    : null,
                child: profile.avatarUrl == null
                    ? Text(
                        profile.fullName.isNotEmpty ? profile.fullName[0] : '?',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 16),
              Text(profile.fullName, style: AppTypography.h2,
                  textAlign: TextAlign.center),
              if (profile.specialization != null) ...[
                const SizedBox(height: 4),
                Text(profile.specialization!,
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.neutral500),
                    textAlign: TextAlign.center),
              ],
              const SizedBox(height: 8),
              if (profile.licenseVerified)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.success.withAlpha(15),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const FaIcon(FontAwesomeIcons.circleCheck,
                          size: 11, color: AppColors.success),
                      const SizedBox(width: 4),
                      Text('Verified',
                          style: AppTypography.caption.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              FilledButton.icon(
                icon: const FaIcon(FontAwesomeIcons.pen, size: 13),
                label: const Text('Edit Profile'),
                onPressed: () {},
                style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(38)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildAffiliationsCard(context),
      ],
    );
  }

  Widget _buildAffiliationsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const FaIcon(FontAwesomeIcons.hospital,
                  size: 13, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Centers', style: AppTypography.h3),
            ],
          ),
          const Divider(height: 20),
          if (profile.centers.isEmpty)
            Text('No center affiliations',
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.neutral400))
          else
            ...profile.centers.map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.circle, size: 6,
                          color: AppColors.neutral300),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(c.centerName, style: AppTypography.body)),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildRightPanel(BuildContext context) {
    return Column(
      children: [
        _buildInfoCard(context, 'Contact Information', [
          _infoRow(FontAwesomeIcons.envelope, 'Email', profile.email),
          _infoRow(FontAwesomeIcons.idBadge, 'Badge Number', profile.badgeNumber),
        ]),
        const SizedBox(height: 16),
        if (profile.bio != null)
          _buildInfoCard(context, 'About', [
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text(profile.bio!, style: AppTypography.body),
            ),
          ]),
        if (profile.qualifications.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildInfoCard(context, 'Qualifications', [
            Padding(
              padding: const EdgeInsets.all(4),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: profile.qualifications
                    .map((q) => Chip(label: Text(q)))
                    .toList(),
              ),
            ),
          ]),
        ],
        if (profile.languages.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildInfoCard(context, 'Languages', [
            Padding(
              padding: const EdgeInsets.all(4),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: profile.languages
                    .map((l) => Chip(label: Text(l)))
                    .toList(),
              ),
            ),
          ]),
        ],
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, List<Widget> content) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.h3),
          const Divider(height: 16),
          ...content,
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          FaIcon(icon, size: 13, color: AppColors.neutral400),
          const SizedBox(width: 10),
          SizedBox(
            width: 120,
            child: Text(label,
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.neutral500)),
          ),
          Expanded(child: Text(value, style: AppTypography.body)),
        ],
      ),
    );
  }
}
