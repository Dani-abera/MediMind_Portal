import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/storage/preferences_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/shell/page_header.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';

class DoctorSettingsPage extends StatefulWidget {
  const DoctorSettingsPage({super.key});

  @override
  State<DoctorSettingsPage> createState() => _DoctorSettingsPageState();
}

class _DoctorSettingsPageState extends State<DoctorSettingsPage> {
  late final PreferencesStorage _prefs;
  late String _themeMode;
  late String _locale;

  @override
  void initState() {
    super.initState();
    _prefs = sl<PreferencesStorage>();
    _themeMode = _prefs.getThemeMode();
    _locale = _prefs.getLocale();
  }

  Future<void> _setTheme(String mode) async {
    await _prefs.setThemeMode(mode);
    setState(() => _themeMode = mode);
  }

  Future<void> _setLocale(String locale) async {
    await _prefs.setLocale(locale);
    setState(() => _locale = locale);
  }

  void _logout() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AuthBloc>().add(const AuthLogoutRequested());
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const PageHeader(
          title: 'Settings',
          subtitle: 'Preferences & account',
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      context,
                      icon: FontAwesomeIcons.paintbrush,
                      title: 'Appearance',
                      children: [
                        _buildOptionRow(
                          label: 'Theme',
                          child: SegmentedButton<String>(
                            segments: const [
                              ButtonSegment(value: 'light', label: Text('Light')),
                              ButtonSegment(value: 'dark', label: Text('Dark')),
                              ButtonSegment(value: 'system', label: Text('System')),
                            ],
                            selected: {_themeMode},
                            onSelectionChanged: (s) => _setTheme(s.first),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      context,
                      icon: FontAwesomeIcons.globe,
                      title: 'Language',
                      children: [
                        _buildOptionRow(
                          label: 'Interface language',
                          child: DropdownButton<String>(
                            value: _locale,
                            underline: const SizedBox.shrink(),
                            items: const [
                              DropdownMenuItem(value: 'en', child: Text('English')),
                              DropdownMenuItem(value: 'am', child: Text('Amharic')),
                            ],
                            onChanged: (v) {
                              if (v != null) _setLocale(v);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      context,
                      icon: FontAwesomeIcons.userDoctor,
                      title: 'Profile',
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const FaIcon(FontAwesomeIcons.idCard,
                              size: 15, color: AppColors.neutral500),
                          title: Text('Edit my profile', style: AppTypography.body),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.go(RouteNames.doctorProfile),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const FaIcon(FontAwesomeIcons.calendarDays,
                              size: 15, color: AppColors.neutral500),
                          title: Text('Manage schedules', style: AppTypography.body),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.go(RouteNames.doctorSchedule),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      context,
                      icon: FontAwesomeIcons.rightFromBracket,
                      title: 'Account',
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const FaIcon(FontAwesomeIcons.rightFromBracket,
                              size: 15, color: AppColors.danger),
                          title: Text('Sign out',
                              style: AppTypography.body
                                  .copyWith(color: AppColors.danger)),
                          onTap: _logout,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
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
              FaIcon(icon, size: 13, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(title, style: AppTypography.h3),
            ],
          ),
          const Divider(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildOptionRow({required String label, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 160,
            child: Text(label,
                style: AppTypography.body.copyWith(color: AppColors.neutral600)),
          ),
          child,
        ],
      ),
    );
  }
}
