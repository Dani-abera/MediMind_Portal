import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/network/user_context.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/feedback/app_loading.dart';
import '../../../../core/widgets/shell/page_header.dart';
import '../../../../features/auth/domain/entities/admin_user.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/center_config.dart';
import '../bloc/center_settings/center_settings_bloc.dart';

class AdminProfilePage extends StatelessWidget {
  const AdminProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CenterSettingsBloc>()
        ..add(CenterSettingsStarted(UserContext().centerId ?? '')),
      child: const _AdminProfileView(),
    );
  }
}

class _AdminProfileView extends StatelessWidget {
  const _AdminProfileView();

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final adminUser =
        authState is AuthAuthenticated ? authState.user as AdminUser? : null;

    return Column(
      children: [
        const PageHeader(
          title: 'My Profile',
          subtitle: 'Account & Health Center',
        ),
        Expanded(
          child: BlocBuilder<CenterSettingsBloc, CenterSettingsState>(
            builder: (ctx, state) {
              if (state is CenterSettingsLoading || state is CenterSettingsInitial) {
                return const Center(child: AppLoadingSpinner());
              }
              if (state is CenterSettingsError) {
                return AppErrorState(
                  message: state.message,
                  onRetry: () => ctx
                      .read<CenterSettingsBloc>()
                      .add(CenterSettingsStarted(UserContext().centerId ?? '')),
                );
              }
              final config = state is CenterSettingsLoaded ? state.config : const CenterConfig();
              return _ProfileContent(adminUser: adminUser, config: config);
            },
          ),
        ),
      ],
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final AdminUser? adminUser;
  final CenterConfig config;

  const _ProfileContent({required this.adminUser, required this.config});

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
    final name = adminUser?.fullName ?? '—';
    final email = adminUser?.email ?? '';
    final avatarUrl = adminUser?.avatarUrl;
    final initials = name.isNotEmpty ? name[0].toUpperCase() : 'A';

    return Container(
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
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
            child: avatarUrl == null
                ? Text(
                    initials,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          Text(name, style: AppTypography.h2, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.info.withAlpha(15),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const FaIcon(FontAwesomeIcons.userShield,
                    size: 11, color: AppColors.info),
                const SizedBox(width: 4),
                Text(
                  'Health Center Admin',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.info,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (email.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              email,
              style: AppTypography.caption.copyWith(color: AppColors.neutral500),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (config.name.isNotEmpty) ...[
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const FaIcon(FontAwesomeIcons.hospital,
                    size: 12, color: AppColors.neutral400),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    config.name,
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.neutral600),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRightPanel(BuildContext context) {
    return Column(
      children: [
        _buildInfoCard(context, 'Account', [
          if (adminUser?.email != null)
            _infoRow(FontAwesomeIcons.envelope, 'Email', adminUser!.email),
          if (adminUser?.id != null)
            _infoRow(FontAwesomeIcons.idBadge, 'User ID', adminUser!.id),
        ]),
        const SizedBox(height: 16),
        _buildInfoCard(context, 'Health Center', [
          if (config.name.isNotEmpty)
            _infoRow(FontAwesomeIcons.hospital, 'Center Name', config.name),
          if (config.city.isNotEmpty)
            _infoRow(FontAwesomeIcons.locationDot, 'City', config.city),
          if (config.region.isNotEmpty)
            _infoRow(FontAwesomeIcons.mapPin, 'Region', config.region),
          if (config.fullAddress.isNotEmpty)
            _infoRow(FontAwesomeIcons.mapLocation, 'Address', config.fullAddress),
          if (config.phone.isNotEmpty)
            _infoRow(FontAwesomeIcons.phone, 'Phone', config.phone),
          if (config.email.isNotEmpty)
            _infoRow(FontAwesomeIcons.envelopeOpen, 'Center Email', config.email),
          if (config.licenseNumber.isNotEmpty)
            _infoRow(FontAwesomeIcons.certificate, 'License No.', config.licenseNumber),
        ]),
        if (config.specializations.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildInfoCard(context, 'Specializations', [
            Padding(
              padding: const EdgeInsets.all(4),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: config.specializations
                    .map((s) => Chip(label: Text(s)))
                    .toList(),
              ),
            ),
          ]),
        ],
        if (config.services.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildInfoCard(context, 'Services', [
            Padding(
              padding: const EdgeInsets.all(4),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: config.services
                    .map((s) => Chip(label: Text(s)))
                    .toList(),
              ),
            ),
          ]),
        ],
      ],
    );
  }

  Widget _buildInfoCard(
      BuildContext context, String title, List<Widget> content) {
    if (content.isEmpty) return const SizedBox.shrink();
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
            child: Text(
              label,
              style: AppTypography.bodySmall
                  .copyWith(color: AppColors.neutral500),
            ),
          ),
          Expanded(child: Text(value, style: AppTypography.body)),
        ],
      ),
    );
  }
}
