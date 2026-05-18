import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../di/service_locator.dart';
import '../../network/user_context.dart';
import '../../routing/route_names.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class _PaletteItem {
  final String label;
  final String? description;
  final String category;
  final IconData icon;
  final void Function(BuildContext ctx) action;

  const _PaletteItem({
    required this.label,
    this.description,
    required this.category,
    required this.icon,
    required this.action,
  });
}

class CommandPalette extends StatefulWidget {
  const CommandPalette._();

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => CommandPalette._(),
    );
  }

  @override
  State<CommandPalette> createState() => _CommandPaletteState();
}

class _CommandPaletteState extends State<CommandPalette> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  int _selectedIndex = 0;
  String _query = '';
  late final List<_PaletteItem> _allItems;

  @override
  void initState() {
    super.initState();
    _allItems = _buildItems();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _focusNode.requestFocus(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<_PaletteItem> _buildItems() {
    final userType = sl<UserContext>().userType;
    switch (userType) {
      case UserType.doctor:
        return _doctorItems;
      case UserType.admin:
        return _adminItems;
      case UserType.superAdmin:
        return _superAdminItems;
      case UserType.unknown:
        return [];
    }
  }

  static List<_PaletteItem> get _doctorItems => [
    _nav(
      'Dashboard',
      FontAwesomeIcons.house,
      RouteNames.doctorDashboard,
      'Pages',
    ),
    _nav(
      "Today's Queue",
      FontAwesomeIcons.peopleGroup,
      RouteNames.doctorQueue,
      'Pages',
    ),
    _nav(
      'Appointments — Calendar',
      FontAwesomeIcons.calendarDays,
      RouteNames.doctorAppointmentsCalendar,
      'Pages',
    ),
    _nav(
      'Appointments — List',
      FontAwesomeIcons.listUl,
      RouteNames.doctorAppointmentsList,
      'Pages',
    ),
    _nav(
      'My Patients',
      FontAwesomeIcons.userInjured,
      RouteNames.doctorPatients,
      'Pages',
    ),
    _nav(
      'Consultations',
      FontAwesomeIcons.video,
      RouteNames.doctorConsultations,
      'Pages',
    ),
    _nav(
      'Prescriptions',
      FontAwesomeIcons.prescription,
      RouteNames.doctorPrescriptions,
      'Pages',
    ),
    _nav(
      'New Prescription',
      FontAwesomeIcons.plus,
      RouteNames.doctorPrescriptionsNew,
      'Actions',
    ),
    _nav(
      'My Schedule',
      FontAwesomeIcons.clock,
      RouteNames.doctorSchedule,
      'Pages',
    ),
    _nav('Profile', FontAwesomeIcons.user, RouteNames.doctorProfile, 'Pages'),
    _nav('Settings', FontAwesomeIcons.gear, RouteNames.doctorSettings, 'Pages'),
  ];

  static List<_PaletteItem> get _adminItems => [
    _nav(
      'Dashboard',
      FontAwesomeIcons.gaugeHigh,
      RouteNames.adminDashboard,
      'Pages',
    ),
    _nav(
      'Live Queue',
      FontAwesomeIcons.peopleGroup,
      RouteNames.adminQueue,
      'Pages',
    ),
    _nav(
      'Pending Appointments',
      FontAwesomeIcons.clock,
      RouteNames.adminAppointmentsPending,
      'Pages',
    ),
    _nav(
      'Appointments — Calendar',
      FontAwesomeIcons.calendarDays,
      RouteNames.adminAppointmentsCalendar,
      'Pages',
    ),
    _nav(
      'Appointments — All',
      FontAwesomeIcons.listUl,
      RouteNames.adminAppointmentsList,
      'Pages',
    ),
    _nav(
      'Doctors',
      FontAwesomeIcons.userDoctor,
      RouteNames.adminDoctors,
      'Pages',
    ),
    _nav(
      'Patients',
      FontAwesomeIcons.hospitalUser,
      RouteNames.adminPatients,
      'Pages',
    ),
    _nav(
      'Payments',
      FontAwesomeIcons.moneyBill,
      RouteNames.adminPayments,
      'Pages',
    ),
    // _nav('Prescriptions', FontAwesomeIcons.prescription, RouteNames.adminPrescriptions, 'Pages'),
    _nav(
      'Analytics Overview',
      FontAwesomeIcons.chartLine,
      RouteNames.adminAnalyticsDashboard,
      'Pages',
    ),
    _nav(
      'Revenue Analytics',
      FontAwesomeIcons.moneyBill,
      RouteNames.adminAnalyticsRevenue,
      'Pages',
    ),
    _nav(
      'Staff & Admins',
      FontAwesomeIcons.usersGear,
      RouteNames.adminAdmins,
      'Pages',
    ),
    _nav(
      'Audit Log',
      FontAwesomeIcons.clockRotateLeft,
      RouteNames.adminAuditLog,
      'Pages',
    ),
    _nav(
      'Center Settings',
      FontAwesomeIcons.building,
      RouteNames.adminSettingsCenter,
      'Pages',
    ),
    _nav('Profile', FontAwesomeIcons.user, RouteNames.adminProfile, 'Pages'),
    _PaletteItem(
      label: 'Add Appointment',
      description: 'Create a new appointment',
      category: 'Actions',
      icon: FontAwesomeIcons.calendarPlus,
      action: (ctx) => ctx.go(RouteNames.adminAppointmentsPending),
    ),
  ];

  static List<_PaletteItem> get _superAdminItems => [
    _nav(
      'Platform Dashboard',
      FontAwesomeIcons.globe,
      RouteNames.superAdminDashboard,
      'Pages',
    ),
    _nav(
      'All Centers',
      FontAwesomeIcons.hospital,
      RouteNames.superAdminCenters,
      'Pages',
    ),
    _nav(
      'Centers — Pending Approval',
      FontAwesomeIcons.clock,
      RouteNames.superAdminCentersPending,
      'Pages',
    ),
    _nav(
      'Centers — Suspended',
      FontAwesomeIcons.ban,
      RouteNames.superAdminCentersSuspended,
      'Pages',
    ),
    _nav(
      'Doctors',
      FontAwesomeIcons.userDoctor,
      RouteNames.superAdminDoctors,
      'Pages',
    ),
    _nav(
      'Doctors — Pending Verification',
      FontAwesomeIcons.hourglassHalf,
      RouteNames.superAdminDoctorsPending,
      'Pages',
    ),
    _nav('Users', FontAwesomeIcons.users, RouteNames.superAdminUsers, 'Pages'),
    _nav(
      'Subscriptions',
      FontAwesomeIcons.creditCard,
      RouteNames.superAdminSubscriptions,
      'Pages',
    ),
    _nav(
      'Analytics — Overview',
      FontAwesomeIcons.chartLine,
      RouteNames.superAdminAnalyticsDashboard,
      'Pages',
    ),
    _nav(
      'Analytics — Revenue',
      FontAwesomeIcons.moneyBill,
      RouteNames.superAdminAnalyticsRevenue,
      'Pages',
    ),
    _nav(
      'Analytics — Growth',
      FontAwesomeIcons.arrowTrendUp,
      RouteNames.superAdminAnalyticsGrowth,
      'Pages',
    ),
    _nav(
      'Audit Log',
      FontAwesomeIcons.clockRotateLeft,
      RouteNames.superAdminAuditLog,
      'Pages',
    ),
    _nav(
      'Platform Settings',
      FontAwesomeIcons.gear,
      RouteNames.superAdminSettings,
      'Pages',
    ),
    _nav(
      'Profile',
      FontAwesomeIcons.user,
      RouteNames.superAdminProfile,
      'Pages',
    ),
  ];

  static _PaletteItem _nav(
    String label,
    IconData icon,
    String route,
    String category,
  ) {
    return _PaletteItem(
      label: label,
      category: category,
      icon: icon,
      action: (ctx) => ctx.go(route),
    );
  }

  List<_PaletteItem> get _filtered {
    if (_query.isEmpty) return _allItems;
    final q = _query.toLowerCase();
    return _allItems
        .where(
          (a) =>
              a.label.toLowerCase().contains(q) ||
              (a.description?.toLowerCase().contains(q) ?? false) ||
              a.category.toLowerCase().contains(q),
        )
        .toList();
  }

  void _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    final filtered = _filtered;
    if (filtered.isEmpty) return;
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      setState(() => _selectedIndex = (_selectedIndex + 1) % filtered.length);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      setState(
        () => _selectedIndex =
            (_selectedIndex - 1 + filtered.length) % filtered.length,
      );
    } else if (event.logicalKey == LogicalKeyboardKey.enter) {
      _execute(filtered[_selectedIndex]);
    } else if (event.logicalKey == LogicalKeyboardKey.escape) {
      Navigator.of(context).pop();
    }
  }

  void _execute(_PaletteItem item) {
    Navigator.of(context).pop();
    item.action(context);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: _handleKey,
        child: Container(
          width: 560,
          constraints: const BoxConstraints(maxHeight: 480),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.neutral200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(40),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSearchInput(),
              if (filtered.isNotEmpty) const Divider(height: 1),
              if (filtered.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    _query.isEmpty
                        ? 'Type to search pages and actions...'
                        : 'No results for "$_query"',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.neutral400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => _buildTile(filtered[i], i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const FaIcon(
            FontAwesomeIcons.magnifyingGlass,
            size: 16,
            color: AppColors.neutral400,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              decoration: const InputDecoration(
                hintText: 'Search pages, actions...',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: AppTypography.body,
              onChanged: (v) => setState(() {
                _query = v;
                _selectedIndex = 0;
              }),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Esc',
              style: AppTypography.caption.copyWith(
                color: AppColors.neutral400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(_PaletteItem item, int index) {
    final isSelected = index == _selectedIndex;
    return MouseRegion(
      onEnter: (_) => setState(() => _selectedIndex = index),
      child: GestureDetector(
        onTap: () => _execute(item),
        child: Container(
          color: isSelected ? AppColors.primaryLight.withAlpha(80) : null,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.neutral100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: FaIcon(
                    item.icon,
                    size: 12,
                    color: AppColors.neutral500,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.label, style: AppTypography.bodySmall),
                    if (item.description != null)
                      Text(
                        item.description!,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.neutral400,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.neutral100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item.category,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.neutral500,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
