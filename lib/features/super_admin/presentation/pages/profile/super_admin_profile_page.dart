import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/di/service_locator.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/shell/page_header.dart';
import '../../../domain/entities/super_admin_profile.dart';
import '../../bloc/profile/super_admin_profile_bloc.dart';

class SuperAdminProfilePage extends StatelessWidget {
  const SuperAdminProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SuperAdminProfileBloc>()..add(const ProfileStarted()),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatefulWidget {
  const _ProfileView();

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  final _fullNameCtrl = TextEditingController();
  String _selectedGender = 'Male';
  DateTime? _selectedDob;
  bool _populated = false;

  static const _genders = ['Male', 'Female', 'Not Mentioned'];

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    super.dispose();
  }

  void _populate(SuperAdminProfile profile) {
    if (_populated) return;
    _populated = true;
    _fullNameCtrl.text = profile.fullName;
    _selectedGender = _genders.contains(profile.gender) ? profile.gender : 'Male';
    if (profile.dateOfBirth.isNotEmpty) {
      _selectedDob = DateTime.tryParse(profile.dateOfBirth);
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDob = picked);
      if (context.mounted) {
        final bloc = context.read<SuperAdminProfileBloc>();
        final current = (bloc.state is ProfileLoaded)
            ? (bloc.state as ProfileLoaded).profile
            : const SuperAdminProfile();
        bloc.add(ProfileChanged(current.copyWith(
          dateOfBirth: picked.toIso8601String().split('T').first,
        )));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SuperAdminProfileBloc, SuperAdminProfileState>(
      listener: (ctx, state) {
        if (state is ProfileLoaded && !_populated) {
          setState(() => _populate(state.profile));
        }
        if (state is ProfileSaved) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
        }
        if (state is ProfileError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      },
      child: BlocBuilder<SuperAdminProfileBloc, SuperAdminProfileState>(
        builder: (ctx, state) {
          final profile = state is ProfileLoaded
              ? state.profile
              : const SuperAdminProfile();
          final isLoading = state is ProfileLoading;
          final isSaving = state is ProfileSaving;

          return Column(
            children: [
              const PageHeader(
                title: 'My Profile',
                subtitle: 'View and manage your account details',
              ),
              if (isLoading)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _avatarRow(profile),
                        const SizedBox(height: AppSpacing.base),
                        _sectionCard(
                          'Account Information',
                          Column(
                            children: [
                              _infoRow('Email', profile.email),
                              _infoRow('Phone', profile.phoneNumber),
                              _infoRow('Status', profile.isVerified ? 'Verified' : 'Unverified'),
                              _infoRow(
                                'Last Login',
                                profile.lastLogin != null
                                    ? _formatDateTime(profile.lastLogin!)
                                    : 'Never',
                              ),
                              _infoRow('Member Since', _formatDateTime(profile.createdAt)),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.base),
                        _sectionCard(
                          'Edit Profile',
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                controller: _fullNameCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Full Name',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (v) {
                                  ctx.read<SuperAdminProfileBloc>().add(
                                        ProfileChanged(profile.copyWith(fullName: v)),
                                      );
                                },
                              ),
                              const SizedBox(height: AppSpacing.base),
                              InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Gender',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                ),
                                child: DropdownButton<String>(
                                  value: _selectedGender,
                                  isExpanded: true,
                                  underline: const SizedBox.shrink(),
                                  items: _genders
                                      .map((g) =>
                                          DropdownMenuItem(value: g, child: Text(g)))
                                      .toList(),
                                  onChanged: (v) {
                                    if (v == null) return;
                                    setState(() => _selectedGender = v);
                                    ctx.read<SuperAdminProfileBloc>().add(
                                          ProfileChanged(profile.copyWith(gender: v)),
                                        );
                                  },
                                ),
                              ),
                              const SizedBox(height: AppSpacing.base),
                              InkWell(
                                onTap: () => _pickDate(ctx),
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'Date of Birth',
                                    border: OutlineInputBorder(),
                                    suffixIcon: Icon(Icons.calendar_today),
                                  ),
                                  child: Text(
                                    _selectedDob != null
                                        ? _selectedDob!.toIso8601String().split('T').first
                                        : profile.dateOfBirth.isNotEmpty
                                            ? profile.dateOfBirth
                                            : 'Select date',
                                    style: AppTypography.bodyMedium,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              Align(
                                alignment: Alignment.centerRight,
                                child: FilledButton(
                                  onPressed: isSaving
                                      ? null
                                      : () {
                                          ctx.read<SuperAdminProfileBloc>().add(
                                                ProfileChanged(profile.copyWith(
                                                  fullName: _fullNameCtrl.text,
                                                  gender: _selectedGender,
                                                )),
                                              );
                                          ctx.read<SuperAdminProfileBloc>().add(
                                                const ProfileUpdateRequested(),
                                              );
                                        },
                                  child: isSaving
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2, color: Colors.white),
                                        )
                                      : const Text('Save Changes'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _avatarRow(SuperAdminProfile profile) => Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.primaryLight,
            backgroundImage: profile.profileImageUrl != null
                ? NetworkImage(profile.profileImageUrl!)
                : null,
            child: profile.profileImageUrl == null
                ? Text(
                    profile.fullName.isNotEmpty
                        ? profile.fullName[0].toUpperCase()
                        : 'S',
                    style: AppTypography.h2.copyWith(color: AppColors.primary),
                  )
                : null,
          ),
          const SizedBox(width: AppSpacing.base),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(profile.fullName.isNotEmpty ? profile.fullName : '—',
                  style: AppTypography.h3),
              Text('Super Administrator',
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.neutral500)),
            ],
          ),
        ],
      );

  Widget _sectionCard(String title, Widget child) => Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.h3),
              const SizedBox(height: AppSpacing.base),
              child,
            ],
          ),
        ),
      );

  Widget _infoRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            SizedBox(
              width: 120,
              child: Text(label,
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.neutral500)),
            ),
            Expanded(child: Text(value, style: AppTypography.bodyMedium)),
          ],
        ),
      );

  String _formatDateTime(String raw) {
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}
